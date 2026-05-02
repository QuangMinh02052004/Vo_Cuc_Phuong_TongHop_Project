import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { authPartner } from '../../../../../lib/partner-auth';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// POST /api/public/v1/bookings — create booking on behalf of partner
// Body: { timeSlotId, seatNumber, name, phone, dropoffMethod?, dropoffAddress?, note?, amount }
export async function POST(request) {
  const auth = await authPartner(request, 'write');
  if (!auth.ok) return NextResponse.json({ error: auth.error }, { status: auth.status });

  try {
    const body = await request.json();
    const { timeSlotId, seatNumber, name, phone, dropoffMethod, dropoffAddress, note, amount } = body;
    if (!timeSlotId || !seatNumber || !name || !phone) {
      return NextResponse.json({ error: 'Missing required: timeSlotId, seatNumber, name, phone' }, { status: 400 });
    }

    // Lookup timeslot
    const slot = await queryOneTongHop(`SELECT * FROM "TH_TimeSlots" WHERE id = $1`, [timeSlotId]);
    if (!slot) return NextResponse.json({ error: 'TimeSlot not found' }, { status: 404 });

    // Check seat available
    const taken = await queryOneTongHop(
      `SELECT id FROM "TH_Bookings" WHERE "timeSlotId" = $1 AND "seatNumber" = $2 AND status != 'cancelled'`,
      [timeSlotId, seatNumber]
    );
    if (taken) return NextResponse.json({ error: `Seat ${seatNumber} already taken` }, { status: 409 });

    const result = await queryOneTongHop(`
      INSERT INTO "TH_Bookings"
        (name, phone, "seatNumber", "timeSlotId", "timeSlot", route, date,
         "dropoffMethod", "dropoffAddress", note, amount, paid, status, "createdBy")
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,'active',$13)
      RETURNING id, "createdAt"
    `, [
      name, phone, seatNumber, timeSlotId, slot.timeSlot, slot.route, slot.date,
      dropoffMethod || 'Tại bến', dropoffAddress || '', note || '',
      Number(amount) || 0, 0, `partner:${auth.partner.name}`,
    ]);

    return NextResponse.json({
      ok: true,
      booking: {
        id: result.id,
        timeSlotId,
        seatNumber,
        name,
        phone,
        route: slot.route,
        date: slot.date,
        timeSlot: slot.timeSlot,
        amount: Number(amount) || 0,
        createdAt: result.createdAt,
      }
    }, { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

// GET /api/public/v1/bookings/:id — không support, dùng query bằng phone
// GET /api/public/v1/bookings?phone=... — list partner-created bookings for that phone
export async function GET(request) {
  const auth = await authPartner(request, 'read');
  if (!auth.ok) return NextResponse.json({ error: auth.error }, { status: auth.status });

  try {
    const { searchParams } = new URL(request.url);
    const phone = searchParams.get('phone');
    const id = searchParams.get('id');
    if (!phone && !id) return NextResponse.json({ error: 'Missing phone or id' }, { status: 400 });

    const rows = id
      ? await queryTongHop(`SELECT id, name, phone, "seatNumber", "timeSlot", route, date, amount, paid, status FROM "TH_Bookings" WHERE id = $1`, [id])
      : await queryTongHop(`SELECT id, name, phone, "seatNumber", "timeSlot", route, date, amount, paid, status FROM "TH_Bookings" WHERE phone = $1 ORDER BY "createdAt" DESC LIMIT 100`, [phone]);

    return NextResponse.json({ bookings: rows });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
