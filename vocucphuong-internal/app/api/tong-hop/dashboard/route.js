import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET ?from=DD-MM-YYYY&to=DD-MM-YYYY
// Trả về:
//   - daily: doanh thu/vé theo từng ngày
//   - byRoute: doanh thu/vé/lấp ghế theo tuyến
//   - heatmap: lấp ghế theo (route × timeSlot)
//   - topCustomers: khách hàng đặt nhiều nhất
//   - summary: totals
function parseDDMMYYYY(s) {
  if (!s) return null;
  const [d, m, y] = s.split('-');
  if (!d || !m || !y) return null;
  return new Date(`${y}-${m}-${d}T00:00:00Z`);
}
function ddmmyyyy(date) {
  const dd = String(date.getUTCDate()).padStart(2, '0');
  const mm = String(date.getUTCMonth() + 1).padStart(2, '0');
  return `${dd}-${mm}-${date.getUTCFullYear()}`;
}
function* dateRange(from, to) {
  const cur = new Date(from);
  while (cur <= to) {
    yield ddmmyyyy(cur);
    cur.setUTCDate(cur.getUTCDate() + 1);
  }
}

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const fromStr = searchParams.get('from');
    const toStr = searchParams.get('to');

    const today = new Date();
    today.setUTCHours(0, 0, 0, 0);
    const defaultFrom = new Date(today);
    defaultFrom.setUTCDate(defaultFrom.getUTCDate() - 6); // 7 ngày gần nhất

    const fromDate = parseDDMMYYYY(fromStr) || defaultFrom;
    const toDate = parseDDMMYYYY(toStr) || today;

    const dates = Array.from(dateRange(fromDate, toDate));
    if (dates.length === 0) {
      return NextResponse.json({ error: 'Invalid date range' }, { status: 400 });
    }

    // Bookings trong khoảng
    const bookings = await queryTongHop(`
      SELECT id, name, phone, "seatNumber", "timeSlot", route, date,
             amount, paid, status
      FROM "TH_Bookings"
      WHERE date = ANY($1::text[])
    `, [dates]);

    const active = bookings.filter(b => b.status !== 'cancelled');
    const cancelled = bookings.filter(b => b.status === 'cancelled');

    // Tổng số ghế khả dụng (28 ghế/chuyến) → cần đếm số (route × timeSlot × date) thực sự có booking
    const tripsSet = new Set();
    for (const b of active) tripsSet.add(`${b.date}|${b.route}|${b.timeSlot}`);
    const totalSeatsAvailable = tripsSet.size * 28;
    const fillRate = totalSeatsAvailable > 0 ? (active.length / totalSeatsAvailable) : 0;

    // === Daily ===
    const dailyMap = new Map(dates.map(d => [d, { date: d, count: 0, paid: 0, amount: 0, cancelled: 0 }]));
    for (const b of active) {
      const g = dailyMap.get(b.date);
      if (g) {
        g.count++;
        g.paid += Number(b.paid) || 0;
        g.amount += Number(b.amount) || 0;
      }
    }
    for (const b of cancelled) {
      const g = dailyMap.get(b.date);
      if (g) g.cancelled++;
    }
    const daily = Array.from(dailyMap.values());

    // === byRoute ===
    const byRouteMap = new Map();
    for (const b of active) {
      const k = b.route || '(không tuyến)';
      if (!byRouteMap.has(k)) byRouteMap.set(k, { route: k, count: 0, paid: 0, amount: 0, trips: new Set() });
      const g = byRouteMap.get(k);
      g.count++;
      g.paid += Number(b.paid) || 0;
      g.amount += Number(b.amount) || 0;
      g.trips.add(`${b.date}|${b.timeSlot}`);
    }
    const byRoute = Array.from(byRouteMap.values()).map(g => ({
      route: g.route,
      count: g.count,
      paid: g.paid,
      amount: g.amount,
      trips: g.trips.size,
      fillRate: g.trips.size > 0 ? g.count / (g.trips.size * 28) : 0,
    })).sort((a, b) => b.paid - a.paid);

    // === Heatmap (route × timeSlot fill rate) ===
    const cellMap = new Map();
    for (const b of active) {
      const key = `${b.route}|${b.timeSlot}`;
      if (!cellMap.has(key)) cellMap.set(key, { route: b.route, timeSlot: b.timeSlot, count: 0, days: new Set() });
      const g = cellMap.get(key);
      g.count++;
      g.days.add(b.date);
    }
    const heatmap = Array.from(cellMap.values()).map(g => ({
      route: g.route,
      timeSlot: g.timeSlot,
      count: g.count,
      days: g.days.size,
      fillRate: g.days.size > 0 ? g.count / (g.days.size * 28) : 0,
    }));

    // === Top customers (theo số vé) ===
    const custMap = new Map();
    for (const b of active) {
      const key = b.phone || b.name || '(ẩn)';
      if (!custMap.has(key)) custMap.set(key, { phone: b.phone, name: b.name, count: 0, paid: 0 });
      const g = custMap.get(key);
      g.count++;
      g.paid += Number(b.paid) || 0;
    }
    const topCustomers = Array.from(custMap.values())
      .sort((a, b) => b.count - a.count)
      .slice(0, 20);

    return NextResponse.json({
      from: ddmmyyyy(fromDate),
      to: ddmmyyyy(toDate),
      summary: {
        totalBookings: active.length,
        cancelledBookings: cancelled.length,
        totalAmount: active.reduce((s, b) => s + (Number(b.amount) || 0), 0),
        totalPaid: active.reduce((s, b) => s + (Number(b.paid) || 0), 0),
        totalDebt: active.reduce((s, b) => s + ((Number(b.amount) || 0) - (Number(b.paid) || 0)), 0),
        totalTrips: tripsSet.size,
        totalSeatsAvailable,
        fillRate,
      },
      daily,
      byRoute,
      heatmap,
      topCustomers,
    });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
