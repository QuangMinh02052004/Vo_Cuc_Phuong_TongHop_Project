import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    const drivers = await queryTongHop('SELECT * FROM "TH_Drivers" ORDER BY name');
    return NextResponse.json(drivers);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const { name, phone } = await request.json();
    const result = await queryTongHop(
      'INSERT INTO "TH_Drivers" (name, phone) VALUES ($1, $2) RETURNING *',
      [name, phone || '']
    );
    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    console.error('Error creating driver:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
