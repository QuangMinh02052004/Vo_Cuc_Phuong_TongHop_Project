import Link from 'next/link';

export default function Home() {
  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      backgroundColor: '#f8fafc',
      fontFamily: 'system-ui, -apple-system, sans-serif'
    }}>
      <h1 style={{
        fontSize: '28px',
        fontWeight: '700',
        color: '#1e40af',
        marginBottom: '40px',
        textAlign: 'center'
      }}>
        CÔNG TY TNHH VÕ CÚC PHƯƠNG
      </h1>

      {/* Main buttons */}
      <div style={{
        display: 'flex',
        gap: '20px',
        flexWrap: 'wrap',
        justifyContent: 'center',
        marginBottom: '30px'
      }}>
        <Link href="/nhap-hang/index.html" style={{
          padding: '16px 40px',
          fontSize: '16px',
          fontWeight: '600',
          color: '#2563eb',
          backgroundColor: '#fff',
          border: '2px solid #2563eb',
          borderRadius: '8px',
          textDecoration: 'none',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
          transition: 'all 0.2s'
        }}>
          Nhập Hàng
        </Link>

        <Link href="/tong-hop/index.html" style={{
          padding: '16px 40px',
          fontSize: '16px',
          fontWeight: '600',
          color: '#2563eb',
          backgroundColor: '#fff',
          border: '2px solid #2563eb',
          borderRadius: '8px',
          textDecoration: 'none',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
          transition: 'all 0.2s'
        }}>
          Tổng Hợp
        </Link>
      </div>

      {/* Dashboard link */}
      <Link href="/dashboard" style={{
        padding: '12px 30px',
        fontSize: '14px',
        fontWeight: '600',
        color: '#fff',
        backgroundColor: '#0ea5e9',
        border: 'none',
        borderRadius: '8px',
        textDecoration: 'none',
        boxShadow: '0 2px 8px rgba(14, 165, 233, 0.3)',
        display: 'flex',
        alignItems: 'center',
        gap: '8px'
      }}>
        <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
        Quản Lý Doanh Thu
      </Link>
    </div>
  );
}
