import { queryTongHop, queryOneTongHop } from '../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    const rows = await queryTongHop('SELECT id, code, type FROM "TH_Vehicles" ORDER BY code');
    return NextResponse.json({ vehicles: rows });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const { code, type } = await request.json();
    if (!code) return NextResponse.json({ error: 'Thiếu biển số' }, { status: 400 });

    const dup = await queryOneTongHop('SELECT id FROM "TH_Vehicles" WHERE code = $1', [code]);
    if (dup) return NextResponse.json({ error: 'Biển số đã tồn tại' }, { status: 409 });

    const row = await queryOneTongHop(
      'INSERT INTO "TH_Vehicles" (code, type) VALUES ($1, $2) RETURNING id, code, type',
      [code, type || 'Ghế ngồi 28 chỗ']
    );
    return NextResponse.json({ vehicle: row }, { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
