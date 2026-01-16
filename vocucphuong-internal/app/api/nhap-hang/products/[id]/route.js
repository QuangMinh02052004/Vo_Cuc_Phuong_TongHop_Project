import { query, queryOne } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

// Helper function để ghi log thay đổi
async function logProductChange(productId, action, field, oldValue, newValue, changedBy, ipAddress) {
  try {
    await query(`
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

// Lấy IP từ request
function getClientIP(request) {
  return request.headers.get('x-forwarded-for')?.split(',')[0] ||
         request.headers.get('x-real-ip') ||
         null;
}

// GET /api/nhap-hang/products/:id
export async function GET(request, { params }) {
  try {
    const product = await queryOne('SELECT * FROM "Products" WHERE id = $1', [params.id]);

    if (!product) {
      return NextResponse.json({ success: false, message: 'Không tìm thấy sản phẩm!' }, { status: 404 });
    }

    return NextResponse.json({ success: true, product });
  } catch (error) {
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}

// PUT /api/nhap-hang/products/:id
export async function PUT(request, { params }) {
  try {
    const body = await request.json();
    const { changedBy } = body;
    const existing = await queryOne('SELECT * FROM "Products" WHERE id = $1', [params.id]);

    if (!existing) {
      return NextResponse.json({ success: false, message: 'Không tìm thấy sản phẩm!' }, { status: 404 });
    }

    const allowedFields = [
      'senderName', 'senderPhone', 'senderStation',
      'receiverName', 'receiverPhone', 'station',
      'productType', 'quantity', 'vehicle', 'insurance', 'totalAmount',
      'paymentStatus', 'status', 'deliveryStatus', 'notes'
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
      return NextResponse.json({ success: false, message: 'Không có dữ liệu để cập nhật!' }, { status: 400 });
    }

    updates.push(`"updatedAt" = NOW()`);
    values.push(params.id);

    const sqlQuery = `UPDATE "Products" SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`;
    const result = await query(sqlQuery, values);

    // Ghi log các thay đổi
    const clientIP = getClientIP(request);
    const userName = changedBy || 'system';

    if (changedFields.length === 1) {
      // Chỉ có 1 field thay đổi
      const change = changedFields[0];
      await logProductChange(params.id, 'update', change.field, change.oldValue, change.newValue, userName, clientIP);
    } else if (changedFields.length > 1) {
      // Nhiều field thay đổi - ghi tổng hợp
      const oldValues = changedFields.map(c => ({ [c.field]: c.oldValue }));
      const newValues = changedFields.map(c => ({ [c.field]: c.newValue }));
      await logProductChange(
        params.id,
        'update',
        `${changedFields.length} fields`,
        JSON.stringify(oldValues),
        JSON.stringify(newValues),
        userName,
        clientIP
      );
    }

    return NextResponse.json({
      success: true,
      message: 'Cập nhật thành công!',
      product: result[0]
    });
  } catch (error) {
    console.error('Error updating product:', error);
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}

// DELETE /api/nhap-hang/products/:id
export async function DELETE(request, { params }) {
  try {
    const { searchParams } = new URL(request.url);
    const changedBy = searchParams.get('changedBy') || 'system';

    const existing = await queryOne('SELECT * FROM "Products" WHERE id = $1', [params.id]);

    if (!existing) {
      return NextResponse.json({ success: false, message: 'Không tìm thấy sản phẩm!' }, { status: 404 });
    }

    // Ghi log trước khi xóa
    const clientIP = getClientIP(request);
    const productInfo = {
      receiverName: existing.receiverName,
      receiverPhone: existing.receiverPhone,
      totalAmount: existing.totalAmount
    };
    await logProductChange(params.id, 'delete', 'product_info', JSON.stringify(productInfo), null, changedBy, clientIP);

    await query('DELETE FROM "Products" WHERE id = $1', [params.id]);

    return NextResponse.json({ success: true, message: 'Xóa thành công!' });
  } catch (error) {
    console.error('Error deleting product:', error);
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}
