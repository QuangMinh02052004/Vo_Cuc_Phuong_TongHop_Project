import { queryTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET ?q=<phone-prefix-or-name>&limit=8
// Trả về tối đa N khách quen distinct theo phone, ưu tiên gần nhất.
export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const q = (searchParams.get('q') || '').trim();
    const limit = Math.min(20, parseInt(searchParams.get('limit')) || 8);
    if (q.length < 3) return NextResponse.json({ suggestions: [] });

    const like = `%${q}%`;
    const rows = await queryTongHop(`
      SELECT DISTINCT ON (phone)
        phone, name, "pickupMethod", "pickupAddress", "dropoffMethod", "dropoffAddress", note,
        "createdAt"
      FROM "TH_Bookings"
      WHERE (phone ILIKE $1 OR name ILIKE $1) AND phone IS NOT NULL AND phone != ''
      ORDER BY phone, "createdAt" DESC
      LIMIT 200
    `, [like]);

    const sorted = rows
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
      .slice(0, limit)
      .map(r => ({
        phone: r.phone,
        name: r.name || '',
        pickupMethod: r.pickupMethod || '',
        pickupAddress: r.pickupAddress || '',
        dropoffMethod: r.dropoffMethod || '',
        dropoffAddress: r.dropoffAddress || '',
        note: r.note || '',
      }));

    return NextResponse.json({ suggestions: sorted });
  } catch (error) {
    return NextResponse.json({ error: error.message, suggestions: [] }, { status: 500 });
  }
}
