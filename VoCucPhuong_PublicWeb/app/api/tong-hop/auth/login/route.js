import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export const dynamic = 'force-dynamic';

const JWT_SECRET = process.env.JWT_SECRET || 'vocucphuong-secret-key-2025';

const TH_ADMIN_PERMS = [
  'phongve.view','phongve.create','phongve.edit','phongve.cancel',
  'kho.view','kho.edit','thongke.view','logs.view','users.manage',
  'tonghop.view','tonghop.edit','tonghop.cancel',
  'routes.manage','vehicles.manage','drivers.manage'
];
const TH_MANAGER_PERMS = [
  'tonghop.view','tonghop.edit','tonghop.cancel',
  'thongke.view','logs.view',
  'routes.manage','vehicles.manage','drivers.manage'
];
const TH_USER_PERMS = [
  'tonghop.view','tonghop.edit','thongke.view'
];

async function ensureTongHopPermColumns() {
  try {
    await queryTongHop(`ALTER TABLE "TH_Users" ADD COLUMN IF NOT EXISTS "permissions" JSONB`);
  } catch (e) {
    console.warn('[TH Login] permission columns migration:', e.message);
  }
}

export async function POST(request) {
  try {
    await ensureTongHopPermColumns();
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

    // So sánh password: hỗ trợ cả bcrypt hash và plain text (legacy)
    let isValidPassword = false;
    let wasPlainText = false;
    if (user.password && user.password.startsWith('$2')) {
      isValidPassword = await bcrypt.compare(password, user.password);
    } else {
      isValidPassword = (user.password === password);
      wasPlainText = isValidPassword;
    }

    if (!isValidPassword) {
      return NextResponse.json({
        success: false,
        error: 'Tên đăng nhập hoặc mật khẩu không đúng'
      }, { status: 401 });
    }

    // Opportunistic upgrade: nếu plain-text → hash và update DB
    if (wasPlainText) {
      try {
        const hashed = await bcrypt.hash(password, 10);
        await queryTongHop('UPDATE "TH_Users" SET password = $1 WHERE id = $2', [hashed, user.id]);
        console.log(`[TH Login] Rehashed plain password for user ${user.username}`);
      } catch (e) {
        console.warn('[TH Login] Rehash failed:', e.message);
      }
    }

    // Default permissions cho legacy user
    let permissions = Array.isArray(user.permissions) ? user.permissions : [];
    if (permissions.length === 0) {
      if (user.role === 'admin') permissions = TH_ADMIN_PERMS;
      else if (user.role === 'manager') permissions = TH_MANAGER_PERMS;
      else permissions = TH_USER_PERMS;
    }

    // Tạo JWT token (kèm permissions)
    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        role: user.role,
        fullName: user.fullName,
        permissions
      },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Trả về user info (không có password)
    const userData = {
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      role: user.role,
      permissions
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
