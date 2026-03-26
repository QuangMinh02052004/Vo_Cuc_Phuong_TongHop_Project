import { queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// Helper: Generate danh sách giờ từ start→end, mỗi interval phút
function generateTimes(startTime, endTime, intervalMinutes) {
  const times = [];
  const [startH, startM] = startTime.split(':').map(Number);
  const [endH, endM] = endTime.split(':').map(Number);
  let current = startH * 60 + startM;
  const end = endH * 60 + endM;
  while (current <= end) {
    const h = String(Math.floor(current / 60)).padStart(2, '0');
    const m = String(current % 60).padStart(2, '0');
    times.push(`${h}:${m}`);
    current += intervalMinutes;
  }
  return times;
}

// Helper: Lấy danh sách times theo route (từ TH_Routes database, fallback theo hướng)
async function getTimesForRoute(route) {
  // Thử lấy từ TH_Routes database
  try {
    const routeInfo = await queryOneTongHop(
      'SELECT "operatingStart", "operatingEnd", "intervalMinutes" FROM "TH_Routes" WHERE name = $1 AND "isActive" = true',
      [route]
    );
    if (routeInfo) {
      return generateTimes(routeInfo.operatingStart || '05:30', routeInfo.operatingEnd || '20:00', routeInfo.intervalMinutes || 30);
    }
  } catch (e) {
    console.warn('[Timeslots] Lỗi query TH_Routes:', e.message);
  }

  // Fallback: detect hướng tuyến
  const lower = (route || '').toLowerCase();
  const isFromLK = lower.startsWith('long khánh') || lower.startsWith('xuân lộc');
  if (isFromLK) {
    return generateTimes('03:30', '18:00', 30);
  }
  return generateTimes('05:30', '20:00', 30);
}

// Helper: Tạo các timeslot mặc định cho một ngày và route
async function createDefaultTimeslots(date, route) {
  const times = await getTimesForRoute(route);
  const created = [];

  for (const time of times) {
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
    const route = searchParams.get('route') || null;

    // Query timeslots - SỬ DỤNG DISTINCT ON để loại bỏ duplicate
    // Giữ lại record có ID nhỏ nhất (cũ nhất) cho mỗi time+date+route
    let sqlQuery = `
      SELECT DISTINCT ON (time, date, route) *
      FROM "TH_TimeSlots"
      WHERE 1=1
    `;
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

    // Order by time, date, route TRƯỚC (cho DISTINCT ON), rồi mới id (để chọn cái cũ nhất)
    // Sau đó order lại theo date DESC, time ASC cho output
    sqlQuery += ` ORDER BY time, date, route, id ASC`;

    // Wrap trong subquery để có thể order lại
    const limit = date ? 200 : 10000;
    const finalQuery = `
      SELECT * FROM (${sqlQuery}) AS deduped
      ORDER BY date DESC, time ASC
      LIMIT ${limit}
    `;

    const timeSlots = await queryTongHop(finalQuery, params);
    return NextResponse.json(timeSlots);
  } catch (error) {
    console.error('Error fetching timeslots:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

// POST /api/tong-hop/timeslots - Tạo mới hoặc trả về slot đã tồn tại (UPSERT)
export async function POST(request) {
  try {
    const body = await request.json();
    const { time, date, route, type, code, driver, phone } = body;

    if (!route) {
      return NextResponse.json({ error: 'Route is required' }, { status: 400 });
    }

    // Sử dụng UPSERT để tránh race condition và đảm bảo không duplicate
    // ON CONFLICT DO UPDATE để luôn trả về dữ liệu mới nhất
    const result = await queryTongHop(`
      INSERT INTO "TH_TimeSlots" (time, date, route, type, code, driver, phone)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      ON CONFLICT (date, time, route) DO UPDATE SET
        type = COALESCE(EXCLUDED.type, "TH_TimeSlots".type),
        code = COALESCE(EXCLUDED.code, "TH_TimeSlots".code),
        driver = COALESCE(EXCLUDED.driver, "TH_TimeSlots".driver),
        phone = COALESCE(EXCLUDED.phone, "TH_TimeSlots".phone)
      RETURNING *
    `, [time, date, route, type || 'Xe 28G', code || '', driver || '', phone || '']);

    const timeslot = result[0];
    console.log(`[Timeslots] UPSERT: ${time} ${date} ${route} (ID: ${timeslot.id})`);
    return NextResponse.json(timeslot, { status: 201 });
  } catch (error) {
    console.error('Error creating timeslot:', error);
    // Nếu lỗi unique constraint (race condition), thử lấy existing
    if (error.code === '23505') {
      try {
        const body2 = await request.clone().json();
        const existing = await queryOneTongHop(`
          SELECT * FROM "TH_TimeSlots"
          WHERE time = $1 AND date = $2 AND route = $3
        `, [body2.time, body2.date, body2.route]);
        if (existing) {
          return NextResponse.json(existing, { status: 200 });
        }
      } catch (e) {
        // ignore
      }
    }
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
