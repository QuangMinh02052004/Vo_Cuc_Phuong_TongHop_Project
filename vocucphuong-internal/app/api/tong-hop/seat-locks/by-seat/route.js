import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export async function DELETE(request) {
  try {
    const body = await request.json();
    const { timeSlotId, seatNumber, date, route, lockedBy } = body;

    if (!timeSlotId || !seatNumber || !date || !route) {
      return NextResponse.json({
        error: 'Missing required parameters',
        required: ['timeSlotId', 'seatNumber', 'date', 'route']
      }, { status: 400 });
    }

    // Build query based on whether lockedBy is provided
    let result;
    if (lockedBy) {
      // Only delete if locked by the same user
      result = await queryTongHop(`
        DELETE FROM "TH_SeatLocks"
        WHERE "timeSlotId" = $1 AND "seatNumber" = $2 AND date = $3 AND route = $4 AND "lockedBy" = $5
        RETURNING id
      `, [timeSlotId, seatNumber, date, route, lockedBy]);
    } else {
      // Delete any lock for this seat
      result = await queryTongHop(`
        DELETE FROM "TH_SeatLocks"
        WHERE "timeSlotId" = $1 AND "seatNumber" = $2 AND date = $3 AND route = $4
        RETURNING id
      `, [timeSlotId, seatNumber, date, route]);
    }

    if (result.length === 0) {
      return NextResponse.json({
        success: true,
        message: 'No lock found to delete'
      });
    }

    return NextResponse.json({
      success: true,
      message: `Deleted lock for seat ${seatNumber}`,
      deletedIds: result.map(r => r.id)
    });
  } catch (error) {
    console.error('Error deleting seat lock:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
