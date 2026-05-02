import { queryTongHop } from '../../../../../lib/database';
import { authPartner } from '../../../../../lib/partner-auth';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET /api/public/v1/timeslots?date=DD-MM-YYYY&route=...
// Trả về danh sách khung giờ kèm số ghế còn trống
export async function GET(request) {
  const auth = await authPartner(request, 'read');
  if (!auth.ok) return NextResponse.json({ error: auth.error }, { status: auth.status });

  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const route = searchParams.get('route');
    if (!date) return NextResponse.json({ error: 'Missing date (DD-MM-YYYY)' }, { status: 400 });

    const slots = await queryTongHop(`
      SELECT id, route, "timeSlot", "vehiclePlate", "driverName"
      FROM "TH_TimeSlots"
      WHERE date = $1 ${route ? 'AND route = $2' : ''}
      ORDER BY route, "timeSlot"
    `, route ? [date, route] : [date]);

    if (slots.length === 0) return NextResponse.json({ timeslots: [] });

    const ids = slots.map(s => s.id);
    const bookings = await queryTongHop(`
      SELECT "timeSlotId", COUNT(*)::int AS taken
      FROM "TH_Bookings"
      WHERE "timeSlotId" = ANY($1::int[]) AND status != 'cancelled'
      GROUP BY "timeSlotId"
    `, [ids]);
    const takenMap = new Map(bookings.map(b => [b.timeSlotId, b.taken]));

    const result = slots.map(s => ({
      id: s.id,
      route: s.route,
      timeSlot: s.timeSlot,
      vehiclePlate: s.vehiclePlate,
      driverName: s.driverName,
      seatsTotal: 28,
      seatsTaken: takenMap.get(s.id) || 0,
      seatsAvailable: 28 - (takenMap.get(s.id) || 0),
    }));

    return NextResponse.json({ timeslots: result });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
