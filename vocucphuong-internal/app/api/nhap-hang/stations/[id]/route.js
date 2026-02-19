import { queryNhapHang, queryOneNhapHang } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// ===========================================
// API: Stations/[id] - Chi tiết bến xe
// ===========================================
// GET /api/nhap-hang/stations/[id] - Lấy chi tiết
// PUT /api/nhap-hang/stations/[id] - Cập nhật
// DELETE /api/nhap-hang/stations/[id] - Xóa

// GET - Lấy chi tiết station
export async function GET(request, { params }) {
  try {
    const { id } = await params;

    const station = await queryOneNhapHang(`
      SELECT * FROM "Stations" WHERE id = $1
    `, [id]);

    if (!station) {
      return NextResponse.json({
        success: false,
        error: 'Bến xe không tồn tại'
      }, { status: 404 });
    }

    return NextResponse.json({
      success: true,
      data: station
    });

  } catch (error) {
    console.error('[Stations/id] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

// PUT - Cập nhật station
export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const body = await request.json();

    // Check if station exists
    const existing = await queryOneNhapHang(`
      SELECT * FROM "Stations" WHERE id = $1
    `, [id]);

    if (!existing) {
      return NextResponse.json({
        success: false,
        error: 'Bến xe không tồn tại'
      }, { status: 404 });
    }

    const { code, name, address, phone, region, isActive } = body;

    // Build update query
    const updates = [];
    const values = [];
    let paramIndex = 1;

    if (code !== undefined) {
      updates.push(`code = $${paramIndex}`);
      values.push(code);
      paramIndex++;
    }
    if (name !== undefined) {
      updates.push(`name = $${paramIndex}`);
      values.push(name);
      paramIndex++;

      // Auto-update fullName
      const newCode = code !== undefined ? code : existing.code;
      updates.push(`"fullName" = $${paramIndex}`);
      values.push(`${newCode} - ${name}`);
      paramIndex++;
    }
    if (address !== undefined) {
      updates.push(`address = $${paramIndex}`);
      values.push(address);
      paramIndex++;
    }
    if (phone !== undefined) {
      updates.push(`phone = $${paramIndex}`);
      values.push(phone);
      paramIndex++;
    }
    if (region !== undefined) {
      updates.push(`region = $${paramIndex}`);
      values.push(region);
      paramIndex++;
    }
    if (isActive !== undefined) {
      updates.push(`"isActive" = $${paramIndex}`);
      values.push(isActive);
      paramIndex++;
    }

    if (updates.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'Không có dữ liệu để cập nhật'
      }, { status: 400 });
    }

    values.push(id);

    const result = await queryNhapHang(`
      UPDATE "Stations"
      SET ${updates.join(', ')}, "updatedAt" = NOW()
      WHERE id = $${paramIndex}
      RETURNING *
    `, values);

    return NextResponse.json({
      success: true,
      message: 'Cập nhật bến xe thành công!',
      data: result[0]
    });

  } catch (error) {
    console.error('[Stations/id] PUT Error:', error);

    if (error.code === '23505') {
      return NextResponse.json({
        success: false,
        error: 'Mã bến xe đã tồn tại'
      }, { status: 409 });
    }

    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

// DELETE - Xóa station
export async function DELETE(request, { params }) {
  try {
    const { id } = await params;

    // Check if station exists
    const existing = await queryOneNhapHang(`
      SELECT * FROM "Stations" WHERE id = $1
    `, [id]);

    if (!existing) {
      return NextResponse.json({
        success: false,
        error: 'Bến xe không tồn tại'
      }, { status: 404 });
    }

    // Check if station is used in products
    const usedInProducts = await queryOneNhapHang(`
      SELECT COUNT(*) as count FROM "Products"
      WHERE station = $1 OR "senderStation" = $1
    `, [existing.fullName]);

    if (parseInt(usedInProducts.count) > 0) {
      return NextResponse.json({
        success: false,
        error: 'Không thể xóa bến xe đang được sử dụng trong đơn hàng'
      }, { status: 400 });
    }

    await queryNhapHang(`
      DELETE FROM "Stations" WHERE id = $1
    `, [id]);

    return NextResponse.json({
      success: true,
      message: 'Xóa bến xe thành công!',
      deletedId: id
    });

  } catch (error) {
    console.error('[Stations/id] DELETE Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
