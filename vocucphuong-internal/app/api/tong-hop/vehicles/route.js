import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    const vehicles = await queryTongHop('SELECT id, code as plate, type FROM "TH_Vehicles" ORDER BY code');
    return NextResponse.json(vehicles);
  } catch (error) {
    console.error('Error fetching vehicles:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const { plate, code, type } = await request.json();
    const vehicleCode = code || plate;
    const result = await queryTongHop(
      'INSERT INTO "TH_Vehicles" (code, type) VALUES ($1, $2) RETURNING id, code as plate, type',
      [vehicleCode, type || 'Limousine 9 chỗ']
    );
    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    console.error('Error creating vehicle:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
