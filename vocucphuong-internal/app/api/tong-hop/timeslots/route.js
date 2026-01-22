import { queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// Khung giờ cho tuyến Sài Gòn - Long Khánh (05:30 - 20:00)
const SGtoLK_TIMES = [
  '05:30', '06:00', '06:30', '07:00', '07:30', '08:00', '08:30', '09:00', '09:30', '10:00',
  '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00',
  '15:30', '16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30', '20:00'
];

// Khung giờ cho tuyến Long Khánh - Sài Gòn (03:30 - 18:00) - matching original
const LKtoSG_TIMES = [
  '03:30', '04:00', '04:30', '05:00', '05:30', '06:00', '06:30', '07:00', '07:30', '08:00',
  '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00',
  '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30', '18:00'
];

// Routes với format chính xác (SG không có space trước dash, LK có space)
const ROUTE_SG_LK = 'Sài Gòn- Long Khánh';
const ROUTE_LK_SG = 'Long Khánh - Sài Gòn';
const DEFAULT_ROUTES = [ROUTE_SG_LK, ROUTE_LK_SG];

// Helper: Normalize route format to match standard
function normalizeRoute(route) {
  if (!route) return ROUTE_SG_LK;

  const lower = route.toLowerCase();

  // Check for Long Khánh - Sài Gòn direction
  if (lower.includes('long khánh') && lower.includes('sài gòn')) {
    if (lower.indexOf('long') < lower.indexOf('sài')) {
      return ROUTE_LK_SG; // LK -> SG
    }
  }

  // Check for Sài Gòn - Long Khánh direction (default)
  if (lower.includes('sài gòn') || lower.includes('sg') || lower.includes('saigon')) {
    return ROUTE_SG_LK;
  }

  // Default
  return ROUTE_SG_LK;
}

// Helper: Lấy danh sách times theo route
function getTimesForRoute(route) {
  if (route === ROUTE_LK_SG) {
    return LKtoSG_TIMES;
  }
  return SGtoLK_TIMES;
}

// Helper: Tạo các timeslot mặc định cho một ngày và route
async function createDefaultTimeslots(date, route) {
  const times = getTimesForRoute(route);
  const created = [];

  for (const time of times) {
    // Kiểm tra đã tồn tại chưa
    const existing = await queryOneTongHop(
      `SELECT id FROM "TH_TimeSlots" WHERE time = $1 AND date = $2 AND route = $3`,
      [time, date, route]
    );

    if (!existing) {
      const result = await queryTongHop(`
        INSERT INTO "TH_TimeSlots" (time, date, route, type, code, driver, phone)
        VALUES ($1, $2, $3, 'Xe 28G', '', '', '')
        RETURNING *
      `, [time, date, route]);
      created.push(result[0]);
    }
  }

  console.log(`[Timeslots] Đã tạo ${created.length} timeslot mặc định cho ngày ${date} route "${route}"`);
  return created;
}

// GET /api/tong-hop/timeslots
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const rawRoute = searchParams.get('route');
    // Normalize route format to prevent duplicates
    const route = rawRoute ? normalizeRoute(rawRoute) : null;

    // Nếu có date, kiểm tra và tạo timeslots mặc định nếu cần
    if (date) {
      // Kiểm tra cho TỪNG route, không phải tổng thể
      for (const r of DEFAULT_ROUTES) {
        // Nếu có filter route cụ thể, chỉ tạo cho route đó
        if (route && r !== route) continue;

        const expectedTimes = getTimesForRoute(r);
        const existingCount = await queryOneTongHop(
          `SELECT COUNT(*) as count FROM "TH_TimeSlots" WHERE date = $1 AND route = $2`,
          [date, r]
        );

        // Nếu chưa đủ timeslot cho ngày + route này, tạo bổ sung
        const currentCount = parseInt(existingCount?.count || '0');
        if (currentCount < expectedTimes.length) {
          console.log(`[Timeslots] Chỉ có ${currentCount}/${expectedTimes.length} timeslot cho ngày ${date} route "${r}", đang tạo bổ sung...`);
          await createDefaultTimeslots(date, r);
        }
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

    // Nếu có date filter thì limit 200, nếu không thì cần load nhiều hơn cho frontend
    const limit = date ? 200 : 10000;
    sqlQuery += ` ORDER BY date DESC, time ASC LIMIT ${limit}`;

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
    const { time, date, route: rawRoute, type, code, driver, phone } = body;
    // Normalize route format to prevent duplicates
    const route = normalizeRoute(rawRoute);

    // Kiểm tra xem time slot đã tồn tại chưa
    const existing = await queryOneTongHop(`
      SELECT * FROM "TH_TimeSlots"
      WHERE time = $1 AND date = $2 AND route = $3
    `, [time, date, route]);

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
    `, [time, date, route, type || 'Xe 28G', code || '', driver || '', phone || '']);

    console.log(`Đã tạo TimeSlot mới: ${time} ${date} ${route} (ID: ${result[0].id})`);
    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    console.error('Error creating timeslot:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
