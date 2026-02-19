import { queryTongHop, queryOneTongHop } from '../../../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

export const dynamic = 'force-dynamic';

// ===========================================
// API: User by ID
// ===========================================
// GET /api/tong-hop/auth/users/[id] - Lấy user theo ID
// PUT /api/tong-hop/auth/users/[id] - Cập nhật user
// DELETE /api/tong-hop/auth/users/[id] - Xóa user

export async function GET(request, { params }) {
  try {
    const { id } = await params;

    const user = await queryOneTongHop(`
      SELECT id, username, "fullName", email, phone, role, active as "isActive", "createdAt"
      FROM "TH_Users"
      WHERE id = $1
    `, [id]);

    if (!user) {
      return NextResponse.json({
        success: false,
        error: 'User không tồn tại'
      }, { status: 404 });
    }

    return NextResponse.json(user);

  } catch (error) {
    console.error('[TH Users] GET by ID Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const body = await request.json();
    const { fullName, email, phone, role, isActive, password } = body;

    // Check if user exists
    const existing = await queryOneTongHop(
      'SELECT id FROM "TH_Users" WHERE id = $1',
      [id]
    );

    if (!existing) {
      return NextResponse.json({
        success: false,
        error: 'User không tồn tại'
      }, { status: 404 });
    }

    // Build update query
    let updateQuery = `
      UPDATE "TH_Users"
      SET "fullName" = $1, email = $2, phone = $3, role = $4, active = $5
    `;
    let updateParams = [fullName, email || null, phone || null, role || 'user', isActive !== false];

    // If password is provided, update it
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      updateQuery = `
        UPDATE "TH_Users"
        SET "fullName" = $1, email = $2, phone = $3, role = $4, active = $5, password = $6
      `;
      updateParams.push(hashedPassword);
    }

    const paramIndex = updateParams.length + 1;
    updateQuery += ` WHERE id = $${paramIndex} RETURNING id, username, "fullName", email, phone, role, active as "isActive"`;
    updateParams.push(id);

    const result = await queryOneTongHop(updateQuery, updateParams);

    return NextResponse.json({
      success: true,
      message: 'Cập nhật user thành công',
      user: result
    });

  } catch (error) {
    console.error('[TH Users] PUT Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  try {
    const { id } = await params;

    // Check if user exists
    const existing = await queryOneTongHop(
      'SELECT id, username FROM "TH_Users" WHERE id = $1',
      [id]
    );

    if (!existing) {
      return NextResponse.json({
        success: false,
        error: 'User không tồn tại'
      }, { status: 404 });
    }

    // Don't allow deleting admin
    if (existing.username === 'admin') {
      return NextResponse.json({
        success: false,
        error: 'Không thể xóa tài khoản admin'
      }, { status: 400 });
    }

    await queryTongHop('DELETE FROM "TH_Users" WHERE id = $1', [id]);

    return NextResponse.json({
      success: true,
      message: 'Xóa user thành công'
    });

  } catch (error) {
    console.error('[TH Users] DELETE Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
