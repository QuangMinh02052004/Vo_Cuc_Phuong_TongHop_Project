import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// PUT /api/tong-hop/routes/[id] - Cập nhật tuyến đường
export async function PUT(request, { params }) {
  try {
    const { id } = await params;
    const body = await request.json();
    const { name, routeType, fromStation, toStation, price, duration, busType, seats, distance, operatingStart, operatingEnd, intervalMinutes, isActive } = body;

    const existing = await queryOneTongHop('SELECT * FROM "TH_Routes" WHERE id = $1', [id]);
    if (!existing) {
      return NextResponse.json({ success: false, error: 'Tuyến không tồn tại' }, { status: 404 });
    }

    const result = await queryOneTongHop(`
      UPDATE "TH_Routes" SET
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
      WHERE id = $14 RETURNING *
    `, [name, routeType, fromStation, toStation, price, duration, busType, seats, distance, operatingStart, operatingEnd, intervalMinutes, isActive, id]);

    return NextResponse.json({ success: true, route: result });
  } catch (error) {
    console.error('[Routes] PUT Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

// DELETE /api/tong-hop/routes/[id] - Xóa tuyến đường
export async function DELETE(request, { params }) {
  try {
    const { id } = await params;

    await queryTongHop('DELETE FROM "TH_Routes" WHERE id = $1', [id]);

    return NextResponse.json({ success: true, message: 'Đã xóa tuyến đường' });
  } catch (error) {
    console.error('[Routes] DELETE Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
