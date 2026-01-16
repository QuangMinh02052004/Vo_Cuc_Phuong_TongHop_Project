import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

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
    const { name, phone, license } = await request.json();
    const result = await queryTongHop(
      'INSERT INTO "TH_Drivers" (name, phone, license) VALUES ($1, $2, $3) RETURNING *',
      [name, phone || '', license || '']
    );
    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
