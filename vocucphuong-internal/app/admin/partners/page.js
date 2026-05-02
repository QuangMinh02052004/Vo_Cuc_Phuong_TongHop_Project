'use client';

import { useState, useEffect } from 'react';

const API = '/api/tong-hop/partners';

export default function PartnersPage() {
  const [partners, setPartners] = useState([]);
  const [name, setName] = useState('');
  const [scopes, setScopes] = useState({ read: true, write: false });
  const [creating, setCreating] = useState(false);
  const [newKey, setNewKey] = useState(null);

  const load = async () => {
    const res = await fetch(API);
    const data = await res.json();
    setPartners(data.partners || []);
  };

  useEffect(() => { load(); }, []);

  const create = async (e) => {
    e.preventDefault();
    setCreating(true);
    const sc = Object.entries(scopes).filter(([_, v]) => v).map(([k]) => k);
    const res = await fetch(API, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name, scopes: sc.length ? sc : ['read'] }),
    });
    const data = await res.json();
    setCreating(false);
    if (data.partner) {
      setNewKey(data.partner);
      setName('');
      load();
    } else {
      alert(data.error || 'Lỗi');
    }
  };

  const toggleActive = async (p) => {
    await fetch(API, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: p.id, active: !p.active }),
    });
    load();
  };

  const remove = async (p) => {
    if (!confirm(`Xóa khóa của "${p.name}"?`)) return;
    await fetch(`${API}?id=${p.id}`, { method: 'DELETE' });
    load();
  };

  const styles = {
    page: { minHeight: '100vh', background: '#f8fafc', fontFamily: 'system-ui, -apple-system, sans-serif', padding: '24px' },
    container: { maxWidth: '1000px', margin: '0 auto' },
    h1: { fontSize: '24px', fontWeight: 700, color: '#0f172a', marginBottom: '8px' },
    sub: { color: '#64748b', marginBottom: '24px' },
    card: { background: '#fff', borderRadius: '12px', padding: '20px', boxShadow: '0 1px 3px rgba(0,0,0,0.05)', marginBottom: '16px', border: '1px solid #e2e8f0' },
    input: { padding: '8px 12px', border: '1px solid #cbd5e1', borderRadius: '6px', fontSize: '14px' },
    btn: { padding: '8px 16px', background: '#0ea5e9', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer', fontWeight: 600, fontSize: '13px' },
    btnGhost: { padding: '6px 12px', background: '#fff', color: '#475569', border: '1px solid #cbd5e1', borderRadius: '6px', cursor: 'pointer', fontSize: '12px' },
    btnDanger: { padding: '6px 12px', background: '#fee2e2', color: '#b91c1c', border: '1px solid #fecaca', borderRadius: '6px', cursor: 'pointer', fontSize: '12px' },
    table: { width: '100%', borderCollapse: 'collapse', fontSize: '13px' },
    th: { background: '#f1f5f9', textAlign: 'left', padding: '8px 10px', borderBottom: '1px solid #e2e8f0', fontSize: '11px', textTransform: 'uppercase', color: '#64748b' },
    td: { padding: '8px 10px', borderBottom: '1px solid #f1f5f9' },
    code: { background: '#0f172a', color: '#10b981', padding: '6px 10px', borderRadius: '4px', fontSize: '12px', fontFamily: 'ui-monospace, monospace', wordBreak: 'break-all' },
  };

  return (
    <div style={styles.page}>
      <div style={styles.container}>
        <a href="/" style={{ color: '#0ea5e9', fontSize: '13px', textDecoration: 'none' }}>← Về cổng chính</a>
        <h1 style={styles.h1}>Quản lý đối tác (API)</h1>
        <p style={styles.sub}>Tạo API key cho đối tác để truy cập public API: timeslots, bookings, routes</p>

        {newKey && (
          <div style={{ ...styles.card, background: '#f0fdf4', border: '1px solid #bbf7d0' }}>
            <div style={{ fontWeight: 600, color: '#15803d', marginBottom: '8px' }}>API key mới — sao chép ngay (không hiện lại)</div>
            <div style={styles.code}>{newKey.apiKey}</div>
            <button onClick={() => { navigator.clipboard.writeText(newKey.apiKey); alert('Đã copy'); }} style={{ ...styles.btn, marginTop: '8px' }}>Copy</button>
            <button onClick={() => setNewKey(null)} style={{ ...styles.btnGhost, marginTop: '8px', marginLeft: '8px' }}>Đóng</button>
          </div>
        )}

        <div style={styles.card}>
          <h3 style={{ marginTop: 0, fontSize: '16px' }}>Tạo API key mới</h3>
          <form onSubmit={create} style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', alignItems: 'center' }}>
            <input
              required
              placeholder="Tên đối tác"
              value={name}
              onChange={(e) => setName(e.target.value)}
              style={{ ...styles.input, flex: 1, minWidth: '200px' }}
            />
            <label style={{ fontSize: '13px' }}>
              <input type="checkbox" checked={scopes.read} onChange={(e) => setScopes(s => ({ ...s, read: e.target.checked }))} /> read
            </label>
            <label style={{ fontSize: '13px' }}>
              <input type="checkbox" checked={scopes.write} onChange={(e) => setScopes(s => ({ ...s, write: e.target.checked }))} /> write
            </label>
            <button type="submit" disabled={creating} style={styles.btn}>
              {creating ? 'Đang tạo...' : 'Tạo'}
            </button>
          </form>
        </div>

        <div style={styles.card}>
          <h3 style={{ marginTop: 0, fontSize: '16px' }}>Danh sách đối tác</h3>
          <table style={styles.table}>
            <thead>
              <tr>
                <th style={styles.th}>Tên</th>
                <th style={styles.th}>API Key (rút gọn)</th>
                <th style={styles.th}>Scopes</th>
                <th style={styles.th}>Trạng thái</th>
                <th style={styles.th}>Lần dùng cuối</th>
                <th style={styles.th}>Hành động</th>
              </tr>
            </thead>
            <tbody>
              {partners.map(p => (
                <tr key={p.id}>
                  <td style={styles.td}><strong>{p.name}</strong></td>
                  <td style={styles.td}><code style={{ fontSize: '11px' }}>{p.apiKey.slice(0, 16)}...</code></td>
                  <td style={styles.td}>{(p.scopes || []).join(', ')}</td>
                  <td style={styles.td}>
                    <span style={{ color: p.active ? '#15803d' : '#dc2626', fontWeight: 600 }}>
                      {p.active ? 'Hoạt động' : 'Đã khóa'}
                    </span>
                  </td>
                  <td style={styles.td}>{p.lastUsedAt ? new Date(p.lastUsedAt).toLocaleString('vi-VN') : 'Chưa dùng'}</td>
                  <td style={styles.td}>
                    <button onClick={() => toggleActive(p)} style={styles.btnGhost}>
                      {p.active ? 'Khóa' : 'Mở'}
                    </button>
                    <button onClick={() => remove(p)} style={{ ...styles.btnDanger, marginLeft: '6px' }}>Xóa</button>
                  </td>
                </tr>
              ))}
              {partners.length === 0 && (
                <tr><td colSpan={6} style={{ ...styles.td, textAlign: 'center', color: '#94a3b8' }}>Chưa có đối tác</td></tr>
              )}
            </tbody>
          </table>
        </div>

        <div style={styles.card}>
          <h3 style={{ marginTop: 0, fontSize: '16px' }}>Tài liệu API</h3>
          <pre style={{ background: '#0f172a', color: '#e2e8f0', padding: '16px', borderRadius: '8px', overflowX: 'auto', fontSize: '12px' }}>
{`# Mọi request cần header: X-API-Key: <key>

GET  /api/public/v1/routes
GET  /api/public/v1/timeslots?date=DD-MM-YYYY&route=<route>
POST /api/public/v1/bookings
     Body: { timeSlotId, seatNumber, name, phone, amount, dropoffMethod?, dropoffAddress?, note? }
GET  /api/public/v1/bookings?phone=<phone>
GET  /api/public/v1/bookings?id=<bookingId>

# Scopes: read | write`}
          </pre>
        </div>
      </div>
    </div>
  );
}
