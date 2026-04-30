import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';
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
const TH_USER_PERMS = ['tonghop.view','tonghop.edit','thongke.view'];

async function ensureTongHopPermColumns() {
  try {
    await queryTongHop(`ALTER TABLE "TH_Users" ADD COLUMN IF NOT EXISTS "permissions" JSONB`);
  } catch (e) {
    console.warn('[TH /me] permission columns migration:', e.message);
  }
}

export async function GET(request) {
  try {
    // Lấy token từ header
    const authHeader = request.headers.get('authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return NextResponse.json({
        success: false,
        error: 'Không có token xác thực'
      }, { status: 401 });
    }

    const token = authHeader.substring(7);

    // Verify token
    let decoded;
    try {
      decoded = jwt.verify(token, JWT_SECRET);
    } catch (err) {
      return NextResponse.json({
        success: false,
        error: 'Token không hợp lệ hoặc đã hết hạn'
      }, { status: 401 });
    }

    await ensureTongHopPermColumns();

    // Lấy user từ database
    const user = await queryOneTongHop(
      'SELECT id, username, "fullName", role, permissions FROM "TH_Users" WHERE id = $1 AND active = true',
      [decoded.id]
    );

    if (!user) {
      return NextResponse.json({
        success: false,
        error: 'Không tìm thấy người dùng'
      }, { status: 404 });
    }

    // Default perms cho legacy user
    let permissions = Array.isArray(user.permissions) ? user.permissions : [];
    if (permissions.length === 0) {
      if (user.role === 'admin') permissions = TH_ADMIN_PERMS;
      else if (user.role === 'manager') permissions = TH_MANAGER_PERMS;
      else permissions = TH_USER_PERMS;
    }

    return NextResponse.json({
      id: user.id,
      username: user.username,
      fullName: user.fullName,
      role: user.role,
      permissions
    });

  } catch (error) {
    console.error('Auth me error:', error);
    return NextResponse.json({
      success: false,
      error: 'Đã xảy ra lỗi'
    }, { status: 500 });
  }
}
