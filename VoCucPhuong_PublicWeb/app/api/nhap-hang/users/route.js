import { queryNhapHang, queryOneNhapHang } from '../../../../lib/database';
import { requirePerm } from '../../../../lib/auth-helper';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// ===========================================
// API: Users - Quản lý tài khoản
// ===========================================
// GET /api/nhap-hang/users - Lấy tất cả users
// POST /api/nhap-hang/users - Tạo user mới

async function ensurePermissionColumns() {
  await queryNhapHang(`ALTER TABLE "Users" ADD COLUMN IF NOT EXISTS "permissions" JSONB`);
  await queryNhapHang(`ALTER TABLE "Users" ADD COLUMN IF NOT EXISTS "scope" TEXT`);
}

export async function GET(request) {
  try {
    const gate = requirePerm(request, 'users.manage');
    if (gate.response) return gate.response;

    await ensurePermissionColumns();
    const { searchParams } = new URL(request.url);
    const activeOnly = searchParams.get('active') !== 'false';

    let query = `
      SELECT id, username, "fullName", phone, role, station, permissions, scope, active, "createdAt", "updatedAt"
      FROM "Users"
    `;
    const params = [];

    if (activeOnly) {
      query += ' WHERE active = true';
    }

    query += ' ORDER BY "createdAt" DESC';

    const users = await queryNhapHang(query, params);

    return NextResponse.json({
      success: true,
      data: users,
      count: users.length
    });

  } catch (error) {
    console.error('[Users] GET Error:', error);
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

    await ensurePermissionColumns();
    const body = await request.json();
    const { username, password, fullName, phone, role, station, permissions, scope } = body;

    if (!username || !password || !fullName) {
      return NextResponse.json({
        success: false,
        error: 'username, password và fullName là bắt buộc'
      }, { status: 400 });
    }

    const permsJson = JSON.stringify(Array.isArray(permissions) ? permissions : []);
    const scopeValue = scope === 'all_stations' ? 'all_stations' : 'own_station';

    const result = await queryOneNhapHang(`
      INSERT INTO "Users" (username, password, "fullName", phone, role, station, permissions, scope, active)
      VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8, true)
      RETURNING id, username, "fullName", phone, role, station, permissions, scope, active, "createdAt"
    `, [username, password, fullName, phone || null, role || 'employee', station || null, permsJson, scopeValue]);

    return NextResponse.json({
      success: true,
      data: result,
      message: 'User created successfully'
    });

  } catch (error) {
    console.error('[Users] POST Error:', error);

    if (error.code === '23505') {
      return NextResponse.json({
        success: false,
        error: 'Username đã tồn tại'
      }, { status: 409 });
    }

    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
