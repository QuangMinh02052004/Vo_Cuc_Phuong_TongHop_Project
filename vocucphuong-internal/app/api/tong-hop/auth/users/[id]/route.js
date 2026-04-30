import { queryTongHop, queryOneTongHop } from '../../../../../../lib/database';
import { requirePerm } from '../../../../../../lib/auth-helper';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

export const dynamic = 'force-dynamic';

// ===========================================
// API: User by ID
// ===========================================
// GET /api/tong-hop/auth/users/[id] - Lấy user theo ID
// PUT /api/tong-hop/auth/users/[id] - Cập nhật user
// DELETE /api/tong-hop/auth/users/[id] - Xóa user

async function ensureTongHopPermColumns() {
  await queryTongHop(`ALTER TABLE "TH_Users" ADD COLUMN IF NOT EXISTS "permissions" JSONB`);
}

export async function GET(request, { params }) {
  try {
    const gate = requirePerm(request, 'users.manage');
    if (gate.response) return gate.response;
    await ensureTongHopPermColumns();
    const { id } = await params;

    const user = await queryOneTongHop(`
      SELECT id, username, "fullName", email, phone, role, permissions, active as "isActive", "createdAt"
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
    const gate = requirePerm(request, 'users.manage');
    if (gate.response) return gate.response;
    await ensureTongHopPermColumns();
    const { id } = await params;
    const body = await request.json();
    const { fullName, email, phone, role, isActive, password, permissions } = body;

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

    const permsJson = JSON.stringify(Array.isArray(permissions) ? permissions : []);

    // Build update query
    let updateQuery = `
      UPDATE "TH_Users"
      SET "fullName" = $1, email = $2, phone = $3, role = $4, active = $5, permissions = $6::jsonb
    `;
    let updateParams = [fullName, email || null, phone || null, role || 'user', isActive !== false, permsJson];

    // If password is provided, update it
    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      updateQuery += `, password = $7`;
      updateParams.push(hashedPassword);
    }

    const paramIndex = updateParams.length + 1;
    updateQuery += ` WHERE id = $${paramIndex} RETURNING id, username, "fullName", email, phone, role, permissions, active as "isActive"`;
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
    const gate = requirePerm(request, 'users.manage');
    if (gate.response) return gate.response;
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
