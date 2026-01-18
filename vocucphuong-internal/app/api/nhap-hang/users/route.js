import { queryNhapHang, queryOneNhapHang } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: NH_Users - Quản lý tài khoản
// ===========================================
// GET /api/nhap-hang/users - Lấy tất cả users
// POST /api/nhap-hang/users - Tạo user mới

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const activeOnly = searchParams.get('active') !== 'false';

    let query = `
      SELECT id, username, "fullName", phone, role, station, active, "createdAt", "updatedAt"
      FROM "NH_Users"
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
    console.error('[NH_Users] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const body = await request.json();
    const { username, password, fullName, phone, role, station } = body;

    if (!username || !password || !fullName) {
      return NextResponse.json({
        success: false,
        error: 'username, password và fullName là bắt buộc'
      }, { status: 400 });
    }

    const result = await queryOneNhapHang(`
      INSERT INTO "NH_Users" (username, password, "fullName", phone, role, station, active)
      VALUES ($1, $2, $3, $4, $5, $6, true)
      RETURNING id, username, "fullName", phone, role, station, active, "createdAt"
    `, [username, password, fullName, phone || null, role || 'employee', station || null]);

    return NextResponse.json({
      success: true,
      data: result,
      message: 'User created successfully'
    });

  } catch (error) {
    console.error('[NH_Users] POST Error:', error);

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
