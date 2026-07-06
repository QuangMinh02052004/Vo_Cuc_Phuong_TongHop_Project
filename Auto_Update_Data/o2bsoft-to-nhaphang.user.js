// ==UserScript==
// @name         O2BSoft → NhapHang Sync
// @namespace    vocucphuong.local
// @version      0.11.0
// @description  Đồng bộ bảng Kho hàng o2bsoft → NhapHang. Manual + auto 20s + auto-reload trang 60s. v0.11: timer chạy trong Web Worker → sync đều cả khi tab ở nền (không bị trình duyệt bóp nhịp).
// @match        https://xe.o2bsoft.com/*
// @match        http://xe.o2bsoft.com/*
// @grant        GM_xmlhttpRequest
// @grant        GM_setValue
// @grant        GM_getValue
// @connect      vocucphuongmanage.vercel.app
// @run-at       document-idle
// ==/UserScript==

(function () {
  'use strict';

  const NHAPHANG_BASE = 'https://vocucphuongmanage.vercel.app';
  const AUTO_INTERVAL_MS = 20000;   // sync mỗi 20s
  const AUTO_RELOAD_MS = 60000;     // reload trang mỗi 60s để lấy đơn mới do người khác nhập
  const MAX_PAGES = 30;             // safety cap để tránh loop vô hạn

  // FORCE: Mọi đơn sync từ o2b đều coi như trạm gửi = AN ĐÔNG
  // Lý do: tài khoản o2b "Lê Thanh Tâm" làm việc tại An Đông, mọi data từ o2b đều bắt nguồn từ trạm này.
  // Bỏ qua việc đọc "Trạm hiện tại" từ DOM o2b → tránh sai sót khi header parser fail.
  // Có thể đổi sang khoá khác (vd. 'metro') nếu sau này cần chuyển trạm.
  const FORCE_SENDER_STATION_KEY = 'andong';

  function getEmployeeName() {
    let name = GM_getValue('employee_name', '');
    if (!name) {
      name = prompt('Nhập tên nhân viên (lưu cho lần sau):', '') || 'O2BSync';
      GM_setValue('employee_name', name);
    }
    return name;
  }

  // ===== Helpers =====
  function $$(sel, root) { return Array.from((root || document).querySelectorAll(sel)); }
  function txt(el) { return (el?.textContent || '').replace(/\s+/g, ' ').trim(); }

  function parseAmount(s) {
    if (!s) return 0;
    const n = parseInt(String(s).replace(/[^\d]/g, ''), 10);
    return isNaN(n) ? 0 : n;
  }

  // "11h05 - 03/06/2026" → "2026-06-03T11:05:00" (giờ Vietnam, không timezone)
  function parseSendDate(s) {
    if (!s) return null;
    const m = s.match(/(\d{1,2})h(\d{1,2})\s*-\s*(\d{1,2})\/(\d{1,2})\/(\d{4})/);
    if (m) {
      const [_, hh, mm, dd, mo, yy] = m;
      const pad = (x) => String(x).padStart(2, '0');
      return `${yy}-${pad(mo)}-${pad(dd)}T${pad(hh)}:${pad(mm)}:00`;
    }
    return null;
  }

  function normalize(s) {
    return (s || '')
      .toLowerCase()
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .replace(/đ/g, 'd')
      .replace(/[^a-z0-9]/g, '');
  }

  function todayYMD() {
    const d = new Date();
    const pad = (x) => String(x).padStart(2, '0');
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
  }

  function getSenderStationLabel() {
    const candidates = $$('*').slice(0, 500).map(txt);
    const hit = candidates.find((t) => /Tr[aạ]m hi[eệ]n t[aạ]i\s*:/i.test(t) && t.length < 200);
    if (!hit) return null;
    const m = hit.match(/Tr[aạ]m hi[eệ]n t[aạ]i\s*:\s*([^\n|]+)/i);
    return m ? m[1].trim().split(/\s{2,}/)[0].trim() : null;
  }

  // Lấy ra hàng được coi là header của bảng (th hoặc tr đầu tiên có td)
  function getHeaderCells(table) {
    let cells = $$('th, thead td', table);
    if (cells.length === 0) {
      const firstTr = table.querySelector('tr');
      if (firstTr) cells = $$('td', firstTr);
    }
    return cells.map(txt);
  }

  // Chuẩn hoá text header: bỏ ▼ ▲ ▾ ▴ ⌄ và khoảng trắng đầu cuối
  function cleanHeader(s) {
    return (s || '').replace(/[▼▲▾▴˅▽△]/g, '').replace(/\s+/g, ' ').trim();
  }

  // ASCII không dấu, lower-case, chỉ chữ+số+space → so sánh chắc chắn không bị Unicode encoding
  function asciiHeader(s) {
    return cleanHeader(s)
      .toLowerCase()
      .normalize('NFD')
      .replace(/[̀-ͯ]/g, '')
      .replace(/đ/g, 'd')
      .replace(/[^a-z0-9 ]/g, '')
      .replace(/\s+/g, ' ')
      .trim();
  }

  function findDataTable(root) {
    root = root || document;
    const tables = Array.from(root.querySelectorAll('table'));
    let best = null, bestScore = 0;
    for (const t of tables) {
      const headers = getHeaderCells(t).map(asciiHeader);
      const hasMa = headers.includes('ma');
      const hasNguoiNhan = headers.includes('nguoi nhan');
      const hasTong = headers.some((h) => h.startsWith('tong'));
      if (!(hasMa && hasNguoiNhan && hasTong)) continue;
      const rowCount = t.querySelectorAll('tr').length;
      if (rowCount > bestScore) { bestScore = rowCount; best = t; }
    }
    return best;
  }

  // Tìm số trang lớn nhất từ pagination (ul > li > a có pn=N)
  function findMaxPageNumber(root) {
    root = root || document;
    const links = Array.from(root.querySelectorAll('a[href*="pn="]'));
    let max = 1;
    for (const a of links) {
      const m = a.getAttribute('href').match(/[?&]pn=(\d+)/);
      if (m) {
        const n = parseInt(m[1], 10);
        if (n > max) max = n;
      }
    }
    return max;
  }

  // Fetch HTML 1 trang qua HTTP (giữ cookie session) → trả về parsed DOM
  async function fetchPageDom(pageNum) {
    const url = `${location.origin}/?m=warehouse/send&pn=${pageNum}`;
    const res = await fetch(url, { credentials: 'include' });
    if (!res.ok) throw new Error(`HTTP ${res.status} khi tải trang ${pageNum}`);
    const html = await res.text();
    const doc = new DOMParser().parseFromString(html, 'text/html');
    return doc;
  }

  function getColumnIndex(table) {
    const headers = getHeaderCells(table).map(asciiHeader);
    const iNhan = headers.indexOf('nguoi nhan');
    return {
      _headers: headers,
      ma: headers.indexOf('ma'),
      nguoiGui: headers.indexOf('nguoi goi'),
      sdtGui: headers.findIndex((h, i) => h === 'dien thoai' && i < iNhan),
      nguoiNhan: iNhan,
      sdtNhan: headers.findIndex((h, i) => h === 'dien thoai' && i > iNhan),
      tramNhan: headers.indexOf('tram nhan'),
      ngayGui: headers.indexOf('ngay goi') >= 0 ? headers.indexOf('ngay goi') : headers.indexOf('ngay gui'),
      xe: headers.indexOf('xe'),
      loaiHang: headers.indexOf('loai hang'),
      baoHiem: headers.indexOf('bao hiem'),
      tongVnd: headers.findIndex((h) => h.startsWith('tong')),
    };
  }

  function parseRows(table) {
    const cols = getColumnIndex(table);
    // Lấy mọi tr; nếu không có tbody thì bỏ qua hàng đầu (giả định là header)
    let rows = $$('tbody tr', table);
    if (rows.length === 0) {
      rows = $$('tr', table).slice(1);
    }
    const out = [];
    for (const tr of rows) {
      const tds = $$('td', tr);
      if (tds.length < 5 || cols.ma < 0 || cols.ma >= tds.length) continue;
      const ma = txt(tds[cols.ma]);
      if (!ma || ma.length < 3) continue;
      if (tds[cols.ma].querySelector('input, select')) continue;

      const ngayGui = cols.ngayGui >= 0 ? txt(tds[cols.ngayGui]) : '';
      const sendDate = parseSendDate(ngayGui);
      if (!sendDate) continue; // bỏ qua row "Hiện tại" hoặc row chưa có giờ

      out.push({
        o2bId: ma,
        senderName: cols.nguoiGui >= 0 ? txt(tds[cols.nguoiGui]) : '',
        senderPhone: cols.sdtGui >= 0 ? txt(tds[cols.sdtGui]) : '',
        receiverName: cols.nguoiNhan >= 0 ? txt(tds[cols.nguoiNhan]) : '',
        receiverPhone: cols.sdtNhan >= 0 ? txt(tds[cols.sdtNhan]) : '',
        tramNhanRaw: cols.tramNhan >= 0 ? txt(tds[cols.tramNhan]) : '',
        vehicle: cols.xe >= 0 ? txt(tds[cols.xe]) : '',
        productTypeRaw: cols.loaiHang >= 0 ? txt(tds[cols.loaiHang]) : '',
        insurance: cols.baoHiem >= 0 ? parseAmount(txt(tds[cols.baoHiem])) : 0,
        totalAmount: cols.tongVnd >= 0 ? parseAmount(txt(tds[cols.tongVnd])) : 0,
        sendDate, // giữ NGUYÊN giờ gửi từ o2bsoft
      });
    }
    // o2bsoft sort từ trên xuống = mới → cũ.
    // Sync từ cũ → mới để counter NhapHang sinh mã đúng thứ tự thời gian.
    // Sort theo sendDate ASC (fallback: đảo thứ tự nếu sendDate trùng).
    out.sort((a, b) => {
      if (a.sendDate < b.sendDate) return -1;
      if (a.sendDate > b.sendDate) return 1;
      return 0;
    });
    return out;
  }

  function gmRequest(method, url, payload) {
    return new Promise((resolve, reject) => {
      GM_xmlhttpRequest({
        method,
        url,
        headers: { 'Content-Type': 'application/json' },
        data: payload ? JSON.stringify(payload) : undefined,
        onload: (res) => {
          try {
            const json = res.responseText ? JSON.parse(res.responseText) : {};
            resolve({ status: res.status, body: json });
          } catch (e) {
            resolve({ status: res.status, body: { raw: res.responseText } });
          }
        },
        onerror: (err) => reject(err),
        ontimeout: () => reject(new Error('timeout')),
      });
    });
  }

  async function fetchStations() {
    const { body } = await gmRequest('GET', `${NHAPHANG_BASE}/api/nhap-hang/stations`);
    const list = body?.data || body?.stations || body || [];
    const map = new Map();
    for (const s of list) {
      const name = s.name || '';
      const full = s.fullName || (s.code ? `${s.code} - ${name}` : name);
      map.set(normalize(name), full);
      if (s.code) map.set(s.code, full);
    }
    return map;
  }

  async function fetchTodayProducts(dateStr) {
    const { body } = await gmRequest('GET', `${NHAPHANG_BASE}/api/nhap-hang/products?date=${dateStr}&limit=1000`);
    const arr = body?.data || body?.products || [];
    const idx = new Map();
    for (const p of arr) {
      // v0.10+: mã đơn NhapHang = mã O2BSoft → index theo p.id trực tiếp
      if (p.id) idx.set(String(p.id), p);
      // Fallback cho đơn cũ (v0.9 trở xuống) lưu o2bId trong notes
      const m = (p.notes || '').match(/o2b:([^\s|]+)/);
      if (m) idx.set(m[1], p);
    }
    return idx;
  }

  function mapStation(label, stationsMap) {
    if (!label) return null;
    const key = normalize(label);
    if (stationsMap.has(key)) return stationsMap.get(key);
    if (/docduong/i.test(key)) {
      for (const v of stationsMap.values()) {
        if (/^00/i.test(v)) return v;
      }
      return '00 - Dọc đường';
    }
    for (const [k, v] of stationsMap.entries()) {
      if (k.length > 2 && (k.includes(key) || key.includes(k))) return v;
    }
    return label;
  }

  function mapProductType(label) {
    const k = normalize(label);
    return ({
      kien: '06 - Kiện',
      thung: '02 - Thùng',
      goi: '01 - Gói',
      bao: '03 - Bao',
      thungxop: '04 - Thùng xốp',
    })[k] || label || '';
  }

  function buildPayload(row, stationsMap, senderStationLabel, employee) {
    return {
      // v0.10+: dùng LUÔN mã đơn O2BSoft làm id NhapHang (không qua counter sinh YYMMDD.SSNN nữa)
      // → 2 hệ thống cùng mã, đối chiếu nhanh, không sai lệch.
      id: row.o2bId,
      senderName: row.senderName || null,
      senderPhone: row.senderPhone || null,
      senderStation: mapStation(senderStationLabel, stationsMap),
      receiverName: row.receiverName || null,
      receiverPhone: row.receiverPhone || null,
      station: mapStation(row.tramNhanRaw, stationsMap),
      productType: mapProductType(row.productTypeRaw),
      quantity: null,
      vehicle: row.vehicle || null,
      insurance: row.insurance || 0,
      totalAmount: row.totalAmount || 0,
      paymentStatus: row.totalAmount >= 10000 ? 'paid' : 'unpaid',
      employee,
      createdBy: employee,
      notes: `o2b:${row.o2bId}`,
      sendDate: row.sendDate, // giờ gửi từ o2bsoft, server lưu nguyên không convert timezone
    };
  }

  function payloadsEqual(p, e) {
    const n = (x) => parseFloat(x || 0);
    return (
      (e.receiverName || '') === (p.receiverName || '') &&
      (e.receiverPhone || '') === (p.receiverPhone || '') &&
      (e.station || '') === (p.station || '') &&
      (e.productType || '') === (p.productType || '') &&
      n(e.totalAmount) === n(p.totalAmount) &&
      n(e.insurance) === n(p.insurance)
    );
  }

  // ===== Sync =====
  let isRunning = false;
  let stats = loadStats();
  let lastError = GM_getValue('last_error', '');

  function loadStats() {
    try {
      const raw = GM_getValue('stats', null);
      if (!raw) return { created: 0, updated: 0, skipped: 0, failed: 0, lastAt: null };
      const s = JSON.parse(raw);
      if (s.lastAt) s.lastAt = new Date(s.lastAt);
      return s;
    } catch { return { created: 0, updated: 0, skipped: 0, failed: 0, lastAt: null }; }
  }
  function saveStats() {
    GM_setValue('stats', JSON.stringify({ ...stats, lastAt: stats.lastAt?.toISOString() || null }));
  }

  function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

  // Đợi đến khi tìm thấy bảng có dữ liệu (sau reload DOM cần thời gian)
  async function waitForTable(maxMs = 15000) {
    const start = Date.now();
    while (Date.now() - start < maxMs) {
      const t = findDataTable();
      if (t) {
        const rs = parseRows(t);
        if (rs.length > 0) return { table: t, rows: rs };
      }
      await sleep(500);
    }
    const t = findDataTable();
    return { table: t, rows: t ? parseRows(t) : [] };
  }

  // Tìm nút "Trang sau / Next" trong vùng pagination
  function findNextPageButton() {
    // 1. Selectors phổ biến
    const directSelectors = [
      'a.next:not(.disabled)',
      'li.next:not(.disabled) a',
      'a[rel="next"]',
      'button.next:not([disabled])',
      '.pagination a.next',
      '.paging a.next',
    ];
    for (const sel of directSelectors) {
      const el = document.querySelector(sel);
      if (el && isVisible(el)) return el;
    }
    // 2. Tìm theo text
    const candidates = $$('a, button, li');
    for (const el of candidates) {
      const t = txt(el);
      if (!t || t.length > 20) continue;
      if (/^(next|>|»|›|trang sau|sau)$/i.test(t)) {
        if (el.classList?.contains('disabled')) continue;
        if (el.hasAttribute && el.hasAttribute('disabled')) continue;
        const parent = el.closest('li');
        if (parent?.classList.contains('disabled')) continue;
        if (isVisible(el)) return el;
      }
    }
    return null;
  }

  function isVisible(el) {
    if (!el) return false;
    const r = el.getBoundingClientRect();
    return r.width > 0 && r.height > 0;
  }

  async function gotoNextPageAndWait(currentFirstId) {
    const next = findNextPageButton();
    if (!next) return false;
    next.click();
    // Đợi tới khi mã đầu tiên của bảng thay đổi (= sang trang mới)
    const start = Date.now();
    while (Date.now() - start < 10000) {
      await sleep(300);
      const t = findDataTable();
      if (t) {
        const rs = parseRows(t);
        if (rs.length > 0 && rs[0].o2bId !== currentFirstId) return true;
      }
    }
    return false;
  }

  // Tìm nút "Trang trước / Previous"
  function findPrevPageButton() {
    const directSelectors = [
      'a.prev:not(.disabled)', 'a.previous:not(.disabled)',
      'li.prev:not(.disabled) a', 'li.previous:not(.disabled) a',
      'a[rel="prev"]', 'button.prev:not([disabled])',
    ];
    for (const sel of directSelectors) {
      const el = document.querySelector(sel);
      if (el && isVisible(el)) return el;
    }
    const candidates = $$('a, button, li');
    for (const el of candidates) {
      const t = txt(el);
      if (!t || t.length > 20) continue;
      if (/^(previous|prev|<|«|‹|trang truoc|truoc)$/i.test(t.normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/đ/g, 'd'))) {
        if (el.classList?.contains('disabled')) continue;
        if (el.hasAttribute && el.hasAttribute('disabled')) continue;
        const parent = el.closest('li');
        if (parent?.classList.contains('disabled')) continue;
        if (isVisible(el)) return el;
      }
    }
    return null;
  }

  // Quay về trang đầu: click previous cho đến khi không còn được nữa
  async function gotoFirstPage(silent) {
    let safety = 0;
    while (safety++ < MAX_PAGES) {
      const prev = findPrevPageButton();
      if (!prev) break;
      const t = findDataTable();
      const currentFirstId = t ? (parseRows(t)[0]?.o2bId || '') : '';
      prev.click();
      const start = Date.now();
      let moved = false;
      while (Date.now() - start < 8000) {
        await sleep(300);
        const t2 = findDataTable();
        if (t2) {
          const rs = parseRows(t2);
          if (rs.length > 0 && rs[0].o2bId !== currentFirstId) { moved = true; break; }
        }
      }
      if (!moved) break;
      if (!silent) setBadge(`⏳ Về trang đầu (đã lùi ${safety})...`);
    }
  }

  async function runSync({ silent } = {}) {
    if (isRunning) return;
    isRunning = true;
    setBadge('⏳ Đếm số trang...');
    try {
      // BỎ QUA detect từ DOM — luôn dùng trạm cố định cấu hình ở FORCE_SENDER_STATION_KEY.
      // mapStation() sẽ tự tìm fullName tương ứng (vd. "01 - AN ĐÔNG") từ /api/nhap-hang/stations
      const senderStation = FORCE_SENDER_STATION_KEY;

      // Bước 1: ước lượng số trang từ DOM hiện tại
      // Nếu link pagination chỉ hiện 1 cửa sổ (vd. "previous 10 11 12 13 14"), max link sẽ là pn=14
      // nhưng có thể vẫn chưa đủ. Ta sẽ fetch tăng dần đến khi 1 trang trả 0 dòng.
      let estimatedMax = findMaxPageNumber();
      // Cộng thêm buffer 5 để chắc chắn không bỏ sót pages mới
      let probeMax = Math.min(estimatedMax + 5, MAX_PAGES);

      // Bước 2: fetch song song các trang (3 trang 1 lúc để không quá tải)
      const allRows = [];
      const batchSize = 3;
      let pagesFetched = 0;
      let stopAtPage = probeMax;
      for (let start = 1; start <= stopAtPage; start += batchSize) {
        const end = Math.min(start + batchSize - 1, stopAtPage);
        setBadge(`⏳ Tải trang ${start}–${end}/${stopAtPage}...`);
        const promises = [];
        for (let p = start; p <= end; p++) promises.push(fetchPageDom(p).then(d => ({ p, doc: d })));
        const results = await Promise.all(promises);
        for (const { p, doc } of results) {
          const t = findDataTable(doc);
          if (!t) { stopAtPage = Math.min(stopAtPage, p - 1); break; }
          const rs = parseRows(t);
          if (rs.length === 0) { stopAtPage = Math.min(stopAtPage, p - 1); break; }
          allRows.push(...rs);
          pagesFetched = Math.max(pagesFetched, p);
        }
      }

      // Nếu đã chạm tới cuối probeMax mà page cuối vẫn có dòng, có thể còn nữa → tiếp tục
      while (pagesFetched < MAX_PAGES) {
        const nextP = pagesFetched + 1;
        setBadge(`⏳ Kiểm tra trang ${nextP}...`);
        const doc = await fetchPageDom(nextP);
        const t = findDataTable(doc);
        if (!t) break;
        const rs = parseRows(t);
        if (rs.length === 0) break;
        allRows.push(...rs);
        pagesFetched = nextP;
      }

      if (allRows.length === 0) {
        const msg = `Không đọc được dòng nào (đã thử ${pagesFetched} trang).`;
        lastError = msg; GM_setValue('last_error', msg);
        if (!silent) alert(msg);
        return;
      }

      setBadge(`⏳ Đã đọc ${allRows.length} dòng từ ${pagesFetched} trang, đang lấy stations...`);
      const [stationsMap, existing] = await Promise.all([
        fetchStations(),
        fetchTodayProducts(todayYMD()),
      ]);
      const employee = getEmployeeName();

      let created = 0, updated = 0, skipped = 0, failed = 0;
      const errors = [];
      const pageIdx = pagesFetched;

      // Sort lại tất cả theo sendDate ASC để mã NhapHang đúng thứ tự
      allRows.sort((a, b) => a.sendDate < b.sendDate ? -1 : a.sendDate > b.sendDate ? 1 : 0);
      // Dedup theo o2bId (đề phòng pagination chồng lấp)
      const seen = new Set();
      const rows = [];
      for (const r of allRows) {
        if (seen.has(r.o2bId)) continue;
        seen.add(r.o2bId);
        rows.push(r);
      }

      setBadge(`⏳ POST ${rows.length} đơn (${pageIdx} trang)...`);

      for (const row of rows) {
        const payload = buildPayload(row, stationsMap, senderStation, employee);
        const hit = existing.get(row.o2bId);
        try {
          if (hit) {
            if (payloadsEqual(payload, hit)) { skipped++; continue; }
            const { status, body } = await gmRequest(
              'PUT',
              `${NHAPHANG_BASE}/api/nhap-hang/products/${encodeURIComponent(hit.id)}`,
              payload
            );
            if (status >= 200 && status < 300) updated++;
            else if (status === 403 && /quá 2 phút|qua 2 phut/i.test(body?.error || body?.message || '')) {
              // NhapHang khoá edit đơn cũ hơn 2 phút → coi như skip, không phải lỗi
              skipped++;
            }
            else { failed++; errors.push(`${row.o2bId}: PUT ${status} ${body?.error || ''}`); }
          } else {
            const { status, body } = await gmRequest(
              'POST',
              `${NHAPHANG_BASE}/api/nhap-hang/products`,
              payload
            );
            if (status >= 200 && status < 300) created++;
            else { failed++; errors.push(`${row.o2bId}: POST ${status} ${body?.error || ''}`); }
          }
        } catch (e) {
          failed++;
          errors.push(`${row.o2bId}: ${e.message || e}`);
        }
      }

      stats.created += created;
      stats.updated += updated;
      stats.skipped += skipped;
      stats.failed += failed;
      stats.lastAt = new Date();
      saveStats();
      if (failed === 0) { lastError = ''; GM_setValue('last_error', ''); }
      else { lastError = errors[0] || `${failed} đơn lỗi`; GM_setValue('last_error', lastError); }

      if (!silent) {
        const msg =
          `Lần này:\n` +
          `  Tạo mới: ${created}\n` +
          `  Cập nhật: ${updated}\n` +
          `  Không đổi: ${skipped}\n` +
          `  Lỗi: ${failed}` +
          (errors.length ? `\n\nChi tiết lỗi:\n` + errors.slice(0, 10).join('\n') : '');
        alert(msg);
      }
    } catch (e) {
      console.error('[O2B Sync]', e);
      lastError = e.message || String(e);
      GM_setValue('last_error', lastError);
      if (!silent) alert('Lỗi: ' + lastError);
    } finally {
      isRunning = false;
      renderBadge();
    }
  }

  // ===== UI =====
  let autoTimer = null;
  let reloadTimer = null;
  let syncWorker = null; // timer chạy trong Web Worker (không bị bóp nhịp khi tab nền)

  // Track lần cuối user gõ phím — chỉ skip reload nếu vừa gõ trong vòng 5s
  let lastInteractAt = 0;
  document.addEventListener('keydown', () => { lastInteractAt = Date.now(); }, true);
  document.addEventListener('input', () => { lastInteractAt = Date.now(); }, true);

  function userIsBusy() {
    return Date.now() - lastInteractAt < 5000;
  }

  // Reload trang (bỏ qua nếu user vừa gõ hoặc đang sync)
  function doAutoReload() {
    if (userIsBusy()) { console.log('[O2B Sync] Skip reload — user vừa gõ phím <5s'); return; }
    if (isRunning) { console.log('[O2B Sync] Skip reload — sync đang chạy'); return; }
    console.log('[O2B Sync] Auto reload trang...');
    GM_setValue('reload_pending_sync', Date.now());
    location.reload();
  }

  // Nhịp sync/reload chạy trong Web Worker → KHÔNG bị trình duyệt bóp khi tab ở nền
  // (setInterval thường bị hạ xuống ~1 lần/phút khi tab ẩn lâu). Tab vẫn phải mở.
  function startBackgroundTimers() {
    stopBackgroundTimers();
    try {
      const code =
        'setInterval(function(){postMessage("sync")},' + AUTO_INTERVAL_MS + ');' +
        'setInterval(function(){postMessage("reload")},' + AUTO_RELOAD_MS + ');';
      const blob = new Blob([code], { type: 'application/javascript' });
      syncWorker = new Worker(URL.createObjectURL(blob));
      syncWorker.onmessage = (e) => {
        if (e.data === 'sync') { if (!isRunning) runSync({ silent: true }); }
        else if (e.data === 'reload') { doAutoReload(); }
      };
      console.log('[O2B Sync] Timer chạy nền qua Web Worker (không bị bóp nhịp).');
    } catch (err) {
      console.warn('[O2B Sync] Worker lỗi, fallback setInterval (có thể bị bóp khi tab nền):', err);
      autoTimer = setInterval(() => { if (!isRunning) runSync({ silent: true }); }, AUTO_INTERVAL_MS);
      reloadTimer = setInterval(doAutoReload, AUTO_RELOAD_MS);
    }
  }

  function stopBackgroundTimers() {
    if (autoTimer) { clearInterval(autoTimer); autoTimer = null; }
    if (reloadTimer) { clearInterval(reloadTimer); reloadTimer = null; }
    if (syncWorker) { try { syncWorker.terminate(); } catch (e) {} syncWorker = null; }
  }

  function setBadge(t) {
    const el = document.getElementById('vcp-sync-badge');
    if (el) el.textContent = t;
  }

  function renderBadge() {
    const el = document.getElementById('vcp-sync-badge');
    if (!el) return;
    const isAuto = GM_getValue('auto_sync', false);
    const last = stats.lastAt ? `${stats.lastAt.toLocaleTimeString('vi-VN')}` : '—';
    const mode = isAuto ? `🟢 Auto nền (sync 20s, reload 60s)` : '⚪ Manual';
    let txt = `${mode} | last: ${last} | +${stats.created} ~${stats.updated} ✗${stats.failed}`;
    if (lastError) txt += `\n❌ ${lastError.slice(0, 80)}`;
    el.textContent = txt;
    el.style.whiteSpace = 'pre-line';
    el.title = lastError || '';
  }

  function setAuto(on) {
    GM_setValue('auto_sync', !!on);
    stopBackgroundTimers();
    if (on) {
      runSync({ silent: true });
      startBackgroundTimers();
    }
    renderBadge();
  }

  function injectButton() {
    if (document.getElementById('vcp-sync-wrap')) return;

    const Z = '2147483647'; // max int z-index
    const wrap = document.createElement('div');
    wrap.id = 'vcp-sync-wrap';
    wrap.style.cssText = `
      position: fixed !important;
      right: 20px !important;
      bottom: 20px !important;
      z-index: ${Z} !important;
      display: flex !important;
      flex-direction: column !important;
      gap: 8px !important;
      align-items: flex-end !important;
      font-family: system-ui, sans-serif !important;
      pointer-events: auto !important;
    `;

    const badge = document.createElement('div');
    badge.id = 'vcp-sync-badge';
    badge.style.cssText = `
      background: rgba(0,0,0,0.85) !important;
      color: #fff !important;
      padding: 6px 10px !important;
      border-radius: 6px !important;
      font-size: 12px !important;
      min-width: 200px !important;
      text-align: right !important;
      pointer-events: none !important;
    `;

    const btnRow = document.createElement('div');
    btnRow.style.cssText = `display: flex !important; gap: 8px !important; pointer-events: auto !important;`;

    const initAuto = GM_getValue('auto_sync', false);
    const autoBtn = document.createElement('button');
    autoBtn.type = 'button';
    autoBtn.textContent = initAuto ? '⏸ TẮT AUTO' : '▶ BẬT AUTO';
    autoBtn.style.cssText = `
      padding: 20px 26px !important;
      background: ${initAuto ? '#b91c1c' : '#2563eb'} !important;
      color: #fff !important;
      border: 0 !important;
      border-radius: 12px !important;
      cursor: pointer !important;
      font-weight: 800 !important;
      font-size: 16px !important;
      box-shadow: 0 6px 20px rgba(0,0,0,0.4) !important;
      pointer-events: auto !important;
      z-index: ${Z} !important;
      position: relative !important;
    `;
    autoBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      const next = !GM_getValue('auto_sync', false);
      setAuto(next);
      autoBtn.textContent = next ? '⏸ TẮT AUTO' : '▶ BẬT AUTO';
      autoBtn.style.setProperty('background', next ? '#b91c1c' : '#2563eb', 'important');
    }, true);

    const manualBtn = document.createElement('button');
    manualBtn.type = 'button';
    manualBtn.textContent = '🔄 SYNC NGAY';
    manualBtn.style.cssText = `
      padding: 20px 32px !important;
      background: #0a7d2e !important;
      color: #fff !important;
      border: 0 !important;
      border-radius: 12px !important;
      cursor: pointer !important;
      font-weight: 800 !important;
      font-size: 17px !important;
      letter-spacing: 0.5px !important;
      box-shadow: 0 6px 24px rgba(10,125,46,0.6) !important;
      pointer-events: auto !important;
      z-index: ${Z} !important;
      position: relative !important;
    `;
    // Capture phase + stopPropagation để bypass mọi handler khác chặn
    manualBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      runSync({ silent: false });
    }, true);
    manualBtn.addEventListener('mousedown', (e) => e.stopPropagation(), true);
    manualBtn.addEventListener('contextmenu', (e) => {
      e.preventDefault();
      e.stopPropagation();
      const cur = GM_getValue('employee_name', '');
      const next = prompt('Đổi tên nhân viên:', cur);
      if (next != null) GM_setValue('employee_name', next.trim() || cur);
    }, true);

    btnRow.appendChild(autoBtn);
    btnRow.appendChild(manualBtn);
    wrap.appendChild(badge);
    wrap.appendChild(btnRow);
    document.body.appendChild(wrap);

    renderBadge();
    if (initAuto) setAuto(true);
  }

  const obs = new MutationObserver(() => injectButton());
  obs.observe(document.documentElement, { childList: true, subtree: true });
  injectButton();

  // ===== Auto-login khi bị log out =====
  // Nếu trang hiện form login (có input password), đợi browser autofill rồi submit.
  // Cần: đã tick "Lưu mật khẩu" trong trình duyệt cho domain o2bsoft.
  async function tryAutoLogin() {
    const pwd = document.querySelector('input[type=password]');
    if (!pwd) return false;

    console.log('[O2B Sync] Phát hiện form login, đợi autofill...');
    setBadge('🔐 Đợi autofill login...');

    // Đợi tối đa 4s cho autofill điền vào ô password
    for (let i = 0; i < 16; i++) {
      await sleep(250);
      if (pwd.value && pwd.value.length > 0) break;
    }

    if (!pwd.value) {
      console.warn('[O2B Sync] Không có autofill — bỏ qua, user phải đăng nhập tay');
      lastError = 'Bị log out, cần đăng nhập tay (autofill trống)';
      GM_setValue('last_error', lastError);
      renderBadge();
      return true;
    }

    const form = pwd.closest('form');
    const submitBtn =
      form?.querySelector('button[type=submit], input[type=submit]') ||
      document.querySelector('button[type=submit], input[type=submit]');

    console.log('[O2B Sync] Autofill OK, submit form');
    if (submitBtn) submitBtn.click();
    else if (form) form.submit();
    return true;
  }

  // Chạy auto-login ngay khi script load (sau reload có thể đã bị log out)
  setTimeout(() => { tryAutoLogin(); }, 800);
})();
