import { queryTongHop, queryOneTongHop, queryDatVe, queryOneDatVe } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

async function ensureDatveRouteIdColumn() {
  await queryTongHop(`
    ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "datveRouteId" TEXT
  `);
}

export async function GET() {
  try {
    await ensureDatveRouteIdColumn();
    const rows = await queryTongHop('SELECT * FROM "TH_Routes" ORDER BY name ASC');
    return NextResponse.json({ routes: rows });
  } catch (error) {
    console.error('[admin/sync/routes] GET', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    await ensureDatveRouteIdColumn();
    const body = await request.json();
    const {
      name, routeType = 'quoc_lo', fromStation = '', toStation = '',
      price = 0, duration = '', busType = 'Ghế ngồi', seats = 28,
      distance = '', operatingStart = '05:30', operatingEnd = '20:00',
      intervalMinutes = 30, isActive = true,
    } = body;

    if (!name || !fromStation || !toStation) {
      return NextResponse.json({ error: 'Thiếu name/fromStation/toStation' }, { status: 400 });
    }

    const dup = await queryOneTongHop('SELECT id FROM "TH_Routes" WHERE name = $1', [name]);
    if (dup) {
      return NextResponse.json({ error: 'Tuyến đã tồn tại' }, { status: 409 });
    }

    let datveRouteId = null;
    let datveError = null;
    try {
      const datveRow = await queryOneDatVe(
        `INSERT INTO routes (
          id, origin, destination, price, duration, bus_type, distance,
          operating_start, operating_end, interval_minutes, is_active, created_at, updated_at
        ) VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())
        RETURNING id`,
        [fromStation, toStation, price, duration, busType, distance || null, operatingStart, operatingEnd, intervalMinutes, isActive]
      );
      datveRouteId = datveRow?.id || null;
    } catch (err) {
      datveError = err.message;
    }

    const thRoute = await queryOneTongHop(
      `INSERT INTO "TH_Routes"
        (name, "routeType", "fromStation", "toStation", price, duration, "busType", seats, distance,
         "operatingStart", "operatingEnd", "intervalMinutes", "isActive", "datveRouteId")
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
       RETURNING *`,
      [name, routeType, fromStation, toStation, price, duration, busType, seats, distance,
       operatingStart, operatingEnd, intervalMinutes, isActive, datveRouteId]
    );

    return NextResponse.json({ route: thRoute, datveSynced: !!datveRouteId, datveError }, { status: 201 });
  } catch (error) {
    console.error('[admin/sync/routes] POST', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
