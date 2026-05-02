import Link from 'next/link';

const APPS = [
  {
    title: 'Đặt Vé',
    desc: 'Khách hàng tự đặt vé online',
    href: 'https://vocucphuong.vercel.app',
    color: '#0ea5e9',
    icon: 'M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2',
    external: true,
  },
  {
    title: 'Tổng Hợp',
    desc: 'Quản lý vé khách, ghế ngồi, tài xế',
    href: '/tong-hop/index.html',
    color: '#2563eb',
    icon: 'M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z',
  },
  {
    title: 'Nhập Hàng',
    desc: 'Quản lý hàng hóa, bưu phẩm',
    href: '/nhap-hang/index.html',
    color: '#f97316',
    icon: 'M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4',
  },
];

export default function Home() {
  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'linear-gradient(135deg, #f8fafc 0%, #e0f2fe 100%)',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      padding: '24px'
    }}>
      <div style={{ textAlign: 'center', marginBottom: '40px' }}>
        <h1 style={{ fontSize: '32px', fontWeight: '700', color: '#0f172a', marginBottom: '8px' }}>
          CÔNG TY TNHH VÕ CÚC PHƯƠNG
        </h1>
        <p style={{ fontSize: '15px', color: '#64748b', margin: 0 }}>
          Cổng quản lý nội bộ — chọn ứng dụng để tiếp tục
        </p>
      </div>

      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
        gap: '20px',
        maxWidth: '880px',
        width: '100%',
        marginBottom: '40px'
      }}>
        {APPS.map(app => (
          <Link
            key={app.title}
            href={app.href}
            target={app.external ? '_blank' : undefined}
            rel={app.external ? 'noreferrer' : undefined}
            style={{
              background: '#fff',
              border: `2px solid ${app.color}`,
              borderRadius: '14px',
              padding: '24px',
              textDecoration: 'none',
              color: '#1e293b',
              boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              transition: 'transform 0.15s, box-shadow 0.15s',
            }}
          >
            <div style={{
              width: '56px', height: '56px', borderRadius: '14px',
              background: app.color, display: 'flex', alignItems: 'center', justifyContent: 'center',
              marginBottom: '14px',
            }}>
              <svg width="30" height="30" fill="none" stroke="white" strokeWidth={2} viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" d={app.icon} />
              </svg>
            </div>
            <div style={{ fontSize: '17px', fontWeight: 700, color: app.color, marginBottom: '4px' }}>
              {app.title}
            </div>
            <div style={{ fontSize: '12px', color: '#64748b', textAlign: 'center' }}>
              {app.desc}
            </div>
          </Link>
        ))}
      </div>

      <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', justifyContent: 'center' }}>
        <Link href="/dashboard" style={{
          padding: '10px 22px', fontSize: '13px', fontWeight: 600, color: '#fff',
          backgroundColor: '#0ea5e9', borderRadius: '8px', textDecoration: 'none',
        }}>
          Quản lý doanh thu
        </Link>
        <Link href="/admin/partners" style={{
          padding: '10px 22px', fontSize: '13px', fontWeight: 600, color: '#475569',
          background: '#fff', border: '1px solid #cbd5e1', borderRadius: '8px', textDecoration: 'none',
        }}>
          Đối tác (API)
        </Link>
      </div>

      <p style={{ marginTop: '36px', fontSize: '11px', color: '#94a3b8' }}>
        © Võ Cúc Phương · Hệ thống quản lý nội bộ
      </p>
    </div>
  );
}
