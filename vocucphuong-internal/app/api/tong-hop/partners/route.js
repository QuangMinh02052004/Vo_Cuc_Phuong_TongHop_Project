import { queryTongHop } from '../../../../lib/database';
import { ensurePartnerTable, generateApiKey } from '../../../../lib/partner-auth';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

export async function GET() {
  try {
    await ensurePartnerTable();
    const rows = await queryTongHop(`
      SELECT id, "apiKey", name, scopes, active, "createdAt", "lastUsedAt", "rateLimit"
      FROM "TH_PartnerKeys" ORDER BY "createdAt" DESC
    `);
    return NextResponse.json({ partners: rows });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    await ensurePartnerTable();
    const { name, scopes } = await request.json();
    if (!name) return NextResponse.json({ error: 'Missing name' }, { status: 400 });
    const apiKey = generateApiKey();
    const scopeArr = Array.isArray(scopes) && scopes.length > 0 ? scopes : ['read'];
    const rows = await queryTongHop(`
      INSERT INTO "TH_PartnerKeys" ("apiKey", name, scopes)
      VALUES ($1, $2, $3::text[])
      RETURNING *
    `, [apiKey, name, scopeArr]);
    return NextResponse.json({ partner: rows[0] }, { status: 201 });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function PATCH(request) {
  try {
    await ensurePartnerTable();
    const { id, active, scopes } = await request.json();
    if (!id) return NextResponse.json({ error: 'Missing id' }, { status: 400 });
    const sets = [];
    const params = [id];
    let i = 2;
    if (typeof active === 'boolean') { sets.push(`active = $${i++}`); params.push(active); }
    if (Array.isArray(scopes)) { sets.push(`scopes = $${i++}::text[]`); params.push(scopes); }
    if (sets.length === 0) return NextResponse.json({ error: 'No fields' }, { status: 400 });
    const rows = await queryTongHop(`UPDATE "TH_PartnerKeys" SET ${sets.join(',')} WHERE id = $1 RETURNING *`, params);
    return NextResponse.json({ partner: rows[0] });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function DELETE(request) {
  try {
    await ensurePartnerTable();
    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');
    if (!id) return NextResponse.json({ error: 'Missing id' }, { status: 400 });
    await queryTongHop(`DELETE FROM "TH_PartnerKeys" WHERE id = $1`, [id]);
    return NextResponse.json({ ok: true });
  } catch (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
