import { queryNhapHang, queryOneNhapHang } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: Users/[id] - Chi tiết người dùng
// ===========================================
// GET /api/nhap-hang/users/[id] - Lấy chi tiết
// PUT /api/nhap-hang/users/[id] - Cập nhật
// DELETE /api/nhap-hang/users/[id] - Xóa

// GET - Lấy chi tiết user
export async function GET(request, { params }) {
  try {
    const { id } = await params;

    const user = await queryOneNhapHang(`
      SELECT id, username, "fullName", phone, role, station, active, "createdAt", "updatedAt"
      FROM "Users"
      WHERE id = $1
    `, [id]);

    if (!user) {
      return NextResponse.json({
        success: false,
        error: 'Người dùng không tồn tại',
        message: 'User not found'
      }, { status: 404 });
    }

    return NextResponse.json({
      success: true,
      data: user,
      user
    });

  } catch (error) {
    console.error('[Users/id] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      message: error.message
    }, { status: 500 });
  }
}

// PUT - Cập nhật user
export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const body = await request.json();

    // Check if user exists
    const existing = await queryOneNhapHang(`
      SELECT * FROM "Users" WHERE id = $1
    `, [id]);

    if (!existing) {
      return NextResponse.json({
        success: false,
        error: 'Người dùng không tồn tại',
        message: 'User not found'
      }, { status: 404 });
    }

    const { username, password, fullName, phone, role, station, active } = body;

    // Build update query
    const updates = [];
    const values = [];
    let paramIndex = 1;

    if (username !== undefined) {
      updates.push(`username = $${paramIndex}`);
      values.push(username);
      paramIndex++;
    }
    if (password !== undefined && password !== '') {
      updates.push(`password = $${paramIndex}`);
      values.push(password); // Plain text for now, should hash in production
      paramIndex++;
    }
    if (fullName !== undefined) {
      updates.push(`"fullName" = $${paramIndex}`);
      values.push(fullName);
      paramIndex++;
    }
    if (phone !== undefined) {
      updates.push(`phone = $${paramIndex}`);
      values.push(phone);
      paramIndex++;
    }
    if (role !== undefined) {
      updates.push(`role = $${paramIndex}`);
      values.push(role);
      paramIndex++;
    }
    if (station !== undefined) {
      updates.push(`station = $${paramIndex}`);
      values.push(station);
      paramIndex++;
    }
    if (active !== undefined) {
      updates.push(`active = $${paramIndex}`);
      values.push(active);
      paramIndex++;
    }

    if (updates.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'Không có dữ liệu để cập nhật',
        message: 'No fields to update'
      }, { status: 400 });
    }

    updates.push(`"updatedAt" = NOW()`);
    values.push(id);

    const result = await queryNhapHang(`
      UPDATE "Users"
      SET ${updates.join(', ')}
      WHERE id = $${paramIndex}
      RETURNING id, username, "fullName", phone, role, station, active, "createdAt", "updatedAt"
    `, values);

    return NextResponse.json({
      success: true,
      message: 'Cập nhật người dùng thành công!',
      data: result[0],
      user: result[0]
    });

  } catch (error) {
    console.error('[Users/id] PUT Error:', error);

    if (error.code === '23505') {
      return NextResponse.json({
        success: false,
        error: 'Username đã tồn tại',
        message: 'Username already exists'
      }, { status: 409 });
    }

    return NextResponse.json({
      success: false,
      error: error.message,
      message: error.message
    }, { status: 500 });
  }
}

// DELETE - Xóa user
export async function DELETE(request, { params }) {
  try {
    const { id } = await params;

    // Check if user exists
    const existing = await queryOneNhapHang(`
      SELECT * FROM "Users" WHERE id = $1
    `, [id]);

    if (!existing) {
      return NextResponse.json({
        success: false,
        error: 'Người dùng không tồn tại',
        message: 'User not found'
      }, { status: 404 });
    }

    // Prevent deleting admin
    if (existing.role === 'admin' && existing.username === 'admin') {
      return NextResponse.json({
        success: false,
        error: 'Không thể xóa tài khoản admin',
        message: 'Cannot delete admin account'
      }, { status: 403 });
    }

    await queryNhapHang(`
      DELETE FROM "Users" WHERE id = $1
    `, [id]);

    return NextResponse.json({
      success: true,
      message: 'Xóa người dùng thành công!',
      deletedId: id
    });

  } catch (error) {
    console.error('[Users/id] DELETE Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      message: error.message
    }, { status: 500 });
  }
}
