import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET - Sinh báo cáo doanh thu / chuyến cho 1 ngày (DD-MM-YYYY)
// Trả về { date, summary, byRoute, byTimeSlot, bookings }
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const date = searchParams.get('date');
    if (!date) return NextResponse.json({ error: 'Missing date' }, { status: 400 });

    const bookings = await queryTongHop(`
      SELECT id, name, phone, "seatNumber", "timeSlot", "timeSlotId", route, date,
             amount, paid, status, "createdAt", "createdBy"
      FROM "TH_Bookings"
      WHERE date = $1
      ORDER BY route, "timeSlot", "seatNumber"
    `, [date]);

    const active = bookings.filter(b => b.status !== 'cancelled');
    const cancelled = bookings.filter(b => b.status === 'cancelled');

    const totalAmount = active.reduce((s, b) => s + (Number(b.amount) || 0), 0);
    const totalPaid = active.reduce((s, b) => s + (Number(b.paid) || 0), 0);
    const totalDebt = totalAmount - totalPaid;

    // Group by route
    const byRouteMap = new Map();
    for (const b of active) {
      const k = b.route || '(không tuyến)';
      if (!byRouteMap.has(k)) byRouteMap.set(k, { route: k, count: 0, amount: 0, paid: 0 });
      const g = byRouteMap.get(k);
      g.count++;
      g.amount += Number(b.amount) || 0;
      g.paid += Number(b.paid) || 0;
    }
    const byRoute = Array.from(byRouteMap.values()).sort((a, b) => b.paid - a.paid);

    // Group by timeSlot
    const byTSMap = new Map();
    for (const b of active) {
      const k = `${b.route}|${b.timeSlot}`;
      if (!byTSMap.has(k)) byTSMap.set(k, { route: b.route, timeSlot: b.timeSlot, count: 0, amount: 0, paid: 0 });
      const g = byTSMap.get(k);
      g.count++;
      g.amount += Number(b.amount) || 0;
      g.paid += Number(b.paid) || 0;
    }
    const byTimeSlot = Array.from(byTSMap.values()).sort((a, b) => {
      if (a.route !== b.route) return a.route.localeCompare(b.route);
      return (a.timeSlot || '').localeCompare(b.timeSlot || '');
    });

    return NextResponse.json({
      date,
      summary: {
        totalBookings: active.length,
        cancelledBookings: cancelled.length,
        totalAmount,
        totalPaid,
        totalDebt,
      },
      byRoute,
      byTimeSlot,
      bookings: active,
    });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
