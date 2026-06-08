// Reconciliation: quét các Products "Dọc đường" chưa sync sang TongHop và tạo booking.
// Endpoint này gọi được từ:
//   - Vercel Cron (vercel.json schedule)
//   - Frontend NhapHang polling mỗi 30s
//   - External cron (cron-job.org) ping HTTP
//
// Idempotent: chạy nhiều lần liên tiếp không tạo trùng vì check syncedToTongHop=false + clientReqId UNIQUE.

import { queryNhapHang, queryOneNhapHang, queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { extractAddressFromName, extractNameOnly } from '../../../../lib/stations';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// ===== Copy các helpers cần thiết từ products/route.js =====
function formatDDMMYYYY(date) {
  const d = new Date(date);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = d.getFullYear();
  return `${day}-${month}-${year}`;
}

function roundToNextTimeSlot(date) {
  const d = new Date(date);
  let hours = d.getHours();
  let minutes = d.getMinutes();
  if (minutes === 0 || minutes === 30) {
    return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
  }
  if (minutes < 30) return `${String(hours).padStart(2, '0')}:30`;
  return `${String((hours + 1) % 24).padStart(2, '0')}:00`;
}

function determineRoute(senderStation) {
  if (!senderStation) return 'Sài Gòn - Long Khánh (Quốc lộ)';
  const s = senderStation.toLowerCase();
  const lk = ['trảng bom','trang bom','dầu giây','dau giay','long khánh','long khanh','hưng lộc','hung loc','tam hiệp','tam hiep','hố nai','ho nai','xuân lộc','xuan loc','amata'];
  if (lk.some(n => s.includes(n))) return 'Long Khánh - Sài Gòn (Quốc lộ)';
  return 'Sài Gòn - Long Khánh (Quốc lộ)';
}

function formatBookingNote(receiverName, productType, quantity) {
  const name = receiverName || '';
  if (quantity && quantity.trim()) return `giao ${name} ${quantity}`;
  const m = (productType || '').match(/^(\d+)\s*-\s*(.+)$/);
  if (m) return `giao ${name} 1 ${m[2].trim()}`;
  return `giao ${name} 1`;
}

async function ensureTimeslotsExist(dateStr, route) {
  const existing = await queryOneTongHop(
    'SELECT COUNT(*) as count FROM "TH_TimeSlots" WHERE date = $1 AND route = $2',
    [dateStr, route]
  );
  if (parseInt(existing?.count || '0') > 0) return;

  let startTime = '05:30', endTime = '20:00', intervalMinutes = 30;
  try {
    const r = await queryOneTongHop(
      'SELECT "operatingStart","operatingEnd","intervalMinutes" FROM "TH_Routes" WHERE name=$1 AND "isActive"=true',
      [route]
    );
    if (r) {
      startTime = r.operatingStart || startTime;
      endTime = r.operatingEnd || endTime;
      intervalMinutes = r.intervalMinutes || intervalMinutes;
    }
  } catch {}

  if ((route || '').toLowerCase().startsWith('long khánh')) {
    if (startTime === '05:30') { startTime = '03:30'; endTime = '18:00'; }
  }

  const times = [];
  const [sH, sM] = startTime.split(':').map(Number);
  const [eH, eM] = endTime.split(':').map(Number);
  let cur = sH * 60 + sM;
  const end = eH * 60 + eM;
  while (cur <= end) {
    times.push(`${String(Math.floor(cur / 60)).padStart(2,'0')}:${String(cur % 60).padStart(2,'0')}`);
    cur += intervalMinutes;
  }
  if (times.length === 0) return;
  const values = [];
  const params = [];
  let idx = 1;
  for (const t of times) {
    values.push(`($${idx++},$${idx++},$${idx++},'Xe 28G','','','')`);
    params.push(t, dateStr, route);
  }
  await queryTongHop(`
    INSERT INTO "TH_TimeSlots" (time,date,route,type,code,driver,phone)
    VALUES ${values.join(',')}
    ON CONFLICT (date, time, route) DO NOTHING
  `, params);
}

async function findNearestTimeslot(route, currentDate) {
  const now = currentDate || new Date();
  const totalMin = now.getHours() * 60 + now.getMinutes();
  const today = formatDDMMYYYY(now);
  await ensureTimeslotsExist(today, route);
  const slots = await queryTongHop(
    `SELECT * FROM "TH_TimeSlots" WHERE date=$1 AND route=$2 ORDER BY time ASC`,
    [today, route]
  );
  for (const s of slots) {
    const [h, m] = s.time.split(':').map(Number);
    if (h * 60 + m > totalMin) return s;
  }
  const tomorrow = new Date(now);
  tomorrow.setDate(tomorrow.getDate() + 1);
  const tomStr = formatDDMMYYYY(tomorrow);
  await ensureTimeslotsExist(tomStr, route);
  return await queryOneTongHop(
    `SELECT * FROM "TH_TimeSlots" WHERE date=$1 AND route=$2 ORDER BY time ASC LIMIT 1`,
    [tomStr, route]
  );
}

// Retry-on-conflict seat assignment: thử 28 ghế, bất kỳ ghế nào INSERT conflict thì thử ghế khác
async function createBookingWithSeatRetry(product, timeSlot, route) {
  const matchResult = extractAddressFromName(product.receiverName);
  const cleanName = matchResult
    ? extractNameOnly(product.receiverName, matchResult.matchedText)
    : (product.receiverName || '');
  const dropoffAddress = matchResult
    ? `${matchResult.stt}. ${matchResult.stationName}`
    : (product.station || 'Dọc đường');
  const bookingNote = formatBookingNote(cleanName, product.productType, product.quantity);

  // Lấy danh sách ghế đã dùng để bắt đầu thử từ ghế thấp nhất chưa dùng
  const used = await queryTongHop(
    `SELECT "seatNumber" FROM "TH_Bookings" WHERE "timeSlotId"=$1 AND "seatNumber">0`,
    [timeSlot.id]
  );
  const usedSet = new Set(used.map(r => r.seatNumber));

  for (let seat = 1; seat <= 28; seat++) {
    if (usedSet.has(seat)) continue;
    try {
      const booking = await queryOneTongHop(`
        INSERT INTO "TH_Bookings" (
          "timeSlotId", phone, name, "pickupMethod", "pickupAddress",
          "dropoffMethod", "dropoffAddress", note, "seatNumber",
          amount, paid, "timeSlot", date, route, "clientReqId"
        ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)
        ON CONFLICT ("clientReqId") DO UPDATE SET "updatedAt"=NOW()
        RETURNING id, "seatNumber"
      `, [
        timeSlot.id,
        product.receiverPhone || '',
        cleanName,
        'Tại bến', 'tại bến',
        'Dọc đường', dropoffAddress,
        bookingNote, seat,
        parseFloat(product.totalAmount) || 0,
        parseFloat(product.totalAmount) || 0,
        timeSlot.time, timeSlot.date, route,
        product.id ? String(product.id) : null,
      ]);
      return booking;
    } catch (e) {
      // Lỗi ghế trùng → thử ghế kế
      if (e.code === '23505' && /seatNumber/i.test(e.message || '')) {
        usedSet.add(seat);
        continue;
      }
      throw e;
    }
  }
  // Hết ghế → vẫn force vào ghế 28 (fallback giống logic cũ)
  return null;
}

async function syncOneProduct(product) {
  // Check đã có booking chưa (idempotent)
  if (product.tongHopBookingId) {
    return { skipped: true, reason: 'already-synced' };
  }
  const existing = await queryOneTongHop(
    `SELECT id, "seatNumber" FROM "TH_Bookings" WHERE "clientReqId"=$1 LIMIT 1`,
    [String(product.id)]
  );
  if (existing) {
    await queryNhapHang(
      `UPDATE "Products" SET "tongHopBookingId"=$1, "syncedToTongHop"=true WHERE id=$2`,
      [existing.id, product.id]
    );
    return { skipped: true, reason: 'already-exists', bookingId: existing.id };
  }

  const route = determineRoute(product.senderStation);
  const sendDate = product.sendDate ? new Date(product.sendDate) : new Date();
  let timeSlot = await findNearestTimeslot(route, sendDate);
  if (!timeSlot) {
    const dateStr = formatDDMMYYYY(sendDate);
    const timeStr = roundToNextTimeSlot(sendDate);
    timeSlot = await queryOneTongHop(`
      INSERT INTO "TH_TimeSlots" (time,date,route,type)
      VALUES ($1,$2,$3,'Xe 28G') RETURNING *
    `, [timeStr, dateStr, route]);
  }

  const booking = await createBookingWithSeatRetry(product, timeSlot, route);
  if (!booking) {
    return { failed: true, reason: 'no-seat-available' };
  }

  await queryNhapHang(
    `UPDATE "Products" SET "tongHopBookingId"=$1, "syncedToTongHop"=true WHERE id=$2`,
    [booking.id, product.id]
  );
  return { created: true, bookingId: booking.id, seat: booking.seatNumber };
}

async function reconcile({ maxItems = 50, sinceMinutes = 1440 } = {}) {
  // Đảm bảo cột clientReqId + unique index (cho idempotency của INSERT)
  await queryTongHop(`ALTER TABLE "TH_Bookings" ADD COLUMN IF NOT EXISTS "clientReqId" TEXT`);
  await queryTongHop(`CREATE UNIQUE INDEX IF NOT EXISTS "UQ_Bookings_clientReqId" ON "TH_Bookings"("clientReqId")`);

  // Lấy đơn dọc đường chưa sync trong khoảng thời gian (default 24h)
  const products = await queryNhapHang(`
    SELECT * FROM "Products"
    WHERE "syncedToTongHop" = false
      AND (
        LOWER(station) LIKE '%dọc đường%'
        OR LOWER(station) LIKE '%doc duong%'
        OR LOWER(station) LIKE '00 -%'
      )
      AND "sendDate" > NOW() - INTERVAL '${sinceMinutes} minutes'
      AND (status IS NULL OR status != 'cancelled')
    ORDER BY "sendDate" ASC
    LIMIT $1
  `, [maxItems]);

  let created = 0, skipped = 0, failed = 0;
  const details = [];
  for (const p of products) {
    try {
      const r = await syncOneProduct(p);
      if (r.created) { created++; details.push({ id: p.id, bookingId: r.bookingId, seat: r.seat }); }
      else if (r.skipped) skipped++;
      else if (r.failed) { failed++; details.push({ id: p.id, error: r.reason }); }
    } catch (e) {
      failed++;
      details.push({ id: p.id, error: e.message });
    }
  }
  return { scanned: products.length, created, skipped, failed, details };
}

// GET: dùng cho Vercel Cron + external cron + frontend polling
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const maxItems = parseInt(searchParams.get('max') || '50', 10);
    const sinceMinutes = parseInt(searchParams.get('since') || '1440', 10);
    const result = await reconcile({ maxItems, sinceMinutes });
    return NextResponse.json({ success: true, ...result });
  } catch (e) {
    console.error('[Reconcile] Error:', e);
    return NextResponse.json({ success: false, error: e.message }, { status: 500 });
  }
}
