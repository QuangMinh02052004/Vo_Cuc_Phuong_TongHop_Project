import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// GET /api/tong-hop/timeslots
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const route = searchParams.get('route');

    let sqlQuery = 'SELECT * FROM "TH_TimeSlots" WHERE 1=1';
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

    sqlQuery += ' ORDER BY time ASC';

    const timeSlots = await queryTongHop(sqlQuery, params);
    return NextResponse.json(timeSlots);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

// POST /api/tong-hop/timeslots
export async function POST(request) {
  try {
    const body = await request.json();
    const { time, date, route, type, code, driver, phone } = body;

    const result = await queryTongHop(`
      INSERT INTO "TH_TimeSlots" (time, date, route, type, code, driver, phone)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `, [time, date, route, type || 'limousine', code || '', driver || '', phone || '']);

    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
