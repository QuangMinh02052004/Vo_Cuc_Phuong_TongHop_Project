import { queryNhapHang, queryOneNhapHang } from '../../../../lib/database';
import { NextResponse } from 'next/server';

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

    // Tìm user theo username
    const user = await queryOneNhapHang(`
      SELECT id, username, password, "fullName", phone, role, station, active
      FROM "NH_Users"
      WHERE username = $1
    `, [username]);

    if (!user) {
      return NextResponse.json({
        success: false,
        error: 'Tài khoản không tồn tại'
      }, { status: 401 });
    }

    // Kiểm tra password (plain text comparison - should use bcrypt in production)
    if (user.password !== password) {
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

    // Trả về thông tin user (không có password)
    const { password: _, ...userWithoutPassword } = user;

    return NextResponse.json({
      success: true,
      message: 'Đăng nhập thành công',
      user: userWithoutPassword
    });

  } catch (error) {
    console.error('[NH_Auth] POST Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
