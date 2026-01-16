import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const vehicles = await queryTongHop('SELECT * FROM "TH_Vehicles" ORDER BY plate');
    return NextResponse.json(vehicles);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const { plate, type, seats } = await request.json();
    const result = await queryTongHop(
      'INSERT INTO "TH_Vehicles" (plate, type, seats) VALUES ($1, $2, $3) RETURNING *',
      [plate, type || 'limousine', seats || 16]
    );
    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
