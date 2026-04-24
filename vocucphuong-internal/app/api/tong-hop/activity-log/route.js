import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET - Lấy activity log theo ngày + route
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const route = searchParams.get('route');
    const limit = parseInt(searchParams.get('limit') || '50');

    let sql = 'SELECT * FROM "TH_ActivityLog"';
    const conditions = [];
    const values = [];
    let paramIdx = 1;

    if (date) {
      conditions.push(`date = $${paramIdx++}`);
      values.push(date);
    }
    if (route) {
      conditions.push(`route = $${paramIdx++}`);
      values.push(route);
    }

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }

    sql += ` ORDER BY "createdAt" DESC LIMIT $${paramIdx}`;
    values.push(limit);

    const logs = await queryTongHop(sql, values);
    return NextResponse.json(logs);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

// POST - Ghi log hoạt động
export async function POST(request) {
  try {
    const body = await request.json();
    const { action, description, bookingId, seatNumber, userName, date, route, timeSlot } = body;

    const result = await queryTongHop(`
      INSERT INTO "TH_ActivityLog" (action, description, "bookingId", "seatNumber", "userName", date, route, "timeSlot")
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *
    `, [action, description, bookingId || null, seatNumber || null, userName || null, date || null, route || null, timeSlot || null]);

    return NextResponse.json(result[0]);
  } catch (error) {
    // Fire-and-forget: không block nếu log bị lỗi
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
