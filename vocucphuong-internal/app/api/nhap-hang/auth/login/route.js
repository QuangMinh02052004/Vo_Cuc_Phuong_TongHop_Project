import { queryNhapHang, queryOneNhapHang } from '../../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

export const dynamic = 'force-dynamic';

const JWT_SECRET = process.env.JWT_SECRET || 'vocucphuong-secret-key-2024';

async function ensurePermissionColumns() {
  try {
    await queryNhapHang(`ALTER TABLE "Users" ADD COLUMN IF NOT EXISTS "permissions" JSONB`);
    await queryNhapHang(`ALTER TABLE "Users" ADD COLUMN IF NOT EXISTS "scope" TEXT`);
  } catch (e) {
    console.warn('[Login] permission columns migration:', e.message);
  }
}

export async function POST(request) {
  try {
    await ensurePermissionColumns();
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

    // So sánh password: hỗ trợ cả bcrypt hash và plain text (legacy)
    let isMatch = false;
    let wasPlainText = false;
    if (user.password.startsWith('$2')) {
      isMatch = await bcrypt.compare(password, user.password);
    } else {
      // Plain text password (legacy)
      isMatch = (user.password === password);
      wasPlainText = isMatch;
    }

    if (!isMatch) {
      return NextResponse.json({
        success: false,
        message: 'Mật khẩu không chính xác!'
      }, { status: 401 });
    }

    // Opportunistic upgrade: nếu login plain-text thành công → hash và update DB
    if (wasPlainText) {
      try {
        const hashed = await bcrypt.hash(password, 10);
        await queryNhapHang('UPDATE "Users" SET password = $1 WHERE id = $2', [hashed, user.id]);
        console.log(`[Login] Rehashed plain password for user ${user.username}`);
      } catch (e) {
        console.warn('[Login] Rehash failed:', e.message);
      }
    }

    // Default permissions cho legacy user (chưa được set permissions)
    const ADMIN_PERMS = ['phongve.view','phongve.create','phongve.edit','phongve.cancel','kho.view','kho.edit','thongke.view','logs.view','users.manage'];
    const EMPLOYEE_PERMS = ['phongve.view','phongve.create','phongve.edit','kho.view','kho.edit','thongke.view'];

    let permissions = Array.isArray(user.permissions) ? user.permissions : [];
    if (permissions.length === 0) {
      permissions = user.role === 'admin' ? ADMIN_PERMS : EMPLOYEE_PERMS;
    }
    const scope = user.scope || (user.role === 'admin' ? 'all_stations' : 'own_station');

    const token = jwt.sign(
      {
        id: user.id,
        username: user.username,
        role: user.role,
        station: user.station,
        fullName: user.fullName,
        permissions,
        scope
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
        station: user.station,
        permissions,
        scope
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}
