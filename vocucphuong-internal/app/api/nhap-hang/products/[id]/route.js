import { query, queryOne } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

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
    const existing = await queryOne('SELECT * FROM "Products" WHERE id = $1', [params.id]);

    if (!existing) {
      return NextResponse.json({ success: false, message: 'Không tìm thấy sản phẩm!' }, { status: 404 });
    }

    const allowedFields = [
      'senderName', 'senderPhone', 'senderStation',
      'receiverName', 'receiverPhone', 'station',
      'productType', 'quantity', 'vehicle', 'insurance', 'totalAmount',
      'paymentStatus', 'status', 'notes'
    ];

    const updates = [];
    const values = [];
    let paramIndex = 1;

    for (const field of allowedFields) {
      if (body[field] !== undefined) {
        updates.push(`"${field}" = $${paramIndex}`);
        values.push(body[field]);
        paramIndex++;
      }
    }

    if (updates.length === 0) {
      return NextResponse.json({ success: false, message: 'Không có dữ liệu để cập nhật!' }, { status: 400 });
    }

    updates.push(`"updatedAt" = NOW()`);
    values.push(params.id);

    const sqlQuery = `UPDATE "Products" SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`;
    const result = await query(sqlQuery, values);

    return NextResponse.json({
      success: true,
      message: 'Cập nhật thành công!',
      product: result[0]
    });
  } catch (error) {
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}

// DELETE /api/nhap-hang/products/:id
export async function DELETE(request, { params }) {
  try {
    const existing = await queryOne('SELECT * FROM "Products" WHERE id = $1', [params.id]);

    if (!existing) {
      return NextResponse.json({ success: false, message: 'Không tìm thấy sản phẩm!' }, { status: 404 });
    }

    await query('DELETE FROM "Products" WHERE id = $1', [params.id]);

    return NextResponse.json({ success: true, message: 'Xóa thành công!' });
  } catch (error) {
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}
