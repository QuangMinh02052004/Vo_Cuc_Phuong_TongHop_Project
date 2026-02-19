import { queryNhapHang, queryOneNhapHang } from '../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'vocucphuong-secret-key-2024';

// ===========================================
// API: Authentication cho NhapHang
// ===========================================
// POST /api/nhap-hang/auth - Đăng nhập

export async function POST(request) {
  try {
    const body = await request.json();
    const { username, password } = body;

    if (!username || !password) {
      return NextResponse.json({
        success: false,
        error: 'username và password là bắt buộc'
      }, { status: 400 });
    }

    // Tìm user theo username từ bảng Users
    const user = await queryOneNhapHang(`
      SELECT id, username, password, "fullName", phone, role, station, active
      FROM "Users"
      WHERE username = $1 AND active = true
    `, [username]);

    if (!user) {
      return NextResponse.json({
        success: false,
        error: 'Tài khoản không tồn tại'
      }, { status: 401 });
    }

    // So sánh password: hỗ trợ cả bcrypt hash và plain text
    let isMatch = false;
    if (user.password.startsWith('$2')) {
      isMatch = await bcrypt.compare(password, user.password);
    } else {
      isMatch = (user.password === password);
    }

    if (!isMatch) {
      return NextResponse.json({
        success: false,
        error: 'Mật khẩu không đúng'
      }, { status: 401 });
    }

    // Kiểm tra active
    if (!user.active) {
      return NextResponse.json({
        success: false,
        error: 'Tài khoản đã bị khóa'
      }, { status: 403 });
    }

    // Tạo JWT token
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

    // Trả về thông tin user (không có password)
    const { password: _, ...userWithoutPassword } = user;

    return NextResponse.json({
      success: true,
      message: 'Đăng nhập thành công',
      token,
      user: userWithoutPassword
    });

  } catch (error) {
    console.error('[Auth] POST Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
