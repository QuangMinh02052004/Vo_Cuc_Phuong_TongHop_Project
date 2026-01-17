import { queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// Danh sách khung giờ mặc định (5:30 - 20:00)
const DEFAULT_TIMES = [
  '05:30', '06:00', '06:30', '07:00', '07:30', '08:00', '08:30', '09:00', '09:30', '10:00',
  '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00',
  '15:30', '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30', '20:00'
];

const DEFAULT_ROUTES = ['Sài Gòn - Long Khánh', 'Long Khánh - Sài Gòn'];

// Helper: Tạo các timeslot mặc định cho một ngày
async function createDefaultTimeslots(date, route = null) {
  const routes = route ? [route] : DEFAULT_ROUTES;
  const created = [];

  for (const r of routes) {
    for (const time of DEFAULT_TIMES) {
      // Kiểm tra đã tồn tại chưa
      const existing = await queryOneTongHop(
        `SELECT id FROM "TH_TimeSlots" WHERE time = $1 AND date = $2 AND route = $3`,
        [time, date, r]
      );

      if (!existing) {
        const result = await queryTongHop(`
          INSERT INTO "TH_TimeSlots" (time, date, route, type, code, driver, phone)
          VALUES ($1, $2, $3, 'Xe 28G', '', '', '')
          RETURNING *
        `, [time, date, r]);
        created.push(result[0]);
      }
    }
  }

  console.log(`[Timeslots] Đã tạo ${created.length} timeslot mặc định cho ngày ${date}`);
  return created;
}

// GET /api/tong-hop/timeslots
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const route = searchParams.get('route');

    // Nếu có date, kiểm tra và tạo timeslots mặc định nếu cần
    if (date) {
      const existingCount = await queryOneTongHop(
        `SELECT COUNT(*) as count FROM "TH_TimeSlots" WHERE date = $1`,
        [date]
      );

      // Nếu chưa có timeslot nào cho ngày này, tạo mặc định
      if (parseInt(existingCount?.count || '0') === 0) {
        console.log(`[Timeslots] Không có timeslot cho ngày ${date}, đang tạo mặc định...`);
        await createDefaultTimeslots(date, route);
      }
    }

    // Query timeslots
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
