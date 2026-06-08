import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

const LOCK_DURATION_MINUTES = 10;

export async function GET(request) {
  try {
    // Clean expired locks
    await queryTongHop('DELETE FROM "TH_SeatLocks" WHERE "expiresAt" < NOW()');

    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const route = searchParams.get('route');

    let sqlQuery = 'SELECT * FROM "TH_SeatLocks" WHERE "expiresAt" > NOW()';
    const params = [];
    let paramIndex = 1;

    if (date) {
      sqlQuery += ` AND date = $${paramIndex}`;
      params.push(date);
      paramIndex++;
    }

    if (route) {
      sqlQuery += ` AND route = $${paramIndex}`;
      params.push(route);
      paramIndex++;
    }

    sqlQuery += ' ORDER BY "lockedAt" DESC';
    const locks = await queryTongHop(sqlQuery, params);

    return NextResponse.json(locks);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const { timeSlotId, seatNumber, lockedBy, lockedByUserId, date, route } = await request.json();

    if (!timeSlotId || !seatNumber || !lockedBy || !date || !route) {
      return NextResponse.json({
        error: 'Thiếu thông tin bắt buộc',
        required: ['timeSlotId', 'seatNumber', 'lockedBy', 'date', 'route']
      }, { status: 400 });
    }

    // Clean expired locks
    await queryTongHop('DELETE FROM "TH_SeatLocks" WHERE "expiresAt" < NOW()');

    // Check existing lock
    const existing = await queryTongHop(`
      SELECT * FROM "TH_SeatLocks"
      WHERE "timeSlotId" = $1 AND "seatNumber" = $2 AND date = $3 AND route = $4 AND "expiresAt" > NOW()
    `, [timeSlotId, seatNumber, date, route]);

    if (existing.length > 0) {
      const existingLock = existing[0];
      if (existingLock.lockedBy === lockedBy) {
        // Extend lock
        const newExpiresAt = new Date(Date.now() + LOCK_DURATION_MINUTES * 60 * 1000);
        await queryTongHop('UPDATE "TH_SeatLocks" SET "expiresAt" = $1 WHERE id = $2', [newExpiresAt, existingLock.id]);
        return NextResponse.json({
          success: true,
          message: 'Đã gia hạn lock',
          lock: { ...existingLock, expiresAt: newExpiresAt }
        });
      }
      return NextResponse.json({
        error: 'Ghế đã bị khóa',
        lockedBy: existingLock.lockedBy,
        expiresAt: existingLock.expiresAt
      }, { status: 409 });
    }

    // Create new lock
    const expiresAt = new Date(Date.now() + LOCK_DURATION_MINUTES * 60 * 1000);
    const result = await queryTongHop(`
      INSERT INTO "TH_SeatLocks" ("timeSlotId", "seatNumber", "lockedBy", "lockedByUserId", "expiresAt", date, route)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `, [timeSlotId, seatNumber, lockedBy, lockedByUserId || null, expiresAt, date, route]);

    return NextResponse.json({
      success: true,
      message: `Đã khóa ghế ${seatNumber} trong ${LOCK_DURATION_MINUTES} phút`,
      lock: result[0]
    }, { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(request) {
  try {
    const { searchParams } = new URL(request.url);
    const clearAll = searchParams.get('clearAll');

    if (clearAll === 'true') {
      const result = await queryTongHop('DELETE FROM "TH_SeatLocks" RETURNING id');
      return NextResponse.json({ success: true, message: `Đã xóa ${result.length} locks` });
    }

    return NextResponse.json({ error: 'Thiếu tham số' }, { status: 400 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
