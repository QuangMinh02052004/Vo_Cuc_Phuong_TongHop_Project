import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { requirePerm } from '../../../../../lib/auth-helper';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

export const dynamic = 'force-dynamic';

// ===========================================
// API: Users Management
// ===========================================
// GET /api/tong-hop/auth/users - Lấy danh sách users
// POST /api/tong-hop/auth/users - Tạo user mới (register)

async function ensureTongHopPermColumns() {
  await queryTongHop(`ALTER TABLE "TH_Users" ADD COLUMN IF NOT EXISTS "permissions" JSONB`);
}

export async function GET(request) {
  try {
    const gate = requirePerm(request, 'users.manage');
    if (gate.response) return gate.response;
    await ensureTongHopPermColumns();
    const users = await queryTongHop(`
      SELECT id, username, "fullName", email, phone, role, permissions, active as "isActive", "createdAt"
      FROM "TH_Users"
      ORDER BY id ASC
    `);

    return NextResponse.json(users);

  } catch (error) {
    console.error('[TH Users] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const gate = requirePerm(request, 'users.manage');
    if (gate.response) return gate.response;
    await ensureTongHopPermColumns();
    const body = await request.json();
    const { username, password, fullName, email, phone, role, permissions } = body;

    if (!username || !password || !fullName) {
      return NextResponse.json({
        success: false,
        error: 'Username, password và fullName là bắt buộc'
      }, { status: 400 });
    }

    // Check if username exists
    const existing = await queryOneTongHop(
      'SELECT id FROM "TH_Users" WHERE username = $1',
      [username]
    );

    if (existing) {
      return NextResponse.json({
        success: false,
        error: 'Username đã tồn tại'
      }, { status: 400 });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    const permsJson = JSON.stringify(Array.isArray(permissions) ? permissions : []);

    // Create user
    const result = await queryOneTongHop(`
      INSERT INTO "TH_Users" (username, password, "fullName", email, phone, role, permissions, active)
      VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, true)
      RETURNING id, username, "fullName", email, phone, role, permissions, active as "isActive"
    `, [username, hashedPassword, fullName, email || null, phone || null, role || 'user', permsJson]);

    return NextResponse.json({
      success: true,
      message: 'Tạo user thành công',
      user: result
    }, { status: 201 });

  } catch (error) {
    console.error('[TH Users] POST Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
