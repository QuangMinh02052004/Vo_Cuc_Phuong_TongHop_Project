import { queryNhapHang, queryOneNhapHang, queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// ===========================================
// API: Products/[id] - Chi tiết đơn hàng
// ===========================================
// GET /api/nhap-hang/products/[id] - Lấy chi tiết
// PUT /api/nhap-hang/products/[id] - Cập nhật toàn bộ
// PATCH /api/nhap-hang/products/[id] - Cập nhật một phần
// DELETE /api/nhap-hang/products/[id] - Xóa đơn hàng

// Lấy IP từ request
function getClientIP(request) {
  return request.headers.get('x-forwarded-for')?.split(',')[0] ||
         request.headers.get('x-real-ip') ||
         null;
}

// Helper: Convert sendDate to string without timezone (để frontend không bị convert)
function sanitizeSendDate(product) {
  if (product && product.sendDate) {
    if (product.sendDate instanceof Date) {
      const d = product.sendDate;
      const year = d.getUTCFullYear();
      const month = String(d.getUTCMonth() + 1).padStart(2, '0');
      const day = String(d.getUTCDate()).padStart(2, '0');
      const hours = String(d.getUTCHours()).padStart(2, '0');
      const minutes = String(d.getUTCMinutes()).padStart(2, '0');
      const seconds = String(d.getUTCSeconds()).padStart(2, '0');
      product.sendDate = `${year}-${month}-${day}T${hours}:${minutes}:${seconds}`;
    } else if (typeof product.sendDate === 'string') {
      product.sendDate = product.sendDate.replace('Z', '').replace(/[+-]\d{2}:\d{2}$/, '');
    }
  }
  return product;
}

// Helper: Ghi log thay đổi
async function logProductChange(productId, action, field, oldValue, newValue, changedBy, ipAddress) {
  try {
    await queryNhapHang(`
      INSERT INTO "ProductLogs" ("productId", action, field, "oldValue", "newValue", "changedBy", "ipAddress")
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [
      productId,
      action,
      field || null,
      oldValue !== undefined && oldValue !== null ? String(oldValue) : null,
      newValue !== undefined && newValue !== null ? String(newValue) : null,
      changedBy,
      ipAddress || null
    ]);
  } catch (error) {
    console.error('Error logging product change:', error.message);
  }
}

// GET - Lấy chi tiết đơn hàng
export async function GET(request, { params }) {
  try {
    const { id } = await params;

    const product = await queryOneNhapHang(`
      SELECT * FROM "Products" WHERE id = $1
    `, [id]);

    if (!product) {
      return NextResponse.json({
        success: false,
        error: 'Đơn hàng không tồn tại',
        message: 'Không tìm thấy sản phẩm!'
      }, { status: 404 });
    }

    // Get logs for this product
    const logs = await queryNhapHang(`
      SELECT * FROM "ProductLogs"
      WHERE "productId" = $1
      ORDER BY "changedAt" DESC
      LIMIT 50
    `, [id]);

    // Sanitize sendDate để không có Z suffix
    const sanitizedProduct = sanitizeSendDate({ ...product });

    return NextResponse.json({
      success: true,
      data: sanitizedProduct,
      product: sanitizedProduct, // Backward compatibility
      logs
    });

  } catch (error) {
    console.error('[Products/id] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      message: error.message
    }, { status: 500 });
  }
}

// PUT - Cập nhật đơn hàng
export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const body = await request.json();
    const clientIP = getClientIP(request);
    const { changedBy } = body;

    // Get current product
    const existing = await queryOneNhapHang(`
      SELECT * FROM "Products" WHERE id = $1
    `, [id]);

    if (!existing) {
      return NextResponse.json({
        success: false,
        error: 'Đơn hàng không tồn tại',
        message: 'Không tìm thấy sản phẩm!'
      }, { status: 404 });
    }

    const allowedFields = [
      'senderName', 'senderPhone', 'senderStation',
      'receiverName', 'receiverPhone', 'station',
      'productType', 'quantity', 'vehicle', 'insurance', 'totalAmount',
      'paymentStatus', 'status', 'deliveryStatus', 'employee', 'notes',
      'deliveredAt'
    ];

    const updates = [];
    const values = [];
    let paramIndex = 1;

    // Track changes for logging
    const changedFields = [];

    for (const field of allowedFields) {
      if (body[field] !== undefined) {
        const oldValue = existing[field];
        const newValue = body[field];

        // Chỉ cập nhật nếu giá trị thực sự thay đổi
        if (String(oldValue) !== String(newValue)) {
          updates.push(`"${field}" = $${paramIndex}`);
          values.push(body[field]);
          paramIndex++;

          // Track for logging
          changedFields.push({ field, oldValue, newValue });
        }
      }
    }

    if (updates.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'Không có dữ liệu để cập nhật',
        message: 'Không có dữ liệu để cập nhật!'
      }, { status: 400 });
    }

    updates.push(`"updatedAt" = NOW()`);
    values.push(id);

    const sqlQuery = `UPDATE "Products" SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`;
    const result = await queryNhapHang(sqlQuery, values);

    const updatedProduct = result[0];

    // Ghi log các thay đổi
    const userName = changedBy || 'system';

    if (changedFields.length === 1) {
      const change = changedFields[0];
      await logProductChange(id, 'update', change.field, change.oldValue, change.newValue, userName, clientIP);
    } else if (changedFields.length > 1) {
      const oldValues = changedFields.map(c => ({ [c.field]: c.oldValue }));
      const newValues = changedFields.map(c => ({ [c.field]: c.newValue }));
      await logProductChange(
        id,
        'update',
        `${changedFields.length} fields`,
        JSON.stringify(oldValues),
        JSON.stringify(newValues),
        userName,
        clientIP
      );
    }

    // Sanitize sendDate
    const sanitizedProduct = sanitizeSendDate({ ...updatedProduct });

    return NextResponse.json({
      success: true,
      message: 'Cập nhật thành công!',
      data: sanitizedProduct,
      product: sanitizedProduct
    });

  } catch (error) {
    console.error('[Products/id] PUT Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      message: error.message
    }, { status: 500 });
  }
}

// DELETE - Xóa đơn hàng
export async function DELETE(request, { params }) {
  try {
    const { id } = await params;
    const clientIP = getClientIP(request);
    const { searchParams } = new URL(request.url);
    const changedBy = searchParams.get('changedBy') || 'system';

    // Get current product
    const existing = await queryOneNhapHang(`
      SELECT * FROM "Products" WHERE id = $1
    `, [id]);

    if (!existing) {
      return NextResponse.json({
        success: false,
        error: 'Đơn hàng không tồn tại',
        message: 'Không tìm thấy sản phẩm!'
      }, { status: 404 });
    }

    // If synced to TongHop, delete the booking too
    if (existing.tongHopBookingId) {
      try {
        await queryTongHop(`
          DELETE FROM "TH_Bookings" WHERE id = $1
        `, [existing.tongHopBookingId]);
        console.log(`[Products] Deleted TongHop booking: ${existing.tongHopBookingId}`);
      } catch (thError) {
        console.error('[Products] Error deleting TongHop booking:', thError.message);
      }
    }

    // Log deletion before deleting
    const productInfo = {
      receiverName: existing.receiverName,
      receiverPhone: existing.receiverPhone,
      totalAmount: existing.totalAmount
    };
    await logProductChange(id, 'delete', 'product_info', JSON.stringify(productInfo), null, changedBy, clientIP);

    // Delete product
    await queryNhapHang(`
      DELETE FROM "Products" WHERE id = $1
    `, [id]);

    return NextResponse.json({
      success: true,
      message: 'Xóa thành công!',
      deletedId: id
    });

  } catch (error) {
    console.error('[Products/id] DELETE Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      message: error.message
    }, { status: 500 });
  }
}
