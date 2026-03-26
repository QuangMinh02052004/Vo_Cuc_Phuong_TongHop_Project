import { queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET /api/tong-hop/routes - Lấy danh sách tuyến đường
export async function GET() {
  try {
    const routes = await queryTongHop(`
      SELECT * FROM "TH_Routes" ORDER BY name ASC
    `);

    return NextResponse.json(routes);
  } catch (error) {
    console.error('[Routes] GET Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

// POST /api/tong-hop/routes - Tạo tuyến đường mới
export async function POST(request) {
  try {
    const body = await request.json();
    const { name, routeType, fromStation, toStation, price, duration, busType, seats, distance, operatingStart, operatingEnd, intervalMinutes } = body;

    if (!name) {
      return NextResponse.json({ success: false, error: 'Tên tuyến là bắt buộc' }, { status: 400 });
    }

    // Check duplicate
    const existing = await queryOneTongHop(
      'SELECT id FROM "TH_Routes" WHERE name = $1', [name]
    );
    if (existing) {
      return NextResponse.json({ success: false, error: 'Tuyến đường đã tồn tại' }, { status: 400 });
    }

    const result = await queryOneTongHop(`
      INSERT INTO "TH_Routes" (name, "routeType", "fromStation", "toStation", price, duration, "busType", seats, distance, "operatingStart", "operatingEnd", "intervalMinutes")
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
      RETURNING *
    `, [name, routeType || 'quoc_lo', fromStation || '', toStation || '', price || 0, duration || '', busType || 'Ghế ngồi', seats || 28, distance || '', operatingStart || '05:30', operatingEnd || '20:00', intervalMinutes || 30]);

    return NextResponse.json({ success: true, route: result }, { status: 201 });
  } catch (error) {
    console.error('[Routes] POST Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
