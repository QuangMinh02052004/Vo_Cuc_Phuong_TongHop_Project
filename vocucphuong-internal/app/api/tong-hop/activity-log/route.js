import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET - Lấy activity log với filter: date, route, userName, action, search, range (dateFrom/dateTo)
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const dateFrom = searchParams.get('dateFrom');
    const dateTo = searchParams.get('dateTo');
    const route = searchParams.get('route');
    const userName = searchParams.get('userName');
    const action = searchParams.get('action');
    const search = searchParams.get('search');
    const limit = Math.min(parseInt(searchParams.get('limit') || '100'), 500);
    const offset = parseInt(searchParams.get('offset') || '0');
    const includeCount = searchParams.get('includeCount') === '1';

    let sql = 'SELECT * FROM "TH_ActivityLog"';
    const conditions = [];
    const values = [];
    let paramIdx = 1;

    if (date) {
      conditions.push(`date = $${paramIdx++}`);
      values.push(date);
    }
    if (dateFrom) {
      conditions.push(`"createdAt" >= $${paramIdx++}`);
      values.push(dateFrom);
    }
    if (dateTo) {
      conditions.push(`"createdAt" <= $${paramIdx++}`);
      values.push(dateTo);
    }
    if (route) {
      conditions.push(`route = $${paramIdx++}`);
      values.push(route);
    }
    if (userName) {
      conditions.push(`"userName" = $${paramIdx++}`);
      values.push(userName);
    }
    if (action) {
      conditions.push(`action = $${paramIdx++}`);
      values.push(action);
    }
    if (search) {
      conditions.push(`description ILIKE $${paramIdx++}`);
      values.push(`%${search}%`);
    }

    const whereClause = conditions.length > 0 ? ' WHERE ' + conditions.join(' AND ') : '';
    sql += whereClause;
    sql += ` ORDER BY "createdAt" DESC LIMIT $${paramIdx++} OFFSET $${paramIdx++}`;
    values.push(limit, offset);

    const logs = await queryTongHop(sql, values);

    if (includeCount) {
      const countSql = 'SELECT COUNT(*)::int AS total FROM "TH_ActivityLog"' + whereClause;
      const countValues = values.slice(0, paramIdx - 3); // bỏ limit + offset
      const countRes = await queryTongHop(countSql, countValues);
      return NextResponse.json({ logs, total: countRes[0]?.total || 0 });
    }

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
