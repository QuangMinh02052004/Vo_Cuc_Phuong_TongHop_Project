import { queryOneNhapHang } from '../../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export const dynamic = 'force-dynamic';

const JWT_SECRET = process.env.JWT_SECRET || 'vocucphuong-secret-key-2024';

export async function POST(request) {
  try {
    const { username, password } = await request.json();

    if (!username || !password) {
      return NextResponse.json({
        success: false,
        message: 'Vui lòng nhập tên đăng nhập và mật khẩu!'
      }, { status: 400 });
    }

    const user = await queryOneNhapHang(
      'SELECT * FROM "Users" WHERE username = $1 AND active = true',
      [username]
    );

    if (!user) {
      return NextResponse.json({
        success: false,
        message: 'Tên đăng nhập không tồn tại!'
      }, { status: 401 });
    }

    // So sánh password: hỗ trợ cả bcrypt hash và plain text (tạm thời)
    let isMatch = false;
    if (user.password.startsWith('$2')) {
      // Password đã được hash bằng bcrypt
      isMatch = await bcrypt.compare(password, user.password);
    } else {
      // Plain text password (legacy) - so sánh trực tiếp
      isMatch = (user.password === password);
    }

    if (!isMatch) {
      return NextResponse.json({
        success: false,
        message: 'Mật khẩu không chính xác!'
      }, { status: 401 });
    }

    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        role: user.role,
        station: user.station,
        fullName: user.fullName
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    return NextResponse.json({
      success: true,
      message: 'Đăng nhập thành công!',
      token,
      user: {
        id: user.id,
        username: user.username,
        fullName: user.fullName,
        role: user.role,
        station: user.station
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}
