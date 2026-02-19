import { queryNhapHang, queryOneNhapHang } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: Stations - Danh sách bến xe
// ===========================================
// GET /api/nhap-hang/stations - Lấy tất cả stations
// POST /api/nhap-hang/stations - Thêm station mới

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const activeOnly = searchParams.get('active') !== 'false';

    let query = 'SELECT * FROM "Stations"';
    const params = [];

    if (activeOnly) {
      query += ' WHERE "isActive" = true';
    }

    query += ' ORDER BY code ASC';

    const stations = await queryNhapHang(query, params);

    return NextResponse.json({
      success: true,
      data: stations,
      count: stations.length
    });

  } catch (error) {
    console.error('[Stations] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const body = await request.json();
    const { code, name, address, phone, region } = body;

    if (!code || !name) {
      return NextResponse.json({
        success: false,
        error: 'code và name là bắt buộc'
      }, { status: 400 });
    }

    const fullName = `${code} - ${name}`;

    const result = await queryOneNhapHang(`
      INSERT INTO "Stations" (code, name, "fullName", address, phone, region, "isActive")
      VALUES ($1, $2, $3, $4, $5, $6, true)
      RETURNING *
    `, [code, name, fullName, address || null, phone || null, region || null]);

    return NextResponse.json({
      success: true,
      data: result,
      message: 'Station created successfully'
    });

  } catch (error) {
    console.error('[Stations] POST Error:', error);

    if (error.code === '23505') { // Unique violation
      return NextResponse.json({
        success: false,
        error: 'Station code đã tồn tại'
      }, { status: 409 });
    }

    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
