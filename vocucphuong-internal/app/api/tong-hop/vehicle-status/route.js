import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    const rows = await queryTongHop(`
      SELECT v.id, v.code, v.type,
        COALESCE(vs.status, 'ready') as status,
        vs.note,
        vs."updatedBy",
        vs."updatedAt"
      FROM "TH_Vehicles" v
      LEFT JOIN "TH_VehicleStatus" vs ON vs."vehicleId" = v.id
      ORDER BY v.type
    `);
    return NextResponse.json(rows);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const { vehicleId, status, note, updatedBy } = await request.json();

    // Check if record exists
    const existing = await queryTongHop(
      'SELECT id FROM "TH_VehicleStatus" WHERE "vehicleId"=$1', [vehicleId]
    );

    let result;
    if (existing.length > 0) {
      result = await queryTongHop(
        'UPDATE "TH_VehicleStatus" SET status=$1, note=$2, "updatedBy"=$3, "updatedAt"=NOW() WHERE "vehicleId"=$4 RETURNING *',
        [status || 'ready', note || '', updatedBy || '', vehicleId]
      );
    } else {
      result = await queryTongHop(
        'INSERT INTO "TH_VehicleStatus" ("vehicleId", status, note, "updatedBy") VALUES ($1,$2,$3,$4) RETURNING *',
        [vehicleId, status || 'ready', note || '', updatedBy || '']
      );
    }

    return NextResponse.json(result[0]);
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
