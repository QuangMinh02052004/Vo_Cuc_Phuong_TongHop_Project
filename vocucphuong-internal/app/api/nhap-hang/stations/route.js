import { query } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const stations = await query('SELECT * FROM "Stations" ORDER BY "StationID"');
    return NextResponse.json({ success: true, stations });
  } catch (error) {
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}
