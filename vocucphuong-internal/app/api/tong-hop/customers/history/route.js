import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET ?phone=... | ?q=... — trả full lịch sử booking + summary
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const phone = (searchParams.get('phone') || '').trim();
    const q = (searchParams.get('q') || '').trim();
    if (!phone && !q) return NextResponse.json({ error: 'Missing phone or q' }, { status: 400 });

    let rows;
    if (phone) {
      rows = await queryTongHop(`
        SELECT id, name, phone, "seatNumber", "timeSlot", route, date,
               amount, paid, status, "createdAt", "createdBy",
               "dropoffMethod", "dropoffAddress", note
        FROM "TH_Bookings"
        WHERE phone = $1
        ORDER BY "createdAt" DESC
        LIMIT 500
      `, [phone]);
    } else {
      const like = `%${q}%`;
      rows = await queryTongHop(`
        SELECT id, name, phone, "seatNumber", "timeSlot", route, date,
               amount, paid, status, "createdAt", "createdBy",
               "dropoffMethod", "dropoffAddress", note
        FROM "TH_Bookings"
        WHERE phone ILIKE $1 OR name ILIKE $1
        ORDER BY "createdAt" DESC
        LIMIT 500
      `, [like]);
    }

    const active = rows.filter(b => b.status !== 'cancelled');
    const cancelled = rows.filter(b => b.status === 'cancelled');
    const totalPaid = active.reduce((s, b) => s + (Number(b.paid) || 0), 0);
    const totalAmount = active.reduce((s, b) => s + (Number(b.amount) || 0), 0);

    // Profile = aggregate from latest booking
    const profile = rows[0] ? {
      name: rows[0].name,
      phone: rows[0].phone,
      lastDropoffMethod: rows[0].dropoffMethod,
      lastDropoffAddress: rows[0].dropoffAddress,
      lastNote: rows[0].note,
      firstSeen: rows[rows.length - 1]?.createdAt,
      lastSeen: rows[0]?.createdAt,
    } : null;

    return NextResponse.json({
      profile,
      summary: {
        total: active.length,
        cancelled: cancelled.length,
        totalAmount,
        totalPaid,
        debt: totalAmount - totalPaid,
      },
      bookings: rows,
    });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
