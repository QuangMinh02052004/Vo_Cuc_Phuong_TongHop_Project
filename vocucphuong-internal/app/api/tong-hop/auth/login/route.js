import { queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export const dynamic = 'force-dynamic';

const JWT_SECRET = process.env.JWT_SECRET || 'vocucphuong-secret-key-2025';

export async function POST(request) {
  try {
    const body = await request.json();
    const { username, password } = body;

    if (!username || !password) {
      return NextResponse.json({
        success: false,
        error: 'Vui lòng nhập tên đăng nhập và mật khẩu'
      }, { status: 400 });
    }

    // Tìm user
    const user = await queryOneTongHop(
      'SELECT * FROM "TH_Users" WHERE username = $1 AND active = true',
      [username]
    );

    if (!user) {
      return NextResponse.json({
        success: false,
        error: 'Tên đăng nhập hoặc mật khẩu không đúng'
      }, { status: 401 });
    }

    // Kiểm tra password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      return NextResponse.json({
        success: false,
        error: 'Tên đăng nhập hoặc mật khẩu không đúng'
      }, { status: 401 });
    }

    // Tạo JWT token
    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        role: user.role
      },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Trả về user info (không có password)
    const userData = {
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      role: user.role
    };

    return NextResponse.json({
      success: true,
      token,
      user: userData
    });

  } catch (error) {
    console.error('Login error:', error);
    return NextResponse.json({
      success: false,
      error: 'Đã xảy ra lỗi khi đăng nhập'
    }, { status: 500 });
  }
}
