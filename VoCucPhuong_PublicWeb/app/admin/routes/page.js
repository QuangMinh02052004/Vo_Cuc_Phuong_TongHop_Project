'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

const ROUTE_TYPES = [
  { value: 'quoc_lo', label: 'Quốc lộ' },
  { value: 'cao_toc', label: 'Cao tốc' },
];

const BUS_TYPES = ['Ghế ngồi', 'Giường nằm', 'Limousine', 'VIP'];

const emptyRoute = {
  name: '',
  routeType: 'quoc_lo',
  fromStation: '',
  toStation: '',
  price: 0,
  duration: '',
  busType: 'Ghế ngồi',
  seats: 28,
  distance: '',
  operatingStart: '05:30',
  operatingEnd: '20:00',
  intervalMinutes: 30,
  isActive: true,
};

export default function AdminRoutesPage() {
  const [tab, setTab] = useState('routes');
  const [routes, setRoutes] = useState([]);
  const [vehicles, setVehicles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState(emptyRoute);
  const [vehicleForm, setVehicleForm] = useState({ code: '', type: 'Ghế ngồi 28 chỗ' });
  const [editingVehicle, setEditingVehicle] = useState(null);
  const [msg, setMsg] = useState('');

  async function loadRoutes() {
    setLoading(true);
    const res = await fetch('/api/admin/sync/routes');
    const data = await res.json();
    setRoutes(data.routes || []);
    setLoading(false);
  }

  async function loadVehicles() {
    setLoading(true);
    const res = await fetch('/api/admin/sync/vehicles');
    const data = await res.json();
    setVehicles(data.vehicles || []);
    setLoading(false);
  }

  useEffect(() => {
    if (tab === 'routes') loadRoutes();
    else loadVehicles();
  }, [tab]);

  function showMsg(text) {
    setMsg(text);
    setTimeout(() => setMsg(''), 3000);
  }

  async function saveRoute(e) {
    e.preventDefault();
    const url = editing ? `/api/admin/sync/routes/${editing}` : '/api/admin/sync/routes';
    const method = editing ? 'PUT' : 'POST';
    const res = await fetch(url, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form),
    });
    const data = await res.json();
    if (!res.ok) {
      showMsg('Lỗi: ' + (data.error || 'Không xác định'));
      return;
    }
    showMsg(
      `${editing ? 'Cập nhật' : 'Tạo'} thành công. ` +
      `DatVe: ${data.datveSynced ? 'OK' : 'CHƯA SYNC' + (data.datveError ? ' (' + data.datveError + ')' : '')}`
    );
    setEditing(null);
    setForm(emptyRoute);
    loadRoutes();
  }

  async function deleteRoute(id, name) {
    if (!confirm(`Xóa tuyến "${name}"? Tuyến trên DatVe sẽ bị tắt (is_active=false).`)) return;
    const res = await fetch(`/api/admin/sync/routes/${id}`, { method: 'DELETE' });
    const data = await res.json();
    if (!res.ok) return showMsg('Lỗi: ' + data.error);
    showMsg(`Đã xóa. DatVe: ${data.datveSynced ? 'tắt OK' : 'không sync'}`);
    loadRoutes();
  }

  function startEditRoute(r) {
    setEditing(r.id);
    setForm({
      name: r.name || '',
      routeType: r.routeType || 'quoc_lo',
      fromStation: r.fromStation || '',
      toStation: r.toStation || '',
      price: r.price || 0,
      duration: r.duration || '',
      busType: r.busType || 'Ghế ngồi',
      seats: r.seats || 28,
      distance: r.distance || '',
      operatingStart: r.operatingStart || '05:30',
      operatingEnd: r.operatingEnd || '20:00',
      intervalMinutes: r.intervalMinutes || 30,
      isActive: r.isActive !== false,
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function cancelEdit() {
    setEditing(null);
    setForm(emptyRoute);
  }

  async function saveVehicle(e) {
    e.preventDefault();
    const url = editingVehicle ? `/api/admin/sync/vehicles/${editingVehicle}` : '/api/admin/sync/vehicles';
    const method = editingVehicle ? 'PUT' : 'POST';
    const res = await fetch(url, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(vehicleForm),
    });
    const data = await res.json();
    if (!res.ok) return showMsg('Lỗi: ' + data.error);
    showMsg(editingVehicle ? 'Cập nhật xe OK' : 'Tạo xe OK');
    setEditingVehicle(null);
    setVehicleForm({ code: '', type: 'Ghế ngồi 28 chỗ' });
    loadVehicles();
  }

  async function deleteVehicle(id, code) {
    if (!confirm(`Xóa xe ${code}?`)) return;
    const res = await fetch(`/api/admin/sync/vehicles/${id}`, { method: 'DELETE' });
    if (!res.ok) return showMsg('Lỗi xóa');
    showMsg('Đã xóa');
    loadVehicles();
  }


  return (
    <div style={S.page}>
      <div style={S.container}>
        <div style={S.header}>
          <h1 style={S.title}>Quản lý Tuyến & Xe (đồng bộ TongHop + DatVe)</h1>
          <Link href="/dashboard" style={S.backLink}>Về Dashboard</Link>
        </div>

        {msg && <div style={S.msg}>{msg}</div>}

        <div style={S.tabs}>
          <button
            onClick={() => setTab('routes')}
            style={{ ...S.tab, ...(tab === 'routes' ? S.tabActive : {}) }}
          >
            Tuyến đường ({routes.length})
          </button>
          <button
            onClick={() => setTab('vehicles')}
            style={{ ...S.tab, ...(tab === 'vehicles' ? S.tabActive : {}) }}
          >
            Xe ({vehicles.length})
          </button>
        </div>

        {tab === 'routes' && (
          <>
            <div style={S.card}>
              <h2 style={S.subtitle}>{editing ? 'Sửa tuyến' : 'Thêm tuyến'}</h2>
              <form onSubmit={saveRoute} style={S.formGrid}>
                <Field label="Tên tuyến *">
                  <input
                    style={S.input}
                    value={form.name}
                    onChange={(e) => setForm({ ...form, name: e.target.value })}
                    placeholder="VD: Sài Gòn - Xuân Lộc (Cao tốc)"
                    required
                  />
                </Field>
                <Field label="Loại tuyến">
                  <select
                    style={S.input}
                    value={form.routeType}
                    onChange={(e) => setForm({ ...form, routeType: e.target.value })}
                  >
                    {ROUTE_TYPES.map((t) => <option key={t.value} value={t.value}>{t.label}</option>)}
                  </select>
                </Field>
                <Field label="Trạm đi *">
                  <input style={S.input} value={form.fromStation}
                    onChange={(e) => setForm({ ...form, fromStation: e.target.value })} required />
                </Field>
                <Field label="Trạm đến *">
                  <input style={S.input} value={form.toStation}
                    onChange={(e) => setForm({ ...form, toStation: e.target.value })} required />
                </Field>
                <Field label="Giá vé (VND)">
                  <input type="number" style={S.input} value={form.price}
                    onChange={(e) => setForm({ ...form, price: Number(e.target.value) })} />
                </Field>
                <Field label="Thời gian">
                  <input style={S.input} value={form.duration}
                    onChange={(e) => setForm({ ...form, duration: e.target.value })} placeholder="VD: 4 giờ" />
                </Field>
                <Field label="Loại xe">
                  <select style={S.input} value={form.busType}
                    onChange={(e) => setForm({ ...form, busType: e.target.value })}>
                    {BUS_TYPES.map((t) => <option key={t} value={t}>{t}</option>)}
                  </select>
                </Field>
                <Field label="Số ghế">
                  <input type="number" style={S.input} value={form.seats}
                    onChange={(e) => setForm({ ...form, seats: Number(e.target.value) })} />
                </Field>
                <Field label="Khoảng cách">
                  <input style={S.input} value={form.distance}
                    onChange={(e) => setForm({ ...form, distance: e.target.value })} placeholder="VD: 80km" />
                </Field>
                <Field label="Khung giờ bắt đầu">
                  <input type="time" style={S.input} value={form.operatingStart}
                    onChange={(e) => setForm({ ...form, operatingStart: e.target.value })} />
                </Field>
                <Field label="Khung giờ kết thúc">
                  <input type="time" style={S.input} value={form.operatingEnd}
                    onChange={(e) => setForm({ ...form, operatingEnd: e.target.value })} />
                </Field>
                <Field label="Cách nhau (phút)">
                  <input type="number" style={S.input} value={form.intervalMinutes}
                    onChange={(e) => setForm({ ...form, intervalMinutes: Number(e.target.value) })} />
                </Field>
                <Field label="Trạng thái">
                  <label style={{ display: 'flex', alignItems: 'center', gap: 8, paddingTop: 8 }}>
                    <input type="checkbox" checked={form.isActive}
                      onChange={(e) => setForm({ ...form, isActive: e.target.checked })} />
                    Đang hoạt động
                  </label>
                </Field>
                <div style={{ gridColumn: '1 / -1', display: 'flex', gap: 12 }}>
                  <button type="submit" style={S.btnPrimary}>{editing ? 'Cập nhật' : 'Thêm tuyến'}</button>
                  {editing && <button type="button" onClick={cancelEdit} style={S.btnSecondary}>Hủy</button>}
                </div>
              </form>
            </div>

            <div style={S.card}>
              <h2 style={S.subtitle}>Danh sách tuyến</h2>
              {loading ? <p>Đang tải...</p> : (
                <table style={S.table}>
                  <thead>
                    <tr>
                      <th style={S.th}>Tên</th>
                      <th style={S.th}>Trạm đi</th>
                      <th style={S.th}>Trạm đến</th>
                      <th style={S.th}>Giá</th>
                      <th style={S.th}>Loại xe</th>
                      <th style={S.th}>Trạng thái</th>
                      <th style={S.th}>Sync DatVe</th>
                      <th style={S.th}>Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    {routes.map((r) => (
                      <tr key={r.id}>
                        <td style={S.td}>{r.name}</td>
                        <td style={S.td}>{r.fromStation}</td>
                        <td style={S.td}>{r.toStation}</td>
                        <td style={S.td}>{Number(r.price || 0).toLocaleString('vi-VN')}đ</td>
                        <td style={S.td}>{r.busType}</td>
                        <td style={S.td}>{r.isActive ? 'Hoạt động' : 'Tạm ngừng'}</td>
                        <td style={S.td}>{r.datveRouteId ? 'Đã link' : 'Chưa'}</td>
                        <td style={S.td}>
                          <button onClick={() => startEditRoute(r)} style={S.btnEdit}>Sửa</button>
                          <button onClick={() => deleteRoute(r.id, r.name)} style={S.btnDanger}>Xóa</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          </>
        )}

        {tab === 'vehicles' && (
          <>
            <div style={S.card}>
              <h2 style={S.subtitle}>{editingVehicle ? 'Sửa xe' : 'Thêm xe'}</h2>
              <form onSubmit={saveVehicle} style={S.formGrid}>
                <Field label="Biển số *">
                  <input style={S.input} value={vehicleForm.code}
                    onChange={(e) => setVehicleForm({ ...vehicleForm, code: e.target.value })}
                    placeholder="VD: 60B-04669" required />
                </Field>
                <Field label="Loại xe">
                  <select style={S.input} value={vehicleForm.type}
                    onChange={(e) => setVehicleForm({ ...vehicleForm, type: e.target.value })}>
                    <option>Ghế ngồi 28 chỗ</option>
                    <option>Limousine 9 chỗ</option>
                    <option>Limousine 11 chỗ</option>
                    <option>Giường nằm 40 chỗ</option>
                  </select>
                </Field>
                <div style={{ gridColumn: '1 / -1', display: 'flex', gap: 12 }}>
                  <button type="submit" style={S.btnPrimary}>{editingVehicle ? 'Cập nhật' : 'Thêm xe'}</button>
                  {editingVehicle && (
                    <button type="button" onClick={() => { setEditingVehicle(null); setVehicleForm({ code: '', type: 'Ghế ngồi 28 chỗ' }); }} style={S.btnSecondary}>Hủy</button>
                  )}
                </div>
              </form>
            </div>

            <div style={S.card}>
              <h2 style={S.subtitle}>Danh sách xe</h2>
              {loading ? <p>Đang tải...</p> : (
                <table style={S.table}>
                  <thead>
                    <tr>
                      <th style={S.th}>Biển số</th>
                      <th style={S.th}>Loại</th>
                      <th style={S.th}>Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    {vehicles.map((v) => (
                      <tr key={v.id}>
                        <td style={S.td}>{v.code}</td>
                        <td style={S.td}>{v.type}</td>
                        <td style={S.td}>
                          <button onClick={() => { setEditingVehicle(v.id); setVehicleForm({ code: v.code, type: v.type }); window.scrollTo({ top: 0, behavior: 'smooth' }); }} style={S.btnEdit}>Sửa</button>
                          <button onClick={() => deleteVehicle(v.id, v.code)} style={S.btnDanger}>Xóa</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          </>
        )}
      </div>
    </div>
  );
}

function Field({ label, children }) {
  return (
    <label style={{ display: 'flex', flexDirection: 'column', gap: 4 }}>
      <span style={{ fontSize: 13, color: '#475569', fontWeight: 500 }}>{label}</span>
      {children}
    </label>
  );
}

const S = {
  page: { minHeight: '100vh', backgroundColor: '#f8fafc', fontFamily: 'system-ui, -apple-system, sans-serif', padding: '24px 16px' },
  container: { maxWidth: 1200, margin: '0 auto' },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 },
  title: { fontSize: 22, fontWeight: 700, color: '#0f172a', margin: 0 },
  backLink: { color: '#475569', textDecoration: 'none', fontSize: 14 },
  msg: { padding: '10px 14px', backgroundColor: '#f0f9ff', border: '1px solid #bae6fd', color: '#075985', borderRadius: 6, marginBottom: 12, fontSize: 14 },
  tabs: { display: 'flex', gap: 4, marginBottom: 16, borderBottom: '1px solid #e2e8f0' },
  tab: { padding: '10px 16px', backgroundColor: 'transparent', border: 'none', borderBottom: '2px solid transparent', cursor: 'pointer', color: '#64748b', fontSize: 14, fontWeight: 500 },
  tabActive: { color: '#0f172a', borderBottomColor: '#0f172a' },
  card: { backgroundColor: '#fff', border: '1px solid #e2e8f0', borderRadius: 6, padding: 20, marginBottom: 16 },
  subtitle: { fontSize: 16, fontWeight: 600, color: '#0f172a', margin: '0 0 14px 0' },
  formGrid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 12 },
  input: { padding: '8px 10px', border: '1px solid #cbd5e1', borderRadius: 4, fontSize: 14, fontFamily: 'inherit', width: '100%', boxSizing: 'border-box' },
  btnPrimary: { padding: '9px 18px', backgroundColor: '#0f172a', color: '#fff', border: 'none', borderRadius: 4, cursor: 'pointer', fontSize: 14, fontWeight: 500 },
  btnSecondary: { padding: '9px 18px', backgroundColor: '#fff', color: '#475569', border: '1px solid #cbd5e1', borderRadius: 4, cursor: 'pointer', fontSize: 14 },
  btnEdit: { padding: '5px 10px', backgroundColor: '#fff', color: '#0f172a', border: '1px solid #cbd5e1', borderRadius: 4, cursor: 'pointer', fontSize: 13, marginRight: 6 },
  btnDanger: { padding: '5px 10px', backgroundColor: '#fff', color: '#dc2626', border: '1px solid #fca5a5', borderRadius: 4, cursor: 'pointer', fontSize: 13 },
  table: { width: '100%', borderCollapse: 'collapse', fontSize: 14 },
  th: { textAlign: 'left', padding: '8px 10px', borderBottom: '1px solid #e2e8f0', color: '#64748b', fontWeight: 600, fontSize: 13 },
  td: { padding: '8px 10px', borderBottom: '1px solid #f1f5f9', color: '#0f172a' },
};
