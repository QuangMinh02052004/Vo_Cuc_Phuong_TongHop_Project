import { queryTongHop, queryDatVe, queryOneDatVe } from './database';

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

function suffixForType(t) {
  return t === 'cao_toc' ? ' (Cao tốc)' : ' (Quốc lộ)';
}

export async function findOrCreateDatveRoute(thRoute, datveRoutesCache = null) {
  const datveRoutes = datveRoutesCache || await queryDatVe(
    'SELECT id, origin, destination FROM routes'
  );

  const thFrom = stripType(thRoute.fromStation);
  const thTo = stripType(thRoute.toStation);
  const thType = thRoute.routeType || detectType(thRoute.name) || 'quoc_lo';

  let match = datveRoutes.find((d) => {
    const dvFrom = stripType(d.origin);
    const dvTo = stripType(d.destination);
    const dvType = detectType(d.destination) || detectType(d.origin);
    return dvFrom === thFrom && dvTo === thTo && (dvType === thType || !dvType);
  });
  if (match) return { id: match.id, action: 'linked' };

  match = datveRoutes.find((d) => stripType(d.origin) === thFrom && stripType(d.destination) === thTo);
  if (match) return { id: match.id, action: 'linked' };

  const suffix = suffixForType(thType);
  const newRow = await queryOneDatVe(
    `INSERT INTO routes (id, origin, destination, price, duration, bus_type, distance,
     operating_start, operating_end, interval_minutes, is_active, created_at, updated_at)
     VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW())
     RETURNING id`,
    [
      thRoute.fromStation,
      thRoute.toStation + suffix,
      thRoute.price || 0,
      thRoute.duration || '',
      thRoute.busType || 'Ghế ngồi',
      thRoute.distance || null,
      thRoute.operatingStart || '05:30',
      thRoute.operatingEnd || '20:00',
      thRoute.intervalMinutes || 30,
      thRoute.isActive !== false,
    ]
  );
  return { id: newRow.id, action: 'created' };
}

export async function autoLinkAllUnlinked() {
  await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "datveRouteId" TEXT`);
  const thRoutes = await queryTongHop('SELECT * FROM "TH_Routes" WHERE "datveRouteId" IS NULL');
  if (thRoutes.length === 0) return { linked: 0, created: 0 };

  const datveRoutes = await queryDatVe('SELECT id, origin, destination FROM routes');

  let linked = 0;
  let created = 0;
  for (const th of thRoutes) {
    try {
      const result = await findOrCreateDatveRoute(th, datveRoutes);
      await queryTongHop('UPDATE "TH_Routes" SET "datveRouteId" = $1 WHERE id = $2', [result.id, th.id]);
      if (result.action === 'linked') linked++;
      else created++;
      if (result.action === 'created') {
        datveRoutes.push({ id: result.id, origin: th.fromStation, destination: th.toStation });
      }
    } catch (err) {
      console.error('[autoLink] failed for', th.id, th.name, err.message);
    }
  }
  return { linked, created };
}

// Reverse autolink: DatVe routes chưa có TH_Routes → tạo TH_Routes
export async function autoLinkFromDatve() {
  await queryTongHop(`ALTER TABLE "TH_Routes" ADD COLUMN IF NOT EXISTS "datveRouteId" TEXT`);
  const datveRoutes = await queryDatVe(
    `SELECT id, origin, destination, price, duration, bus_type, distance,
            operating_start, operating_end, interval_minutes, is_active
     FROM routes`
  );
  if (datveRoutes.length === 0) return { created: 0 };

  const thRoutes = await queryTongHop('SELECT id, name, "fromStation", "toStation", "routeType", "datveRouteId" FROM "TH_Routes"');
  const linkedDatveIds = new Set(thRoutes.map((th) => th.datveRouteId).filter(Boolean));

  let created = 0;
  for (const dv of datveRoutes) {
    if (linkedDatveIds.has(dv.id)) continue;

    const dvFromStripped = stripType(dv.origin);
    const dvToStripped = stripType(dv.destination);
    const dvType = detectType(dv.destination) || detectType(dv.origin) || 'quoc_lo';

    // Có TH_Route nào match từ→đến + type chưa? Nếu có thì link.
    const match = thRoutes.find(
      (th) =>
        stripType(th.fromStation) === dvFromStripped &&
        stripType(th.toStation) === dvToStripped &&
        (th.routeType === dvType || !th.routeType)
    );
    if (match) {
      await queryTongHop('UPDATE "TH_Routes" SET "datveRouteId" = $1 WHERE id = $2', [dv.id, match.id]);
      linkedDatveIds.add(dv.id);
      continue;
    }

    // Tạo TH_Route mới mirror DatVe
    const typeLabel = dvType === 'cao_toc' ? 'Cao tốc' : 'Quốc lộ';
    const name = `${dvFromStripped.replace(/\b\w/g, (c) => c.toUpperCase())} - ${dvToStripped.replace(/\b\w/g, (c) => c.toUpperCase())} (${typeLabel})`;
    try {
      // Skip nếu TH_Route đã có name trùng (chưa có UNIQUE constraint)
      const existed = await queryTongHop('SELECT id FROM "TH_Routes" WHERE name = $1 LIMIT 1', [name]);
      if (existed.length > 0) {
        await queryTongHop('UPDATE "TH_Routes" SET "datveRouteId" = $1 WHERE id = $2', [dv.id, existed[0].id]);
        linkedDatveIds.add(dv.id);
        continue;
      }
      await queryTongHop(
        `INSERT INTO "TH_Routes"
          (name, "routeType", "fromStation", "toStation", price, duration, "busType", seats, distance,
           "operatingStart", "operatingEnd", "intervalMinutes", "isActive", "datveRouteId")
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
        [
          name,
          dvType,
          dv.origin.replace(/\s*\((cao tốc|quốc lộ|cao toc|quoc lo)\)\s*$/i, '').trim(),
          dv.destination.replace(/\s*\((cao tốc|quốc lộ|cao toc|quoc lo)\)\s*$/i, '').trim(),
          dv.price || 0,
          dv.duration || '',
          dv.bus_type || 'Ghế ngồi',
          28,
          dv.distance || '',
          dv.operating_start || '05:30',
          dv.operating_end || '20:00',
          dv.interval_minutes || 30,
          dv.is_active !== false,
          dv.id,
        ]
      );
      created++;
      linkedDatveIds.add(dv.id);
    } catch (err) {
      console.error('[autoLinkFromDatve] failed for', dv.id, err.message);
    }
  }
  return { created };
}
