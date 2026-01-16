import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export async function GET(request) {
  try {
    // Clean expired locks first
    await queryTongHop('DELETE FROM "TH_SeatLocks" WHERE "expiresAt" < NOW()');

    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const route = searchParams.get('route');

    if (!date || !route) {
      return NextResponse.json({ error: 'Missing date or route parameter' }, { status: 400 });
    }

    const locks = await queryTongHop(`
      SELECT * FROM "TH_SeatLocks"
      WHERE date = $1 AND route = $2 AND "expiresAt" > NOW()
      ORDER BY "lockedAt" DESC
    `, [date, route]);

    return NextResponse.json(locks);
  } catch (error) {
    console.error('Error getting seat locks:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
