import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const q = (searchParams.get('q') || '').trim();
    const limit = Math.min(parseInt(searchParams.get('limit') || '30', 10), 100);

    if (!q || q.length < 2) {
      return NextResponse.json({ results: [] });
    }

    const pattern = `%${q}%`;
    const results = await queryTongHop(`
      SELECT
        id, name, phone, "seatNumber", "timeSlot", "timeSlotId", date, route,
        "dropoffAddress", "dropoffMethod", note, amount, paid, "createdAt"
      FROM "TH_Bookings"
      WHERE name ILIKE $1 OR phone ILIKE $1
      ORDER BY "createdAt" DESC
      LIMIT $2
    `, [pattern, limit]);

    return NextResponse.json({ results });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
