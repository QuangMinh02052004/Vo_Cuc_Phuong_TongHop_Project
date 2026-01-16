import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const route = searchParams.get('route');

    let sqlQuery = 'SELECT * FROM "TH_Bookings" WHERE 1=1';
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

    // Giới hạn 500 kết quả gần nhất
    sqlQuery += ' ORDER BY "createdAt" DESC LIMIT 500';

    const bookings = await queryTongHop(sqlQuery, params);
    return NextResponse.json(bookings);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const body = await request.json();
    const {
      timeSlotId, phone, name, gender, nationality, pickupMethod,
      pickupAddress, dropoffMethod, dropoffAddress, note, seatNumber,
      amount, paid, timeSlot, date, route
    } = body;

    const result = await queryTongHop(`
      INSERT INTO "TH_Bookings" (
        "timeSlotId", phone, name, gender, nationality, "pickupMethod",
        "pickupAddress", "dropoffMethod", "dropoffAddress", note, "seatNumber",
        amount, paid, "timeSlot", date, route
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
      RETURNING *
    `, [
      timeSlotId, phone || '', name || '', gender || '', nationality || '',
      pickupMethod || '', pickupAddress || '', dropoffMethod || '', dropoffAddress || '',
      note || '', seatNumber || 0, amount || 0, paid || 0, timeSlot || '', date || '', route || ''
    ]);

    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
