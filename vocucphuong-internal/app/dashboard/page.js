'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

// Format tiền VND
function formatCurrency(amount) {
  return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);
}

// Format số ngắn gọn (1.5M, 500K)
function formatShortCurrency(amount) {
  if (amount >= 1000000000) return `${(amount / 1000000000).toFixed(1)}B`;
  if (amount >= 1000000) return `${(amount / 1000000).toFixed(1)}M`;
  if (amount >= 1000) return `${(amount / 1000).toFixed(0)}K`;
  return amount.toString();
}

// Format ngày
function formatDate(dateStr) {
  if (!dateStr) return '';
  if (dateStr.includes('-') && dateStr.split('-')[0].length === 2) {
    const [day, month, year] = dateStr.split('-');
    return `${day}/${month}`;
  }
  const d = new Date(dateStr);
  return `${d.getDate()}/${d.getMonth() + 1}`;
}

// Format datetime
function formatDateTime(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  return d.toLocaleString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}

// Export to CSV
function exportToCSV(stats) {
  if (!stats) return;
  const lines = [];
  lines.push(['BÁO CÁO DOANH THU - CÔNG TY TNHH VÕ CÚC PHƯƠNG']);
  lines.push([`Kỳ báo cáo: ${stats.dateRange?.label || ''}`]);
  lines.push([]);
  lines.push(['TỔNG QUAN']);
  lines.push(['Tổng doanh thu', stats.summary?.totalRevenue || 0]);
  lines.push(['Doanh thu Nhập Hàng', stats.summary?.nhapHangRevenue || 0]);
  lines.push(['Doanh thu Hành Khách', stats.summary?.tongHopRevenue || 0]);
  lines.push(['Doanh thu Đặt Vé Online', stats.summary?.datVeRevenue || 0]);
  lines.push([]);
  lines.push(['NHẬP HÀNG THEO TRẠM']);
  lines.push(['Trạm', 'Số đơn', 'Doanh thu']);
  (stats.nhapHang?.byStation || []).forEach(item => {
    lines.push([item.station, item.orderCount, item.revenue]);
  });
  lines.push([]);
  lines.push(['HÀNH KHÁCH THEO TUYẾN']);
  lines.push(['Tuyến', 'Số vé', 'Doanh thu']);
  (stats.tongHop?.byRoute || []).forEach(item => {
    lines.push([item.route || 'Không xác định', item.bookingCount, item.revenue]);
  });
  lines.push([]);
  lines.push(['ĐẶT VÉ ONLINE THEO TUYẾN']);
  lines.push(['Tuyến', 'Số vé', 'Doanh thu']);
  (stats.datVe?.byRoute || []).forEach(item => {
    lines.push([item.route || 'Không xác định', item.bookingCount, item.revenue]);
  });
  const csvContent = lines.map(row => row.join(',')).join('\n');
  const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = `bao-cao-doanh-thu-${stats.dateRange?.from || 'all'}.csv`;
  link.click();
}

