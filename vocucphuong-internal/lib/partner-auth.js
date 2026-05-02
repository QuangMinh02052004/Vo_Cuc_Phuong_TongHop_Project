import { queryOneTongHop, queryTongHop } from './database';
import crypto from 'crypto';

// Đảm bảo bảng TH_PartnerKeys tồn tại
let ensured = false;
export async function ensurePartnerTable() {
  if (ensured) return;
  await queryTongHop(`
    CREATE TABLE IF NOT EXISTS "TH_PartnerKeys" (
      id SERIAL PRIMARY KEY,
      "apiKey" TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      scopes TEXT[] DEFAULT ARRAY['read'],
      active BOOLEAN DEFAULT TRUE,
      "createdAt" TIMESTAMPTZ DEFAULT NOW(),
      "lastUsedAt" TIMESTAMPTZ,
      "rateLimit" INTEGER DEFAULT 1000
    )
  `);
  ensured = true;
}

export function generateApiKey() {
  return 'vcp_' + crypto.randomBytes(24).toString('base64url');
}

export async function authPartner(request, requiredScope = 'read') {
  await ensurePartnerTable();
  const key = request.headers.get('x-api-key') || request.headers.get('X-API-Key');
  if (!key) return { ok: false, status: 401, error: 'Missing X-API-Key header' };

  const partner = await queryOneTongHop(
    `SELECT * FROM "TH_PartnerKeys" WHERE "apiKey" = $1 AND active = TRUE`, [key]
  );
  if (!partner) return { ok: false, status: 403, error: 'Invalid or revoked API key' };

  if (!partner.scopes.includes(requiredScope) && !partner.scopes.includes('*')) {
    return { ok: false, status: 403, error: `Missing scope: ${requiredScope}` };
  }

  // Best-effort lastUsedAt update (no await for response speed)
  queryTongHop(`UPDATE "TH_PartnerKeys" SET "lastUsedAt" = NOW() WHERE id = $1`, [partner.id]).catch(() => {});

  return { ok: true, partner };
}
