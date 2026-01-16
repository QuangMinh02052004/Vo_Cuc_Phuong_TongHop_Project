import { queryTongHop } from '../../../../../../lib/database';
import { NextResponse } from 'next/server';

export async function GET(request, { params }) {
  try {
    const bookings = await queryTongHop(
      'SELECT * FROM "TH_Bookings" WHERE "timeSlotId" = $1 ORDER BY "seatNumber"',
      [params.timeSlotId]
    );
    return NextResponse.json(bookings);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
