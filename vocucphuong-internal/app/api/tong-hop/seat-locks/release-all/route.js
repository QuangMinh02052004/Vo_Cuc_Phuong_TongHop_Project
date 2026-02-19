import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function POST(request) {
  try {
    let lockedBy;

    // Handle both JSON body and text body (for sendBeacon)
    const contentType = request.headers.get('content-type') || '';

    if (contentType.includes('application/json')) {
      const body = await request.json();
      lockedBy = body.lockedBy;
    } else {
      // sendBeacon sends as text/plain by default
      const text = await request.text();
      try {
        const parsed = JSON.parse(text);
        lockedBy = parsed.lockedBy;
      } catch {
        lockedBy = text;
      }
    }

    if (!lockedBy) {
      return NextResponse.json({ error: 'Missing lockedBy parameter' }, { status: 400 });
    }

    const result = await queryTongHop(`
      DELETE FROM "TH_SeatLocks"
      WHERE "lockedBy" = $1
      RETURNING id
    `, [lockedBy]);

    return NextResponse.json({
      success: true,
      message: `Released ${result.length} locks for user ${lockedBy}`,
      deletedCount: result.length
    });
  } catch (error) {
    console.error('Error releasing all seat locks:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
