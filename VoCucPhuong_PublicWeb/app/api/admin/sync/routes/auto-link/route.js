import { queryTongHop, queryDatVe, queryOneDatVe } from '../../../../../../lib/database';
import { NextResponse } from 'next/server';

export const dynamic = 'force-dynamic';

function normalize(s) {
  return (s || '').toString().trim().toLowerCase();
}

function stripType(s) {
  return normalize(s).replace(/\s*\((cao tốc|quốc lộ|cao toc|quoc lo)\)\s*$/i, '').trim();
}

function detectType(s) {
  const n = normalize(s);
  if (n.includes('cao tốc') || n.includes('cao toc')) return 'cao_toc';
  if (n.includes('quốc lộ') || n.includes('quoc lo')) return 'quoc_lo';
  return null;
}

export async function POST() {
  try {
    await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "datveRouteId" TEXT`);

    const thRoutes = await queryTongHop('SELECT * FROM "TH_Routes"');
    const datveRoutes = await queryDatVe('SELECT id, origin, destination, price, duration, bus_type, distance, operating_start, operating_end, interval_minutes, is_active FROM routes');

    const results = { linked: [], created: [], skipped: [], errors: [] };

    for (const th of thRoutes) {
      if (th.datveRouteId) {
        results.skipped.push({ id: th.id, name: th.name, reason: 'đã có datveRouteId' });
        continue;
      }

      const thFrom = stripType(th.fromStation);
      const thTo = stripType(th.toStation);
      const thType = th.routeType || detectType(th.name) || 'quoc_lo';

      let match = datveRoutes.find((d) => {
        const dvFrom = stripType(d.origin);
        const dvTo = stripType(d.destination);
        const dvTypeFromOrigin = detectType(d.origin);
        const dvTypeFromDest = detectType(d.destination);
        const dvType = dvTypeFromDest || dvTypeFromOrigin;
        return dvFrom === thFrom && dvTo === thTo && (dvType === thType || !dvType);
      });

      if (!match) {
        match = datveRoutes.find((d) => stripType(d.origin) === thFrom && stripType(d.destination) === thTo);
      }

      if (match) {
        try {
          await queryTongHop('UPDATE "TH_Routes" SET "datveRouteId" = $1 WHERE id = $2', [match.id, th.id]);
          results.linked.push({ id: th.id, name: th.name, datveId: match.id });
        } catch (err) {
          results.errors.push({ id: th.id, name: th.name, error: err.message });
        }
      } else {
        try {
          const suffix = thType === 'cao_toc' ? ' (Cao tốc)' : ' (Quốc lộ)';
          const newDatve = await queryOneDatVe(
            `INSERT INTO routes (id, origin, destination, price, duration, bus_type, distance,
             operating_start, operating_end, interval_minutes, is_active, created_at, updated_at)
             VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())
             RETURNING id`,
            [th.fromStation, th.toStation + suffix, th.price || 0, th.duration || '',
             th.busType || 'Ghế ngồi', th.distance || null,
             th.operatingStart || '05:30', th.operatingEnd || '20:00',
             th.intervalMinutes || 30, th.isActive !== false]
          );
          await queryTongHop('UPDATE "TH_Routes" SET "datveRouteId" = $1 WHERE id = $2', [newDatve.id, th.id]);
          results.created.push({ id: th.id, name: th.name, datveId: newDatve.id });
        } catch (err) {
          results.errors.push({ id: th.id, name: th.name, error: err.message });
        }
      }
    }

    return NextResponse.json({
      success: true,
      summary: {
        total: thRoutes.length,
        linked: results.linked.length,
        created: results.created.length,
        skipped: results.skipped.length,
        errors: results.errors.length,
      },
      details: results,
    });
  } catch (error) {
    console.error('[auto-link] POST', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
