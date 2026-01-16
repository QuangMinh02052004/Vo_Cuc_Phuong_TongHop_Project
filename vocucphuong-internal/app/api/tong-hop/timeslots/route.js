import { queryTongHop, queryOneTongHop } from '../../../../lib/database';
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

    sqlQuery += ' ORDER BY time ASC LIMIT 200';

    const timeSlots = await queryTongHop(sqlQuery, params);
    return NextResponse.json(timeSlots);
  } catch (error) {
    console.error('Error fetching timeslots:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

// POST /api/tong-hop/timeslots - Tạo mới hoặc trả về slot đã tồn tại
export async function POST(request) {
  try {
    const body = await request.json();
    const { time, date, route, type, code, driver, phone } = body;

    // Kiểm tra xem time slot đã tồn tại chưa
    const existing = await queryOneTongHop(`
      SELECT * FROM "TH_TimeSlots"
      WHERE time = $1 AND date = $2 AND route = $3
    `, [time, date, route || '']);

    if (existing) {
      // Đã tồn tại, trả về slot hiện có
      console.log(`TimeSlot ${time} ${date} ${route} đã tồn tại, trả về slot hiện có (ID: ${existing.id})`);
      return NextResponse.json(existing, { status: 200 });
    }

    // Chưa tồn tại, tạo mới
    const result = await queryTongHop(`
      INSERT INTO "TH_TimeSlots" (time, date, route, type, code, driver, phone)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `, [time, date, route || '', type || 'Xe 28G', code || '', driver || '', phone || '']);

    console.log(`Đã tạo TimeSlot mới: ${time} ${date} ${route} (ID: ${result[0].id})`);
    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    console.error('Error creating timeslot:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
