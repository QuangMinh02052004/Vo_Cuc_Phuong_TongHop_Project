import { queryTongHop, queryOneTongHop } from '../../../../lib/database';
import { stations as seedStations } from '../../../../lib/stations';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

// ===========================================
// API: TRẠM ĐÓN DỌC ĐƯỜNG
// ===========================================
// Bảng nguồn dùng chung cho TongHop + DatVe.
// stt          : chuỗi hiển thị gốc ("1", "7.1", "94")
// sortOrder    : decimal để sắp xếp (1.0, 7.1, 94.0) — chiều mặc định Sài Gòn → Long Khánh
// direction    : query param "sg-lk" (mặc định) hoặc "lk-sg" → đảo thứ tự + đánh lại STT hiển thị 1..N

async function ensureTable() {
  await queryTongHop(`
    CREATE TABLE IF NOT EXISTS "TH_PickupStations" (
      id SERIAL PRIMARY KEY,
      stt VARCHAR(10) NOT NULL,
      "sortOrder" DECIMAL(6,2) NOT NULL UNIQUE,
      name TEXT NOT NULL,
      aliases JSONB DEFAULT '[]'::jsonb,
      "isActive" BOOLEAN DEFAULT true,
      "createdAt" TIMESTAMP DEFAULT NOW(),
      "updatedAt" TIMESTAMP DEFAULT NOW()
    )
  `);
}

async function seedIfEmpty() {
  const row = await queryOneTongHop('SELECT COUNT(*)::int AS cnt FROM "TH_PickupStations"');
  if (row && row.cnt > 0) return 0;

  // Seed từ lib/stations.js
  const values = [];
  const params = [];
  let p = 1;
  for (const s of seedStations) {
    const sortOrder = parseFloat(s.stt);
    if (Number.isNaN(sortOrder)) continue;
    values.push(`($${p++}, $${p++}, $${p++}, $${p++}::jsonb)`);
    params.push(s.stt, sortOrder, s.name, JSON.stringify(s.aliases || []));
  }
  if (values.length === 0) return 0;

  await queryTongHop(
    `INSERT INTO "TH_PickupStations" (stt, "sortOrder", name, aliases) VALUES ${values.join(',')}
     ON CONFLICT ("sortOrder") DO NOTHING`,
    params
  );
  return values.length;
}

export async function GET(request) {
  try {
    await ensureTable();
    await seedIfEmpty();

    const { searchParams } = new URL(request.url);
    const direction = (searchParams.get('direction') || 'sg-lk').toLowerCase();
    const activeOnly = searchParams.get('activeOnly') !== 'false';

    const rows = await queryTongHop(`
      SELECT id, stt, "sortOrder", name, aliases, "isActive"
      FROM "TH_PickupStations"
      ${activeOnly ? 'WHERE "isActive" = true' : ''}
      ORDER BY "sortOrder" ASC
    `);

    // Đảo chiều LK → SG: reverse mảng + đánh số hiển thị 1..N
    const ordered = direction === 'lk-sg' ? [...rows].reverse() : rows;
    const withDisplay = ordered.map((r, i) => ({
      ...r,
      displayStt: String(i + 1).padStart(2, '0'),
    }));

    return NextResponse.json(withDisplay);
  } catch (error) {
    console.error('[PickupStations GET]', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    await ensureTable();
    const body = await request.json();
    const { stt, sortOrder, name, aliases = [] } = body;

    if (!stt || !name || sortOrder === undefined) {
      return NextResponse.json(
        { error: 'Thiếu trường bắt buộc: stt, sortOrder, name' },
        { status: 400 }
      );
    }

    const result = await queryTongHop(
      `INSERT INTO "TH_PickupStations" (stt, "sortOrder", name, aliases)
       VALUES ($1, $2, $3, $4::jsonb)
       RETURNING *`,
      [String(stt), parseFloat(sortOrder), name, JSON.stringify(aliases)]
    );
    return NextResponse.json(result[0], { status: 201 });
  } catch (error) {
    console.error('[PickupStations POST]', error);
    if (String(error.code) === '23505') {
      return NextResponse.json({ error: 'sortOrder đã tồn tại, chọn giá trị khác' }, { status: 409 });
    }
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
