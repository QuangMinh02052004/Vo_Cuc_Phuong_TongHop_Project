import { queryTongHop } from './database';

// Idempotent ensure: 2 cột thường bị thiếu trên TH cũ.
// Gọi đầu các route đọc/ghi để self-heal, không cần migration thủ công.
let cached = false;
export async function ensureTHCoreColumns() {
  if (cached) return;
  await queryTongHop(`ALTER TABLE "TH_Bookings" ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active'`);
  await queryTongHop(`ALTER TABLE "TH_Bookings" ADD COLUMN IF NOT EXISTS "createdBy" TEXT`);
  await queryTongHop(`ALTER TABLE "TH_Bookings" ADD COLUMN IF NOT EXISTS "callStatus" TEXT`);
  await queryTongHop(`ALTER TABLE "TH_Bookings" ADD COLUMN IF NOT EXISTS printed BOOLEAN DEFAULT false`);
  await queryTongHop(`ALTER TABLE "TH_Users" ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT true`);
  cached = true;
}
