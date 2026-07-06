/**
 * Nguồn "từ viết tắt" cho auto-booking NhapHang → TongHop.
 * ĐÃ GỘP: dùng chung bảng "TH_PickupStations" (DB TongHop) với trạm đón dọc đường
 * bên DatVe — một nguồn dữ liệu duy nhất, sửa 1 chỗ áp dụng mọi nơi.
 *
 * Trước đây có bảng riêng "StationAliases" (DB NhapHang) — nay bỏ, không dùng nữa.
 */
import { queryTongHop, queryOneTongHop } from './database';
import { stations as baseStations } from './stations';

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
  const row = await queryOneTongHop('SELECT COUNT(*)::int AS cnt FROM "TH_PickupStations"');
  if (row && row.cnt > 0) return;
  // Seed lần đầu từ lib/stations.js
  const values = [];
  const params = [];
  let p = 1;
  for (const s of baseStations) {
    const sortOrder = parseFloat(s.stt);
    if (Number.isNaN(sortOrder)) continue;
    values.push(`($${p++}, $${p++}, $${p++}, $${p++}::jsonb)`);
    params.push(s.stt, sortOrder, s.name, JSON.stringify(s.aliases || []));
  }
  if (values.length === 0) return;
  await queryTongHop(
    `INSERT INTO "TH_PickupStations" (stt, "sortOrder", name, aliases) VALUES ${values.join(',')}
     ON CONFLICT ("sortOrder") DO NOTHING`,
    params
  );
}

// Danh sách để matcher dùng (webhook/reconcile) — cùng shape với lib/stations.
// Cache ngắn 15s để reconcile (loop nhiều đơn) không SELECT lặp.
let _mergedCache = null;
let _mergedCacheAt = 0;
export async function getMergedStations() {
  const now = Date.now();
  if (_mergedCache && now - _mergedCacheAt < 15000) return _mergedCache;
  await ensureTable();
  const rows = await queryTongHop(`
    SELECT stt, name, aliases
    FROM "TH_PickupStations"
    ORDER BY "sortOrder" ASC
  `);
  _mergedCache = rows.map(r => ({
    stt: r.stt,
    name: r.name,
    aliases: Array.isArray(r.aliases) ? r.aliases : [],
  }));
  _mergedCacheAt = now;
  return _mergedCache;
}