// Styles
const styles = {
  container: { minHeight: '100vh', backgroundColor: '#f8fafc', fontFamily: 'system-ui, -apple-system, sans-serif' },
  header: { backgroundColor: '#fff', borderBottom: '1px solid #e2e8f0', padding: '16px 24px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' },
  headerLeft: { display: 'flex', alignItems: 'center', gap: '16px' },
  backBtn: { color: '#0284c7', textDecoration: 'none', fontSize: '20px' },
  title: { fontSize: '20px', fontWeight: '700', color: '#1e293b', margin: 0 },
  exportBtn: { display: 'flex', alignItems: 'center', gap: '8px', padding: '10px 16px', backgroundColor: '#10b981', color: '#fff', border: 'none', borderRadius: '8px', fontSize: '14px', fontWeight: '600', cursor: 'pointer' },
  main: { maxWidth: '1400px', margin: '0 auto', padding: '24px' },
  filters: { backgroundColor: '#fff', borderRadius: '12px', padding: '16px', marginBottom: '24px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)', display: 'flex', flexWrap: 'wrap', alignItems: 'center', gap: '12px' },
  filterLabel: { fontSize: '14px', fontWeight: '500', color: '#64748b' },
  periodBtns: { display: 'flex', borderRadius: '8px', overflow: 'hidden', border: '1px solid #e2e8f0' },
  periodBtn: { padding: '8px 16px', fontSize: '14px', fontWeight: '500', border: 'none', cursor: 'pointer', transition: 'all 0.2s' },
  periodBtnActive: { backgroundColor: '#0284c7', color: '#fff' },
  periodBtnInactive: { backgroundColor: '#fff', color: '#475569' },
  dateInput: { padding: '8px 12px', border: '1px solid #e2e8f0', borderRadius: '8px', fontSize: '14px', outline: 'none' },
  quickDateBtn: { padding: '6px 12px', fontSize: '12px', fontWeight: '500', border: '1px solid #e2e8f0', borderRadius: '6px', cursor: 'pointer', backgroundColor: '#fff', color: '#475569', transition: 'all 0.2s' },
  quickDateBtnActive: { backgroundColor: '#0284c7', color: '#fff', borderColor: '#0284c7' },
  cardsGrid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '24px' },
  card: { backgroundColor: '#fff', borderRadius: '12px', padding: '20px', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' },
  cardBlue: { background: 'linear-gradient(135deg, #0284c7, #0369a1)', color: '#fff' },
  cardHeader: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' },
  cardLabel: { fontSize: '14px', fontWeight: '500', opacity: 0.8 },
  cardValue: { fontSize: '24px', fontWeight: '700' },
  cardSubtext: { fontSize: '13px', marginTop: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
  changePositive: { color: '#10b981', fontSize: '12px', display: 'flex', alignItems: 'center', gap: '4px' },
  changeNegative: { color: '#ef4444', fontSize: '12px', display: 'flex', alignItems: 'center', gap: '4px' },
  detailsGrid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(380px, 1fr))', gap: '24px' },
  section: { backgroundColor: '#fff', borderRadius: '12px', overflow: 'hidden', boxShadow: '0 1px 3px rgba(0,0,0,0.1)' },
  sectionHeaderGreen: { backgroundColor: '#f0f9ff', padding: '12px 20px', borderBottom: '1px solid #bae6fd' },
  sectionHeaderBlue: { backgroundColor: '#f0f9ff', padding: '12px 20px', borderBottom: '1px solid #bae6fd' },
  sectionHeaderPurple: { backgroundColor: '#f0f9ff', padding: '12px 20px', borderBottom: '1px solid #bae6fd' },
  sectionHeaderOrange: { backgroundColor: '#f0f9ff', padding: '12px 20px', borderBottom: '1px solid #bae6fd' },
  sectionTitle: { fontSize: '16px', fontWeight: '700', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' },
  sectionBody: { padding: '20px' },
  statsRow: { display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '12px', marginBottom: '16px' },
  statsRow2: { display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '12px', marginBottom: '16px' },
  statsRow4: { display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '12px', marginBottom: '16px' },
  statBox: { textAlign: 'center', padding: '12px', backgroundColor: '#f8fafc', borderRadius: '8px' },
  statBoxGreen: { backgroundColor: '#ecfdf5' },
  statBoxYellow: { backgroundColor: '#fef3c7' },
  statBoxBlue: { backgroundColor: '#f0f9ff' },
  statBoxPurple: { backgroundColor: '#faf5ff' },
  statValue: { fontSize: '18px', fontWeight: '700', color: '#1e293b' },
  statValueGreen: { color: '#059669' },
  statValueYellow: { color: '#d97706' },
  statValueBlue: { color: '#0284c7' },
  statValuePurple: { color: '#7c3aed' },
  statLabel: { fontSize: '12px', color: '#64748b', marginTop: '4px' },
  paymentRow: { display: 'flex', justifyContent: 'space-between', padding: '12px', backgroundColor: '#f0f9ff', borderRadius: '8px', marginBottom: '16px' },
  listTitle: { fontSize: '14px', fontWeight: '600', color: '#475569', marginBottom: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
  listItem: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 12px', backgroundColor: '#f8fafc', borderRadius: '6px', marginBottom: '8px', cursor: 'pointer', transition: 'all 0.2s', border: '1px solid transparent' },
  listItemName: { fontSize: '14px', color: '#334155', flex: 1 },
  listItemCount: { fontSize: '13px', color: '#64748b', marginRight: '12px' },
  listItemValue: { fontSize: '14px', fontWeight: '600' },
  listItemValueGreen: { color: '#059669' },
  listItemValueBlue: { color: '#0284c7' },
  listItemValuePurple: { color: '#7c3aed' },
  emptyText: { textAlign: 'center', color: '#94a3b8', padding: '20px' },
  loading: { display: 'flex', justifyContent: 'center', alignItems: 'center', padding: '60px' },
  spinner: { width: '40px', height: '40px', border: '4px solid #e2e8f0', borderTop: '4px solid #0284c7', borderRadius: '50%', animation: 'spin 1s linear infinite' },
  footer: { textAlign: 'center', padding: '20px', fontSize: '14px', color: '#64748b', borderTop: '1px solid #e2e8f0', backgroundColor: '#fff', marginTop: '40px' },
  modalOverlay: { position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, backgroundColor: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000, padding: '20px' },
  modalContent: { backgroundColor: '#fff', borderRadius: '16px', width: '100%', maxWidth: '1000px', maxHeight: '85vh', overflow: 'hidden', boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)' },
  modalHeader: { padding: '20px 24px', borderBottom: '1px solid #e2e8f0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
  modalTitle: { fontSize: '18px', fontWeight: '700', color: '#1e293b', margin: 0 },
  modalCloseBtn: { background: 'none', border: 'none', fontSize: '24px', cursor: 'pointer', color: '#64748b', padding: '4px' },
  modalBody: { padding: '20px 24px', maxHeight: 'calc(85vh - 140px)', overflowY: 'auto' },
  modalFooter: { padding: '16px 24px', borderTop: '1px solid #e2e8f0', textAlign: 'right' },
  table: { width: '100%', borderCollapse: 'collapse', fontSize: '13px' },
  th: { padding: '10px 6px', textAlign: 'left', fontWeight: '600', color: '#475569', borderBottom: '2px solid #e2e8f0', backgroundColor: '#f8fafc', whiteSpace: 'nowrap' },
  td: { padding: '10px 6px', borderBottom: '1px solid #f1f5f9', color: '#334155' },
  badge: { display: 'inline-block', padding: '3px 6px', borderRadius: '4px', fontSize: '11px', fontWeight: '600' },
  badgeGreen: { backgroundColor: '#dcfce7', color: '#166534' },
  badgeYellow: { backgroundColor: '#fef3c7', color: '#92400e' },
  badgeRed: { backgroundColor: '#fee2e2', color: '#991b1b' },
  badgeBlue: { backgroundColor: '#dbeafe', color: '#1e40af' },
  badgePurple: { backgroundColor: '#f3e8ff', color: '#6b21a8' },
  viewAllBtn: { fontSize: '12px', color: '#0284c7', cursor: 'pointer', textDecoration: 'underline' },
  // Progress bar
  progressBar: { width: '100%', height: '8px', backgroundColor: '#e2e8f0', borderRadius: '4px', overflow: 'hidden', marginTop: '8px' },
  progressFill: { height: '100%', borderRadius: '4px', transition: 'width 0.5s ease' },
  // Mini chart
  chartContainer: { display: 'flex', alignItems: 'flex-end', gap: '4px', height: '80px', padding: '10px 0' },
  chartBar: { flex: 1, borderRadius: '4px 4px 0 0', transition: 'height 0.3s ease', cursor: 'pointer', minWidth: '20px' },
  chartLabel: { fontSize: '10px', color: '#94a3b8', textAlign: 'center', marginTop: '4px' },
};

// Default monthly target (có thể set qua localStorage)
const DEFAULT_TARGET = 50000000; // 50 triệu / tháng

export default function DashboardPage() {
  const [period, setPeriod] = useState('week');
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [quickDate, setQuickDate] = useState('7days');
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [modalType, setModalType] = useState(null);
  const [modalTitle, setModalTitle] = useState('');
  const [modalData, setModalData] = useState([]);
  const [modalLoading, setModalLoading] = useState(false);
  const [modalSearch, setModalSearch] = useState('');
  const [monthlyTarget, setMonthlyTarget] = useState(DEFAULT_TARGET);
  const [showTargetEdit, setShowTargetEdit] = useState(false);

  // Quick date shortcuts
  const quickDates = [
    { key: 'today', label: 'Hôm nay', period: 'day', getDate: () => new Date().toISOString().split('T')[0] },
    { key: 'yesterday', label: 'Hôm qua', period: 'day', getDate: () => { const d = new Date(); d.setDate(d.getDate() - 1); return d.toISOString().split('T')[0]; } },
    { key: '7days', label: '7 ngày', period: 'week', getDate: () => new Date().toISOString().split('T')[0] },
    { key: '30days', label: '30 ngày', period: 'month', getDate: () => new Date().toISOString().split('T')[0] },
  ];

  const handleQuickDate = (qd) => {
    setQuickDate(qd.key);
    setPeriod(qd.period);
    setSelectedDate(qd.getDate());
  };

  useEffect(() => {
    // Load target from localStorage
    const savedTarget = localStorage.getItem('revenueTarget');
    if (savedTarget) setMonthlyTarget(Number(savedTarget));
  }, []);

  useEffect(() => {
    const loadStats = async () => {
      setLoading(true);
      try {
        const res = await fetch(`/api/stats?period=${period}&date=${selectedDate}`);
        const data = await res.json();
        if (data.success) setStats(data);
      } catch (error) {
        console.error('Error loading stats:', error);
      } finally {
        setLoading(false);
      }
    };
    loadStats();
  }, [period, selectedDate]);

  const loadOrderDetails = async (type, filter = {}) => {
    setModalLoading(true);
    setModalOpen(true);
    setModalType(type);
    try {
      const params = new URLSearchParams();
      params.append('type', type);
      if (stats?.dateRange?.from && stats?.dateRange?.to) {
        params.append('fromDate', stats.dateRange.from);
        params.append('toDate', stats.dateRange.to);
      }
      if (filter.station) {
        params.append('station', filter.station);
        setModalTitle(`Chi tiết đơn hàng - ${filter.station}`);
      } else if (filter.route) {
        params.append('route', filter.route);
        setModalTitle(`Chi tiết ${type === 'datve' ? 'đặt vé online' : 'vé'} - ${filter.route}`);
      } else if (filter.date) {
        params.append('date', filter.date);
        setModalTitle(`Chi tiết ${type === 'datve' ? 'đặt vé online' : 'vé'} - ${filter.date}`);
      } else {
        setModalTitle(type === 'nhaphang' ? 'Tất cả đơn Nhập Hàng' : type === 'datve' ? 'Tất cả Đặt Vé Online' : 'Tất cả vé Hành Khách');
      }
      const res = await fetch(`/api/stats/orders?${params.toString()}`);
      const data = await res.json();
      setModalData(data.success ? (data.data || []) : []);
    } catch (error) {
      console.error('Error loading details:', error);
      setModalData([]);
    } finally {
      setModalLoading(false);
    }
  };

  const closeModal = () => { setModalOpen(false); setModalData([]); setModalType(null); setModalSearch(''); };

  const filteredModalData = modalData.filter(item => {
    if (!modalSearch.trim()) return true;
    const search = modalSearch.toLowerCase();
    if (modalType === 'nhaphang') {
      return (item.senderName?.toLowerCase()?.includes(search) || item.receiverName?.toLowerCase()?.includes(search) || item.senderPhone?.includes(search) || item.receiverPhone?.includes(search) || item.station?.toLowerCase()?.includes(search) || item.id?.toString().includes(search));
    } else if (modalType === 'datve') {
      return (item.customer_name?.toLowerCase()?.includes(search) || item.customer_phone?.includes(search) || item.booking_code?.toLowerCase()?.includes(search) || item.route?.toLowerCase()?.includes(search));
    } else {
      return (item.name?.toLowerCase()?.includes(search) || item.phone?.includes(search) || item.route?.toLowerCase()?.includes(search) || item.seatNumber?.toString().includes(search));
    }
  });

  const modalTotals = filteredModalData.reduce((acc, item) => {
    if (modalType === 'nhaphang') {
      acc.total += Number(item.totalAmount) || 0;
      acc.paid += item.paymentStatus === 'paid' ? (Number(item.totalAmount) || 0) : 0;
    } else if (modalType === 'datve') {
      acc.total += Number(item.total_price) || 0;
      acc.paid += Number(item.paid_amount) || 0;
    } else {
      acc.total += Number(item.amount) || 0;
      acc.paid += Number(item.paid) || 0;
    }
    return acc;
  }, { total: 0, paid: 0 });

  const exportModalToCSV = () => {
    if (filteredModalData.length === 0) return;
    const lines = [];
    if (modalType === 'nhaphang') {
      lines.push(['Mã đơn', 'Thời gian', 'Người gửi', 'SĐT gửi', 'Người nhận', 'SĐT nhận', 'Trạm', 'Loại hàng', 'Số tiền', 'Thanh toán', 'Trạng thái']);
      filteredModalData.forEach(o => { lines.push([o.id, o.sendDate, o.senderName || '', o.senderPhone || '', o.receiverName || '', o.receiverPhone || '', o.station, o.productType || '', o.totalAmount || 0, o.paymentStatus, o.status]); });
    } else if (modalType === 'datve') {
      lines.push(['Mã đặt vé', 'Ngày', 'Giờ', 'Tuyến', 'Họ tên', 'SĐT', 'Email', 'Số ghế', 'Số tiền', 'Đã thanh toán', 'Trạng thái']);
      filteredModalData.forEach(b => { lines.push([b.booking_code || '', b.date || '', b.departure_time || '', b.route || '', b.customer_name || '', b.customer_phone || '', b.customer_email || '', b.seats || '', b.total_price || 0, b.paid_amount || 0, b.status || '']); });
    } else {
      lines.push(['ID', 'Ngày', 'Giờ', 'Tuyến', 'Họ tên', 'SĐT', 'Ghế', 'Điểm đón', 'Điểm trả', 'Số tiền', 'Đã thu']);
      filteredModalData.forEach(b => { lines.push([b.id, b.date, b.timeSlot, b.route, b.name || '', b.phone || '', b.seatNumber || '', b.pickupAddress || '', b.dropoffAddress || '', b.amount || 0, b.paid || 0]); });
    }
    const csvContent = lines.map(row => row.map(cell => `"${String(cell).replace(/"/g, '""')}"`).join(',')).join('\n');
    const blob = new Blob(['\uFEFF' + csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `chi-tiet-${modalType}-${new Date().toISOString().split('T')[0]}.csv`;
    link.click();
  };

  const saveTarget = (value) => {
    const num = Number(value);
    if (num > 0) {
      setMonthlyTarget(num);
      localStorage.setItem('revenueTarget', num.toString());
    }
    setShowTargetEdit(false);
  };

  // Calculate KPIs
  const totalOrders = (stats?.summary?.totalOrders || 0) + (stats?.summary?.totalPassengers || 0) + (stats?.summary?.totalOnlineBookings || 0);
  const avgOrderValue = totalOrders > 0 ? Math.round((stats?.summary?.totalRevenue || 0) / totalOrders) : 0;
  const paidAmount = (stats?.nhapHang?.overview?.paidAmount || 0) + (stats?.tongHop?.overview?.paidAmount || 0) + (stats?.datVe?.overview?.paidAmount || 0);
  const totalAmount = stats?.summary?.totalRevenue || 0;
  const paymentRate = totalAmount > 0 ? Math.round((paidAmount / totalAmount) * 100) : 0;

  // Target progress (adjusted for period)
  const daysInPeriod = period === 'day' ? 1 : period === 'week' ? 7 : 30;
  const targetForPeriod = Math.round(monthlyTarget * daysInPeriod / 30);
  const targetProgress = targetForPeriod > 0 ? Math.min(100, Math.round((totalAmount / targetForPeriod) * 100)) : 0;

  // Get chart data
  const chartData = [];
  if (stats?.nhapHang?.byDate || stats?.tongHop?.byDate || stats?.datVe?.byDate) {
    const nhDates = stats?.nhapHang?.byDate || [];
    const thDates = stats?.tongHop?.byDate || [];
    const dvDates = stats?.datVe?.byDate || [];
    const allDates = new Map();
    nhDates.forEach(d => {
      const key = d.date?.split('T')[0] || d.date;
      allDates.set(key, (allDates.get(key) || 0) + Number(d.revenue || 0));
    });
    thDates.forEach(d => {
      const key = d.date;
      allDates.set(key, (allDates.get(key) || 0) + Number(d.revenue || 0));
    });
    dvDates.forEach(d => {
      const key = d.date?.split('T')[0] || d.date;
      allDates.set(key, (allDates.get(key) || 0) + Number(d.revenue || 0));
    });
    Array.from(allDates.entries()).slice(-7).forEach(([date, revenue]) => {
      chartData.push({ date, revenue });
    });
  }
  const maxRevenue = Math.max(...chartData.map(d => d.revenue), 1);

  const ChangeIndicator = ({ change, light }) => {
    if (change === undefined || change === null) return null;
    const isPositive = change >= 0;
    const style = light ? { ...styles.changePositive, color: isPositive ? '#bae6fd' : '#fca5a5' } : (isPositive ? styles.changePositive : styles.changeNegative);
    return <span style={style}>{isPositive ? '↑' : '↓'} {isPositive ? '+' : ''}{change}%</span>;
  };

  const PaymentBadge = ({ status }) => {
    const isPaid = status === 'paid';
    return <span style={{ ...styles.badge, ...(isPaid ? styles.badgeGreen : styles.badgeRed) }}>{isPaid ? 'Đã TT' : 'Chưa TT'}</span>;
  };

  const StatusBadge = ({ status }) => {
    const map = { pending: { label: 'Chờ xử lý', style: styles.badgeYellow }, processing: { label: 'Đang xử lý', style: styles.badgeBlue }, delivered: { label: 'Đã giao', style: styles.badgeGreen }, cancelled: { label: 'Đã hủy', style: styles.badgeRed } };
    const cfg = map[status] || { label: status, style: styles.badgeYellow };
    return <span style={{ ...styles.badge, ...cfg.style }}>{cfg.label}</span>;
  };

  const DatVeStatusBadge = ({ status }) => {
    const map = { pending: { label: 'Chờ xác nhận', style: styles.badgeYellow }, confirmed: { label: 'Đã xác nhận', style: styles.badgeGreen }, cancelled: { label: 'Đã hủy', style: styles.badgeRed }, completed: { label: 'Hoàn thành', style: styles.badgePurple } };
    const cfg = map[status] || { label: status || 'Không rõ', style: styles.badgeYellow };
    return <span style={{ ...styles.badge, ...cfg.style }}>{cfg.label}</span>;
  };

  const ClickableItem = ({ onClick, children }) => {
    const [hover, setHover] = useState(false);
    return (
      <div style={{ ...styles.listItem, ...(hover ? { backgroundColor: '#e0f2fe', borderColor: '#0284c7' } : {}) }} onMouseEnter={() => setHover(true)} onMouseLeave={() => setHover(false)} onClick={onClick} title="Bấm để xem chi tiết">
        {children}
        <span style={{ marginLeft: '8px', color: '#0284c7', fontSize: '12px' }}>→</span>
      </div>
    );
  };

  // Mini bar chart component
  const MiniChart = ({ data }) => {
    const [hoveredBar, setHoveredBar] = useState(null);
    if (data.length === 0) return <div style={styles.emptyText}>Chưa có dữ liệu</div>;
    return (
      <div>
        <div style={styles.chartContainer}>
          {data.map((item, idx) => (
            <div key={idx} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
              <div
                style={{
                  ...styles.chartBar,
                  height: `${Math.max(5, (item.revenue / maxRevenue) * 100)}%`,
                  backgroundColor: hoveredBar === idx ? '#0284c7' : '#93c5fd',
                  width: '100%'
                }}
                onMouseEnter={() => setHoveredBar(idx)}
                onMouseLeave={() => setHoveredBar(null)}
                title={`${formatDate(item.date)}: ${formatCurrency(item.revenue)}`}
              />
            </div>
          ))}
        </div>
        <div style={{ display: 'flex', gap: '4px' }}>
          {data.map((item, idx) => (
            <div key={idx} style={{ flex: 1, ...styles.chartLabel }}>{formatDate(item.date)}</div>
          ))}
        </div>
        {hoveredBar !== null && (
          <div style={{ textAlign: 'center', marginTop: '8px', fontSize: '13px', color: '#0284c7', fontWeight: '600' }}>
            {formatDate(data[hoveredBar].date)}: {formatCurrency(data[hoveredBar].revenue)}
          </div>
        )}
      </div>
    );
  };

  return (
    <div style={styles.container}>
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      <header style={styles.header}>
        <div style={styles.headerLeft}>
          <Link href="/" style={styles.backBtn}>← </Link>
          <h1 style={styles.title}>📊 Quản Lý Doanh Thu</h1>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          {stats && <button style={styles.exportBtn} onClick={() => exportToCSV(stats)}>↓ Xuất Báo Cáo</button>}
          <span style={{ fontSize: '14px', color: '#64748b' }}>CÔNG TY TNHH VÕ CÚC PHƯƠNG</span>
        </div>
      </header>

      <main style={styles.main}>
        {/* Filters */}
        <div style={styles.filters}>
          <span style={styles.filterLabel}>Nhanh:</span>
          <div style={{ display: 'flex', gap: '8px' }}>
            {quickDates.map(qd => (
              <button key={qd.key} onClick={() => handleQuickDate(qd)} style={{ ...styles.quickDateBtn, ...(quickDate === qd.key ? styles.quickDateBtnActive : {}) }}>{qd.label}</button>
            ))}
          </div>
          <span style={{ ...styles.filterLabel, marginLeft: '16px' }}>Xem theo:</span>
          <div style={styles.periodBtns}>
            {[{ value: 'day', label: 'Ngày' }, { value: 'week', label: 'Tuần' }, { value: 'month', label: 'Tháng' }].map(opt => (
              <button key={opt.value} onClick={() => { setPeriod(opt.value); setQuickDate(''); }} style={{ ...styles.periodBtn, ...(period === opt.value ? styles.periodBtnActive : styles.periodBtnInactive) }}>{opt.label}</button>
            ))}
          </div>
          <input type="date" value={selectedDate} onChange={(e) => { setSelectedDate(e.target.value); setQuickDate(''); }} style={styles.dateInput} />
          {stats && <span style={{ marginLeft: 'auto', fontSize: '14px', color: '#64748b', fontWeight: '500' }}>📅 {stats.dateRange?.label}</span>}
        </div>

        {loading ? (
          <div style={styles.loading}><div style={styles.spinner}></div></div>
        ) : stats ? (
          <>
            {/* Summary Cards */}
            <div style={styles.cardsGrid}>
              <div style={{ ...styles.card, ...styles.cardBlue }}>
                <div style={styles.cardHeader}><span style={styles.cardLabel}>💰 Tổng Doanh Thu</span></div>
                <div style={styles.cardValue}>{formatCurrency(stats.summary?.totalRevenue || 0)}</div>
                <div style={styles.cardSubtext}>
                  <span style={{ opacity: 0.8 }}>so với {stats.prevDateRange?.label}</span>
                  <ChangeIndicator change={stats.summary?.totalRevenueChange} light />
                </div>
              </div>
              <div style={{ ...styles.card, cursor: 'pointer' }} onClick={() => loadOrderDetails('nhaphang')} title="Bấm để xem chi tiết">
                <div style={styles.cardHeader}>
                  <span style={{ ...styles.cardLabel, color: '#64748b' }}>📦 Nhập Hàng</span>
                  <span style={{ fontSize: '11px', color: '#0284c7' }}>Chi tiết →</span>
                </div>
                <div style={{ ...styles.cardValue, color: '#1e293b' }}>{formatCurrency(stats.summary?.nhapHangRevenue || 0)}</div>
                <div style={styles.cardSubtext}>
                  <span style={{ color: '#64748b' }}>{stats.summary?.totalOrders || 0} đơn</span>
                  <ChangeIndicator change={stats.summary?.nhapHangRevenueChange} />
                </div>
              </div>
              <div style={{ ...styles.card, cursor: 'pointer' }} onClick={() => loadOrderDetails('tonghop')} title="Bấm để xem chi tiết">
                <div style={styles.cardHeader}>
                  <span style={{ ...styles.cardLabel, color: '#64748b' }}>🚌 Hành Khách</span>
                  <span style={{ fontSize: '11px', color: '#0284c7' }}>Chi tiết →</span>
                </div>
                <div style={{ ...styles.cardValue, color: '#1e293b' }}>{formatCurrency(stats.summary?.tongHopRevenue || 0)}</div>
                <div style={styles.cardSubtext}>
                  <span style={{ color: '#64748b' }}>{stats.summary?.totalPassengers || 0} khách</span>
                  <ChangeIndicator change={stats.summary?.tongHopRevenueChange} />
                </div>
              </div>
              <div style={{ ...styles.card, cursor: 'pointer' }} onClick={() => loadOrderDetails('datve')} title="Bấm để xem chi tiết">
                <div style={styles.cardHeader}>
                  <span style={{ ...styles.cardLabel, color: '#64748b' }}>🎫 Đặt Vé Online</span>
                  <span style={{ fontSize: '11px', color: '#0284c7' }}>Chi tiết →</span>
                </div>
                <div style={{ ...styles.cardValue, color: '#1e293b' }}>{formatCurrency(stats.summary?.datVeRevenue || 0)}</div>
                <div style={styles.cardSubtext}>
                  <span style={{ color: '#64748b' }}>{stats.summary?.totalOnlineBookings || 0} vé</span>
                  <ChangeIndicator change={stats.summary?.datVeRevenueChange} />
                </div>
              </div>
              <div style={styles.card}>
                <div style={styles.cardHeader}><span style={{ ...styles.cardLabel, color: '#64748b' }}>📈 Giao Dịch</span></div>
                <div style={{ ...styles.cardValue, color: '#1e293b' }}>{totalOrders + (stats.summary?.totalOnlineBookings || 0)}</div>
                <div style={styles.cardSubtext}><span style={{ color: '#64748b' }}>trong kỳ báo cáo</span></div>
              </div>
            </div>

            {/* Chart Section */}
            {chartData.length > 1 && (
              <div style={{ ...styles.section, marginBottom: '24px' }}>
                <div style={styles.sectionHeaderBlue}>
                  <h2 style={{ ...styles.sectionTitle, color: '#0284c7' }}>📈 Biểu Đồ Doanh Thu</h2>
                </div>
                <div style={styles.sectionBody}>
                  <MiniChart data={chartData} />
                </div>
              </div>
            )}

            {/* Details Grid */}
            <div style={styles.detailsGrid}>
              <div style={styles.section}>
                <div style={styles.sectionHeaderBlue}><h2 style={{ ...styles.sectionTitle, color: '#0284c7' }}>📦 Chi Tiết Nhập Hàng</h2></div>
                <div style={styles.sectionBody}>
                  <div style={styles.statsRow}>
                    <div style={styles.statBox}><div style={styles.statValue}>{stats.nhapHang?.overview?.totalOrders || 0}</div><div style={styles.statLabel}>Tổng đơn</div></div>
                    <div style={{ ...styles.statBox, ...styles.statBoxBlue }}><div style={{ ...styles.statValue, ...styles.statValueBlue }}>{stats.nhapHang?.overview?.deliveredOrders || 0}</div><div style={styles.statLabel}>Đã giao</div></div>
                    <div style={styles.statBox}><div style={styles.statValue}>{stats.nhapHang?.overview?.pendingOrders || 0}</div><div style={styles.statLabel}>Chờ xử lý</div></div>
                  </div>
                  <div style={styles.paymentRow}>
                    <div><div style={{ fontSize: '13px', color: '#64748b' }}>Đã thanh toán</div><div style={{ fontWeight: '700', color: '#0284c7' }}>{formatCurrency(stats.nhapHang?.overview?.paidAmount || 0)}</div></div>
                    <div style={{ textAlign: 'right' }}><div style={{ fontSize: '13px', color: '#64748b' }}>Chưa thanh toán</div><div style={{ fontWeight: '700', color: '#64748b' }}>{formatCurrency(stats.nhapHang?.overview?.unpaidAmount || 0)}</div></div>
                  </div>
                  <div style={styles.listTitle}><span>Theo Trạm</span><span style={styles.viewAllBtn} onClick={() => loadOrderDetails('nhaphang')}>Xem tất cả</span></div>
                  <div style={{ maxHeight: '200px', overflowY: 'auto' }}>
                    {stats.nhapHang?.byStation?.length > 0 ? stats.nhapHang.byStation.map((item, idx) => (
                      <ClickableItem key={idx} onClick={() => loadOrderDetails('nhaphang', { station: item.station })}>
                        <span style={styles.listItemName}>{item.station}</span>
                        <span style={styles.listItemCount}>{item.orderCount} đơn</span>
                        <span style={{ ...styles.listItemValue, ...styles.listItemValueBlue }}>{formatCurrency(item.revenue)}</span>
                      </ClickableItem>
                    )) : <div style={styles.emptyText}>Chưa có dữ liệu</div>}
                  </div>
                </div>
              </div>

              <div style={styles.section}>
                <div style={styles.sectionHeaderBlue}><h2 style={{ ...styles.sectionTitle, color: '#0284c7' }}>🚌 Chi Tiết Hành Khách</h2></div>
                <div style={styles.sectionBody}>
                  <div style={styles.statsRow2}>
                    <div style={styles.statBox}><div style={styles.statValue}>{stats.tongHop?.overview?.totalBookings || 0}</div><div style={styles.statLabel}>Tổng booking</div></div>
                    <div style={{ ...styles.statBox, ...styles.statBoxBlue }}><div style={{ ...styles.statValue, ...styles.statValueBlue }}>{formatCurrency(stats.tongHop?.overview?.paidAmount || 0)}</div><div style={styles.statLabel}>Đã thu</div></div>
                  </div>
                  <div style={styles.listTitle}><span>Theo Tuyến</span><span style={styles.viewAllBtn} onClick={() => loadOrderDetails('tonghop')}>Xem tất cả</span></div>
                  <div style={{ marginBottom: '16px' }}>
                    {stats.tongHop?.byRoute?.length > 0 ? stats.tongHop.byRoute.map((item, idx) => (
                      <ClickableItem key={idx} onClick={() => loadOrderDetails('tonghop', { route: item.route })}>
                        <span style={styles.listItemName}>{item.route || 'Không xác định'}</span>
                        <span style={styles.listItemCount}>{item.bookingCount} vé</span>
                        <span style={{ ...styles.listItemValue, ...styles.listItemValueBlue }}>{formatCurrency(item.revenue)}</span>
                      </ClickableItem>
                    )) : <div style={styles.emptyText}>Chưa có dữ liệu</div>}
                  </div>
                  <div style={styles.listTitle}><span>Theo Ngày</span></div>
                  <div style={{ maxHeight: '150px', overflowY: 'auto' }}>
                    {stats.tongHop?.byDate?.length > 0 ? stats.tongHop.byDate.map((item, idx) => (
                      <ClickableItem key={idx} onClick={() => loadOrderDetails('tonghop', { date: item.date })}>
                        <span style={styles.listItemName}>{formatDate(item.date)}</span>
                        <span style={styles.listItemCount}>{item.bookingCount} booking</span>
                        <span style={{ ...styles.listItemValue, ...styles.listItemValueBlue }}>{formatCurrency(item.revenue)}</span>
                      </ClickableItem>
                    )) : <div style={styles.emptyText}>Chưa có dữ liệu</div>}
                  </div>
                </div>
              </div>

              <div style={styles.section}>
                <div style={styles.sectionHeaderBlue}><h2 style={{ ...styles.sectionTitle, color: '#0284c7' }}>🎫 Chi Tiết Đặt Vé Online</h2></div>
                <div style={styles.sectionBody}>
                  <div style={styles.statsRow}>
                    <div style={styles.statBox}><div style={styles.statValue}>{stats.datVe?.overview?.totalBookings || 0}</div><div style={styles.statLabel}>Tổng vé</div></div>
                    <div style={{ ...styles.statBox, ...styles.statBoxBlue }}><div style={{ ...styles.statValue, ...styles.statValueBlue }}>{stats.datVe?.overview?.confirmedBookings || 0}</div><div style={styles.statLabel}>Đã xác nhận</div></div>
                    <div style={styles.statBox}><div style={styles.statValue}>{stats.datVe?.overview?.pendingBookings || 0}</div><div style={styles.statLabel}>Chờ xử lý</div></div>
                  </div>
                  <div style={styles.paymentRow}>
                    <div><div style={{ fontSize: '13px', color: '#64748b' }}>Tổng doanh thu</div><div style={{ fontWeight: '700', color: '#0284c7' }}>{formatCurrency(stats.datVe?.overview?.totalRevenue || 0)}</div></div>
                    <div style={{ textAlign: 'right' }}><div style={{ fontSize: '13px', color: '#64748b' }}>Đã thanh toán</div><div style={{ fontWeight: '700', color: '#059669' }}>{formatCurrency(stats.datVe?.overview?.paidAmount || 0)}</div></div>
                  </div>
                  <div style={styles.listTitle}><span>Theo Tuyến</span><span style={styles.viewAllBtn} onClick={() => loadOrderDetails('datve')}>Xem tất cả</span></div>
                  <div style={{ marginBottom: '16px' }}>
                    {stats.datVe?.byRoute?.length > 0 ? stats.datVe.byRoute.map((item, idx) => (
                      <ClickableItem key={idx} onClick={() => loadOrderDetails('datve', { route: item.route })}>
                        <span style={styles.listItemName}>{item.route || 'Không xác định'}</span>
                        <span style={styles.listItemCount}>{item.bookingCount} vé</span>
                        <span style={{ ...styles.listItemValue, ...styles.listItemValueBlue }}>{formatCurrency(item.revenue)}</span>
                      </ClickableItem>
                    )) : <div style={styles.emptyText}>Chưa có dữ liệu</div>}
                  </div>
                  <div style={styles.listTitle}><span>Theo Ngày</span></div>
                  <div style={{ maxHeight: '150px', overflowY: 'auto' }}>
                    {stats.datVe?.byDate?.length > 0 ? stats.datVe.byDate.map((item, idx) => (
                      <ClickableItem key={idx} onClick={() => loadOrderDetails('datve', { date: item.date })}>
                        <span style={styles.listItemName}>{formatDate(item.date)}</span>
                        <span style={styles.listItemCount}>{item.bookingCount} vé</span>
                        <span style={{ ...styles.listItemValue, ...styles.listItemValueBlue }}>{formatCurrency(item.revenue)}</span>
                      </ClickableItem>
                    )) : <div style={styles.emptyText}>Chưa có dữ liệu</div>}
                  </div>
                </div>
              </div>
            </div>
          </>
        ) : <div style={styles.emptyText}>Không thể tải dữ liệu</div>}
      </main>

      <footer style={styles.footer}>Hệ thống quản lý nội bộ - CÔNG TY TNHH VÕ CÚC PHƯƠNG</footer>

      {/* Modal */}
      {modalOpen && (
        <div style={styles.modalOverlay} onClick={closeModal}>
          <div style={styles.modalContent} onClick={(e) => e.stopPropagation()}>
            <div style={styles.modalHeader}>
              <h3 style={styles.modalTitle}>{modalTitle}</h3>
              <button style={styles.modalCloseBtn} onClick={closeModal}>×</button>
            </div>
            {!modalLoading && modalData.length > 0 && (
              <div style={{ padding: '12px 24px', borderBottom: '1px solid #e2e8f0', display: 'flex', gap: '12px', alignItems: 'center', flexWrap: 'wrap' }}>
                <input
                  type="text"
                  placeholder={modalType === 'nhaphang' ? 'Tìm theo tên, SĐT, trạm, mã đơn...' : modalType === 'datve' ? 'Tìm theo mã đặt vé, tên, SĐT, tuyến...' : 'Tìm theo tên, SĐT, tuyến, ghế...'}
                  value={modalSearch}
                  onChange={(e) => setModalSearch(e.target.value)}
                  style={{ flex: 1, minWidth: '200px', padding: '8px 12px', border: '1px solid #e2e8f0', borderRadius: '8px', fontSize: '14px', outline: 'none' }}
                />
                <button onClick={exportModalToCSV} style={{ padding: '8px 16px', backgroundColor: '#10b981', color: '#fff', border: 'none', borderRadius: '8px', fontSize: '13px', fontWeight: '600', cursor: 'pointer' }}>↓ Xuất CSV</button>
              </div>
            )}
            <div style={styles.modalBody}>
              {modalLoading ? <div style={styles.loading}><div style={styles.spinner}></div></div> : filteredModalData.length === 0 ? <div style={styles.emptyText}>{modalSearch ? 'Không tìm thấy kết quả' : 'Không có dữ liệu'}</div> : modalType === 'nhaphang' ? (
                <table style={styles.table}>
                  <thead>
                    <tr>
                      <th style={styles.th}>Mã đơn</th>
                      <th style={styles.th}>Thời gian</th>
                      <th style={styles.th}>Người gửi</th>
                      <th style={styles.th}>Người nhận</th>
                      <th style={styles.th}>Trạm nhận</th>
                      <th style={styles.th}>Loại hàng</th>
                      <th style={styles.th}>Số tiền</th>
                      <th style={styles.th}>TT toán</th>
                      <th style={styles.th}>Trạng thái</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredModalData.map((o, idx) => (
                      <tr key={idx}>
                        <td style={{ ...styles.td, fontWeight: '600', fontFamily: 'monospace' }}>{o.id}</td>
                        <td style={styles.td}>{formatDateTime(o.sendDate)}</td>
                        <td style={styles.td}><div>{o.senderName || '-'}</div><div style={{ fontSize: '11px', color: '#64748b' }}>{o.senderPhone || ''}</div></td>
                        <td style={styles.td}><div>{o.receiverName || '-'}</div><div style={{ fontSize: '11px', color: '#64748b' }}>{o.receiverPhone || ''}</div></td>
                        <td style={styles.td}>{o.station}</td>
                        <td style={styles.td}>{o.productType || '-'}</td>
                        <td style={{ ...styles.td, fontWeight: '600', color: '#059669' }}>{formatCurrency(o.totalAmount || 0)}</td>
                        <td style={styles.td}><PaymentBadge status={o.paymentStatus} /></td>
                        <td style={styles.td}><StatusBadge status={o.status} /></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              ) : modalType === 'datve' ? (
                <table style={styles.table}>
                  <thead>
                    <tr>
                      <th style={styles.th}>Mã đặt vé</th>
                      <th style={styles.th}>Ngày</th>
                      <th style={styles.th}>Giờ</th>
                      <th style={styles.th}>Tuyến</th>
                      <th style={styles.th}>Khách hàng</th>
                      <th style={styles.th}>SĐT</th>
                      <th style={styles.th}>Số ghế</th>
                      <th style={styles.th}>Số tiền</th>
                      <th style={styles.th}>Đã TT</th>
                      <th style={styles.th}>Trạng thái</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredModalData.map((b, idx) => (
                      <tr key={idx}>
                        <td style={{ ...styles.td, fontWeight: '600', fontFamily: 'monospace', color: '#7c3aed' }}>{b.booking_code || '-'}</td>
                        <td style={styles.td}>{b.date || '-'}</td>
                        <td style={styles.td}>{b.departure_time || '-'}</td>
                        <td style={{ ...styles.td, fontSize: '11px' }}>{b.route || '-'}</td>
                        <td style={styles.td}><div>{b.customer_name || '-'}</div><div style={{ fontSize: '11px', color: '#64748b' }}>{b.customer_email || ''}</div></td>
                        <td style={styles.td}>{b.customer_phone || '-'}</td>
                        <td style={{ ...styles.td, textAlign: 'center' }}><span style={{ ...styles.badge, ...styles.badgePurple }}>{b.seats || '-'}</span></td>
                        <td style={{ ...styles.td, fontWeight: '600', color: '#7c3aed' }}>{formatCurrency(b.total_price || 0)}</td>
                        <td style={{ ...styles.td, fontWeight: '600', color: '#059669' }}>{formatCurrency(b.paid_amount || 0)}</td>
                        <td style={styles.td}><DatVeStatusBadge status={b.status} /></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              ) : (
                <table style={styles.table}>
                  <thead>
                    <tr>
                      <th style={styles.th}>ID</th>
                      <th style={styles.th}>Ngày</th>
                      <th style={styles.th}>Giờ</th>
                      <th style={styles.th}>Tuyến</th>
                      <th style={styles.th}>Hành khách</th>
                      <th style={styles.th}>SĐT</th>
                      <th style={styles.th}>Ghế</th>
                      <th style={styles.th}>Đón/Trả</th>
                      <th style={styles.th}>Số tiền</th>
                      <th style={styles.th}>Đã thu</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredModalData.map((b, idx) => (
                      <tr key={idx}>
                        <td style={{ ...styles.td, fontFamily: 'monospace' }}>{b.id}</td>
                        <td style={styles.td}>{b.date}</td>
                        <td style={styles.td}>{b.timeSlot}</td>
                        <td style={{ ...styles.td, fontSize: '11px' }}>{b.route}</td>
                        <td style={styles.td}>{b.name || '-'}</td>
                        <td style={styles.td}>{b.phone || '-'}</td>
                        <td style={{ ...styles.td, textAlign: 'center' }}><span style={{ ...styles.badge, ...styles.badgeBlue }}>{b.seatNumber || '-'}</span></td>
                        <td style={styles.td}><div style={{ fontSize: '11px' }}>{b.pickupAddress} → {b.dropoffAddress}</div></td>
                        <td style={{ ...styles.td, fontWeight: '600', color: '#0284c7' }}>{formatCurrency(b.amount || 0)}</td>
                        <td style={{ ...styles.td, fontWeight: '600', color: '#059669' }}>{formatCurrency(b.paid || 0)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
            <div style={{ ...styles.modalFooter, display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
              <span style={{ color: '#64748b', fontSize: '14px' }}>
                {modalSearch && filteredModalData.length !== modalData.length ? `${filteredModalData.length}/${modalData.length}` : filteredModalData.length} {modalType === 'nhaphang' ? 'đơn hàng' : modalType === 'datve' ? 'vé online' : 'booking'}
              </span>
              <div style={{ display: 'flex', gap: '20px', fontSize: '14px' }}>
                <span><strong style={{ color: '#0284c7' }}>Tổng tiền:</strong> <span style={{ fontWeight: '700', color: '#1e293b' }}>{formatCurrency(modalTotals.total)}</span></span>
                <span><strong style={{ color: '#059669' }}>Đã thu:</strong> <span style={{ fontWeight: '700', color: '#059669' }}>{formatCurrency(modalTotals.paid)}</span></span>
                {modalTotals.total - modalTotals.paid > 0 && (
                  <span><strong style={{ color: '#ef4444' }}>Còn lại:</strong> <span style={{ fontWeight: '700', color: '#ef4444' }}>{formatCurrency(modalTotals.total - modalTotals.paid)}</span></span>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
