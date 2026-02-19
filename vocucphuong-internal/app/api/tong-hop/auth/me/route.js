import { queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';
import jwt from 'jsonwebtoken';

export const dynamic = 'force-dynamic';

const JWT_SECRET = process.env.JWT_SECRET || 'vocucphuong-secret-key-2025';

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

    // Lấy user từ database
    const user = await queryOneTongHop(
      'SELECT id, username, "fullName", role FROM "TH_Users" WHERE id = $1 AND active = true',
      [decoded.id]
    );

    if (!user) {
      return NextResponse.json({
        success: false,
        error: 'Không tìm thấy người dùng'
      }, { status: 404 });
    }

    return NextResponse.json(user);

  } catch (error) {
    console.error('Auth me error:', error);
    return NextResponse.json({
      success: false,
      error: 'Đã xảy ra lỗi'
    }, { status: 500 });
  }
}
