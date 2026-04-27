import { queryTongHop, queryOneTongHop } from '../../../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// Webhook reverse-sync: DatVe → TongHop
// Cập nhật TH_Routes WHERE datveRouteId = :datveId
export async function PATCH(request, { params }) {
  try {
    await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "datveRouteId" TEXT`);
    const { datveId } = await params;
    const body = await request.json();
    const {
      fromStation, toStation, price, duration, busType, distance,
      operatingStart, operatingEnd, intervalMinutes, isActive,
    } = body;

    const existing = await queryOneTongHop('SELECT * FROM "TH_Routes" WHERE "datveRouteId" = $1', [datveId]);
    if (!existing) {
      return NextResponse.json({ ok: false, reason: 'no-th-row-linked' }, { status: 200 });
    }

    const updated = await queryOneTongHop(
      `UPDATE "TH_Routes" SET
        "fromStation" = COALESCE($1, "fromStation"),
        "toStation" = COALESCE($2, "toStation"),
        price = COALESCE($3, price),
        duration = COALESCE($4, duration),
        "busType" = COALESCE($5, "busType"),
        distance = COALESCE($6, distance),
        "operatingStart" = COALESCE($7, "operatingStart"),
        "operatingEnd" = COALESCE($8, "operatingEnd"),
        "intervalMinutes" = COALESCE($9, "intervalMinutes"),
        "isActive" = COALESCE($10, "isActive"),
        "updatedAt" = NOW()
      WHERE "datveRouteId" = $11 RETURNING *`,
      [fromStation, toStation, price, duration, busType, distance,
       operatingStart, operatingEnd, intervalMinutes, isActive, datveId]
    );
    return NextResponse.json({ ok: true, route: updated });
  } catch (error) {
    console.error('[reverse-sync routes by-datve] PATCH', error);
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}

export async function DELETE(_request, { params }) {
  try {
    const { datveId } = await params;
    await queryTongHop(
      'UPDATE "TH_Routes" SET "isActive" = false, "updatedAt" = NOW() WHERE "datveRouteId" = $1',
      [datveId]
    );
    return NextResponse.json({ ok: true });
  } catch (error) {
    console.error('[reverse-sync routes by-datve] DELETE', error);
    return NextResponse.json({ ok: false, error: error.message }, { status: 500 });
  }
}
