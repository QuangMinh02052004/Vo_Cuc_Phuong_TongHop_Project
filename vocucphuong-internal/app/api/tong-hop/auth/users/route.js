import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

// ===========================================
// API: Users Management
// ===========================================
// GET /api/tong-hop/auth/users - Lấy danh sách users
// POST /api/tong-hop/auth/users - Tạo user mới (register)

export async function GET(request) {
  try {
    const users = await queryTongHop(`
      SELECT id, username, "fullName", email, phone, role, active as "isActive", "createdAt"
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
    const body = await request.json();
    const { username, password, fullName, email, phone, role } = body;

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

    // Create user
    const result = await queryOneTongHop(`
      INSERT INTO "TH_Users" (username, password, "fullName", email, phone, role, active)
      VALUES ($1, $2, $3, $4, $5, $6, true)
      RETURNING id, username, "fullName", email, phone, role, active as "isActive"
    `, [username, hashedPassword, fullName, email || null, phone || null, role || 'user']);

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
