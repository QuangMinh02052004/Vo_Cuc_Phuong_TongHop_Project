import { queryTongHop } from '../../../../../lib/database';
import { authPartner } from '../../../../../lib/partner-auth';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// GET /api/public/v1/routes — list active routes
export async function GET(request) {
  const auth = await authPartner(request, 'read');
  if (!auth.ok) return NextResponse.json({ error: auth.error }, { status: auth.status });

  try {
    const rows = await queryTongHop(`
      SELECT id, name, "from", "to", price
      FROM "TH_Routes"
      WHERE "deletedAt" IS NULL
      ORDER BY name
    `);
    return NextResponse.json({ routes: rows });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
