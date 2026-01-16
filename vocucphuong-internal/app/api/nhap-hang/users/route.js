import { query, queryOne } from '../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

export async function GET() {
  try {
    const users = await query('SELECT id, username, "fullName", role, station, active, "createdAt" FROM "NhapHangUsers" ORDER BY id');
    return NextResponse.json({ success: true, users });
  } catch (error) {
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const body = await request.json();
    const { username, password, fullName, role, station } = body;

    if (!username || !password || !fullName) {
      return NextResponse.json({
        success: false,
        message: 'Username, password và fullName là bắt buộc'
      }, { status: 400 });
    }

    // Check if username exists
    const existingUser = await queryOne('SELECT id FROM "NhapHangUsers" WHERE username = $1', [username]);
    if (existingUser) {
      return NextResponse.json({
        success: false,
        message: 'Tên đăng nhập đã tồn tại'
      }, { status: 400 });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const id = `USER${Date.now().toString().slice(-6)}`;

    const result = await query(`
      INSERT INTO "NhapHangUsers" (id, username, password, "fullName", role, station, active)
      VALUES ($1, $2, $3, $4, $5, $6, true)
      RETURNING id, username, "fullName", role, station, active
    `, [id, username, hashedPassword, fullName, role || 'employee', station || null]);

    return NextResponse.json({ success: true, user: result[0] });
  } catch (error) {
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}
