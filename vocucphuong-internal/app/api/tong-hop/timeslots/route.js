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

// Helper: Lấy danh sách times theo route từ TH_Routes database
async function getTimesForRoute(route) {
  try {
    const routeInfo = await queryOneTongHop(
      'SELECT "operatingStart", "operatingEnd", "intervalMinutes" FROM "TH_Routes" WHERE name = $1 AND "isActive" = true',
      [route]
    );
    if (routeInfo) {
      return generateTimes(
        routeInfo.operatingStart || '05:30',
        routeInfo.operatingEnd || '20:00',
        routeInfo.intervalMinutes || 30
      );
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

// Helper: Tạo timeslots cho date + route bằng batch INSERT ... ON CONFLICT
async function ensureTimeslots(date, route) {
  const times = await getTimesForRoute(route);

  // Lấy danh sách time đã tồn tại
  const existingSlots = await queryTongHop(
    'SELECT time FROM "TH_TimeSlots" WHERE date = $1 AND route = $2',
    [date, route]
  );
  const existingTimes = new Set(existingSlots.map(s => s.time));

  // Lọc ra các time chưa có
  const missingTimes = times.filter(t => !existingTimes.has(t));

  if (missingTimes.length === 0) return 0;

  // Batch insert tất cả missing times trong 1 query
  const values = [];
  const params = [];
  let paramIdx = 1;

  for (const time of missingTimes) {
    values.push(`($${paramIdx++}, $${paramIdx++}, $${paramIdx++}, 'Xe 28G', '', '', '')`);
    params.push(time, date, route);
  }

  await queryTongHop(`
    INSERT INTO "TH_TimeSlots" (time, date, route, type, code, driver, phone)
    VALUES ${values.join(', ')}
    ON CONFLICT (date, time, route) DO NOTHING
  `, params);

  console.log(`[Timeslots] Tạo ${missingTimes.length} timeslot cho ${date} "${route}"`);
  return missingTimes.length;
}

// GET /api/tong-hop/timeslots - Lấy timeslots, tự động tạo nếu chưa có
// Hỗ trợ ?since=ISO để lấy delta (chỉ slots updated sau timestamp) — KHÔNG auto-create trong delta mode
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    const route = searchParams.get('route') || null;
    const since = searchParams.get('since');

    // Auto-create chỉ khi KHÔNG phải delta mode (delta mode tránh side-effect tốn DB)
    if (!since) {
      if (date && route) {
        await ensureTimeslots(date, route);
      } else if (date && !route) {
        try {
          const activeRoutes = await queryTongHop('SELECT name FROM "TH_Routes" WHERE "isActive" = true');
          for (const r of activeRoutes) {
            await ensureTimeslots(date, r.name);
          }
        } catch (e) {
          console.warn('[Timeslots] Lỗi query routes:', e.message);
        }
      }
    }

    // Query timeslots
    let sqlQuery = 'SELECT * FROM "TH_TimeSlots" WHERE 1=1';
    const params = [];
    let paramIndex = 1;

    if (since) {
      sqlQuery += ` AND "updatedAt" > $${paramIndex++}`;
      params.push(since);
    }

    if (date) {
      sqlQuery += ` AND date = $${paramIndex++}`;
      params.push(date);
    }

    if (route) {
      sqlQuery += ` AND route = $${paramIndex++}`;
      params.push(route);
    }

    if (since) {
      sqlQuery += ' ORDER BY "updatedAt" ASC LIMIT 1000';
    } else {
      sqlQuery += ' ORDER BY date DESC, time ASC';
      const limit = date ? 500 : 10000;
      sqlQuery += ` LIMIT ${limit}`;
    }

    const timeSlots = await queryTongHop(sqlQuery, params);

    // Loại duplicate ở JS level (backup cho trường hợp lỗi unique constraint)
    const seen = new Set();
    const deduped = timeSlots.filter(s => {
      const key = `${s.time}_${s.date}_${s.route}`;
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });

    if (since) {
      const serverTime = new Date().toISOString();
      return NextResponse.json({ timeSlots: deduped, serverTime });
    }
    return NextResponse.json(deduped);
  } catch (error) {
    console.error('Error fetching timeslots:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

// POST /api/tong-hop/timeslots - Tạo mới (UPSERT)
export async function POST(request) {
  try {
    const body = await request.json();
    const { time, date, route, type, code, driver, phone } = body;

    if (!route) {
      return NextResponse.json({ error: 'Route is required' }, { status: 400 });
    }

    const result = await queryTongHop(`
      INSERT INTO "TH_TimeSlots" (time, date, route, type, code, driver, phone)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      ON CONFLICT (date, time, route) DO UPDATE SET
        type = COALESCE(NULLIF(EXCLUDED.type, ''), "TH_TimeSlots".type),
        code = COALESCE(NULLIF(EXCLUDED.code, ''), "TH_TimeSlots".code),
        driver = COALESCE(NULLIF(EXCLUDED.driver, ''), "TH_TimeSlots".driver),
        phone = COALESCE(NULLIF(EXCLUDED.phone, ''), "TH_TimeSlots".phone)
      RETURNING *
    `, [time, date, route, type || 'Xe 28G', code || '', driver || '', phone || '']);

    const timeslot = result[0];
    return NextResponse.json(timeslot, { status: 201 });
  } catch (error) {
    console.error('Error creating timeslot:', error);
    if (error.code === '23505') {
      try {
        const existing = await queryOneTongHop(
          'SELECT * FROM "TH_TimeSlots" WHERE time = $1 AND date = $2 AND route = $3',
          [body.time, body.date, body.route]
        );
        if (existing) return NextResponse.json(existing, { status: 200 });
      } catch (e) { /* ignore */ }
    }
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
