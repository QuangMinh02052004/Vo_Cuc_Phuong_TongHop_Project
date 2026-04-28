import { queryTongHop, queryOneTongHop, queryDatVe, queryOneDatVe } from '../../../../lib/database';
import { autoLinkAllUnlinked, autoLinkFromDatve } from '../../../../lib/route-sync';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "datveRouteId" TEXT`);
    await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "deletedAt" TIMESTAMP`);

    // Dọn dẹp: nếu có row active dùng chung datveRouteId với row đã soft-delete → là bản auto-tạo lại, soft-delete luôn
    await queryTongHop(`
      UPDATE "TH_Routes"
      SET "deletedAt" = NOW(), "isActive" = false, "updatedAt" = NOW()
      WHERE "deletedAt" IS NULL
        AND "datveRouteId" IS NOT NULL
        AND "datveRouteId" IN (
          SELECT "datveRouteId" FROM "TH_Routes"
          WHERE "datveRouteId" IS NOT NULL AND "deletedAt" IS NOT NULL
        )
    `);

    try { await autoLinkAllUnlinked(); } catch (err) { console.error('[tong-hop/routes] auto-link error:', err.message); }
    try { await autoLinkFromDatve(); } catch (err) { console.error('[tong-hop/routes] reverse auto-link error:', err.message); }
    const routes = await queryTongHop('SELECT * FROM "TH_Routes" WHERE "deletedAt" IS NULL ORDER BY name ASC');
    return NextResponse.json(routes);
  } catch (error) {
    console.error('[Routes] GET Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "datveRouteId" TEXT`);
    const body = await request.json();
    const {
      name, routeType = 'quoc_lo', fromStation = '', toStation = '',
      price = 0, duration = '', busType = 'Ghế ngồi', seats = 28,
      distance = '', operatingStart = '05:30', operatingEnd = '20:00',
      intervalMinutes = 30, isActive = true,
    } = body;

    if (!name) {
      return NextResponse.json({ success: false, error: 'Tên tuyến là bắt buộc' }, { status: 400 });
    }

    const dup = await queryOneTongHop('SELECT id FROM "TH_Routes" WHERE name = $1', [name]);
    if (dup) {
      return NextResponse.json({ success: false, error: 'Tuyến đường đã tồn tại' }, { status: 400 });
    }

    let datveRouteId = null;
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
      console.error('[tong-hop/routes] DatVe insert failed:', err.message);
    }

    const result = await queryOneTongHop(
      `INSERT INTO "TH_Routes"
        (name, "routeType", "fromStation", "toStation", price, duration, "busType", seats, distance,
         "operatingStart", "operatingEnd", "intervalMinutes", "isActive", "datveRouteId")
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)
       RETURNING *`,
      [name, routeType, fromStation, toStation, price, duration, busType, seats, distance,
       operatingStart, operatingEnd, intervalMinutes, isActive, datveRouteId]
    );

    return NextResponse.json({ success: true, route: result, datveSynced: !!datveRouteId }, { status: 201 });
  } catch (error) {
    console.error('[Routes] POST Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
