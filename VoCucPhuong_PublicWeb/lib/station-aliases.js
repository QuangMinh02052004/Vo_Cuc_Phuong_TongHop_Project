/**
 * StationAliases — lưu "từ viết tắt" (aliases) từng trạm vào DB NhapHang để admin
 * sửa được lúc chạy (Vercel FS read-only). Auto-booking NhapHang → TongHop
 * (webhook + reconcile) đọc danh sách merge từ đây thay vì hardcode trong lib/stations.js.
 *
 * Bảng "StationAliases": stt (khóa chính), name, aliases (JSONB mảng string).
 * Seed lần đầu từ danh sách gốc; mỗi lần ensure sẽ bổ sung trạm mới trong code
 * (ON CONFLICT chỉ update name, KHÔNG đụng aliases admin đã sửa).
 */
import { queryNhapHang, queryOneNhapHang } from './database';
import { stations as baseStations } from './stations';

let ensured = false;

async function ensureTable() {
  await queryNhapHang(`
    CREATE TABLE IF NOT EXISTS "StationAliases" (
      stt TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      aliases JSONB NOT NULL DEFAULT '[]'::jsonb,
      "updatedAt" TIMESTAMPTZ DEFAULT now()
    )
  `);

  if (ensured) return;
  // Đồng bộ danh mục trạm gốc: thêm trạm mới, cập nhật name; giữ nguyên aliases đã sửa.
  for (const s of baseStations) {
    await queryNhapHang(
      `INSERT INTO "StationAliases" (stt, name, aliases)
       VALUES ($1, $2, $3::jsonb)
       ON CONFLICT (stt) DO UPDATE SET name = EXCLUDED.name`,
      [String(s.stt), s.name, JSON.stringify(Array.isArray(s.aliases) ? s.aliases : [])]
    );
  }
  ensured = true;
}

// Danh sách đầy đủ (để trang admin hiển thị + sửa)
export async function getAllStationAliases() {
  await ensureTable();
  const rows = await queryNhapHang(`
    SELECT stt, name, aliases
    FROM "StationAliases"
    ORDER BY (split_part(stt, '.', 1))::int, stt
  `);
  return rows.map(r => ({
    stt: r.stt,
    name: r.name,
    aliases: Array.isArray(r.aliases) ? r.aliases : [],
  }));
}

// Danh sách để matcher dùng (webhook/reconcile) — cùng shape với lib/stations.
// Cache ngắn 15s để reconcile (loop nhiều đơn) không SELECT lặp mỗi lần.
let _mergedCache = null;
let _mergedCacheAt = 0;
export async function getMergedStations() {
  const now = Date.now();
  if (_mergedCache && now - _mergedCacheAt < 15000) return _mergedCache;
  const rows = await getAllStationAliases();
  _mergedCache = rows.map(r => ({ stt: r.stt, name: r.name, aliases: r.aliases }));
  _mergedCacheAt = now;
  return _mergedCache;
}

// Chuẩn hóa 1 alias: trim, lowercase, gộp khoảng trắng. Bỏ rỗng/trùng.
function cleanAliases(aliases) {
  if (!Array.isArray(aliases)) return [];
  const seen = new Set();
  const out = [];
  for (const a of aliases) {
    const v = String(a || '').toLowerCase().replace(/\s+/g, ' ').trim();
    if (!v || seen.has(v)) continue;
    seen.add(v);
    out.push(v);
  }
  return out;
}

// Lưu aliases cho 1 trạm. Trả về hàng đã cập nhật.
export async function updateStationAliases(stt, aliases) {
  await ensureTable();
  const clean = cleanAliases(aliases);
  const row = await queryOneNhapHang(
    `UPDATE "StationAliases"
     SET aliases = $2::jsonb, "updatedAt" = now()
     WHERE stt = $1
     RETURNING stt, name, aliases`,
    [String(stt), JSON.stringify(clean)]
  );
  if (!row) return null;
  _mergedCache = null; // invalidate cache để auto-booking dùng ngay aliases mới
  return { stt: row.stt, name: row.name, aliases: Array.isArray(row.aliases) ? row.aliases : [] };
}
