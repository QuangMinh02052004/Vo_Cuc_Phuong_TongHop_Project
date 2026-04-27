import { queryTongHop, queryOneTongHop, queryDatVe, queryOneDatVe } from '../../../../../../lib/database';
import { findOrCreateDatveRoute } from '../../../../../../lib/route-sync';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const body = await request.json();
    const {
      name, routeType, fromStation, toStation, price, duration, busType, seats,
      distance, operatingStart, operatingEnd, intervalMinutes, isActive,
    } = body;

    const existing = await queryOneTongHop('SELECT * FROM "TH_Routes" WHERE id = $1', [id]);
    if (!existing) {
      return NextResponse.json({ error: 'Tuyến không tồn tại' }, { status: 404 });
    }

    const updated = await queryOneTongHop(
      `UPDATE "TH_Routes" SET
        name = COALESCE($1, name),
        "routeType" = COALESCE($2, "routeType"),
        "fromStation" = COALESCE($3, "fromStation"),
        "toStation" = COALESCE($4, "toStation"),
        price = COALESCE($5, price),
        duration = COALESCE($6, duration),
        "busType" = COALESCE($7, "busType"),
        seats = COALESCE($8, seats),
        distance = COALESCE($9, distance),
        "operatingStart" = COALESCE($10, "operatingStart"),
        "operatingEnd" = COALESCE($11, "operatingEnd"),
        "intervalMinutes" = COALESCE($12, "intervalMinutes"),
        "isActive" = COALESCE($13, "isActive"),
        "updatedAt" = NOW()
      WHERE id = $14 RETURNING *`,
      [name, routeType, fromStation, toStation, price, duration, busType, seats,
       distance, operatingStart, operatingEnd, intervalMinutes, isActive, id]
    );

    let datveRouteId = updated.datveRouteId || existing.datveRouteId;
    let datveSynced = false;
    let datveError = null;
    let autoLinked = false;

    if (!datveRouteId) {
      try {
        const result = await findOrCreateDatveRoute(updated);
        datveRouteId = result.id;
        autoLinked = true;
        await queryTongHop('UPDATE "TH_Routes" SET "datveRouteId" = $1 WHERE id = $2', [datveRouteId, id]);
      } catch (err) {
        datveError = 'auto-link failed: ' + err.message;
      }
    }

    if (datveRouteId) {
      try {
        await queryDatVe(
          `UPDATE routes SET
            origin = COALESCE($1, origin),
            destination = COALESCE($2, destination),
            price = COALESCE($3, price),
            duration = COALESCE($4, duration),
            bus_type = COALESCE($5, bus_type),
            distance = COALESCE($6, distance),
            operating_start = COALESCE($7, operating_start),
            operating_end = COALESCE($8, operating_end),
            interval_minutes = COALESCE($9, interval_minutes),
            is_active = COALESCE($10, is_active),
            updated_at = NOW()
          WHERE id = $11`,
          [fromStation, toStation, price, duration, busType, distance, operatingStart, operatingEnd,
           intervalMinutes, isActive, datveRouteId]
        );
        datveSynced = true;
      } catch (err) {
        datveError = err.message;
      }
    }

    return NextResponse.json({ route: { ...updated, datveRouteId }, datveSynced, autoLinked, datveError });
  } catch (error) {
    console.error('[admin/sync/routes/:id] PUT', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  try {
    const { id } = await params;
    const existing = await queryOneTongHop('SELECT * FROM "TH_Routes" WHERE id = $1', [id]);
    if (!existing) {
      return NextResponse.json({ error: 'Tuyến không tồn tại' }, { status: 404 });
    }

    let datveRouteId = existing.datveRouteId;
    if (!datveRouteId) {
      try {
        const result = await findOrCreateDatveRoute(existing);
        datveRouteId = result.id;
      } catch {}
    }

    let datveSynced = false;
    let datveError = null;
    if (datveRouteId) {
      try {
        await queryDatVe(
          'UPDATE routes SET is_active = false, updated_at = NOW() WHERE id = $1',
          [datveRouteId]
        );
        datveSynced = true;
      } catch (err) {
        datveError = err.message;
      }
    }

    await queryTongHop('DELETE FROM "TH_Routes" WHERE id = $1', [id]);

    return NextResponse.json({ success: true, datveSynced, datveError });
  } catch (error) {
    console.error('[admin/sync/routes/:id] DELETE', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
