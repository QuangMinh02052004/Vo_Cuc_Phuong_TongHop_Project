'use client';

import { useState, useEffect } from 'react';
import Link from 'next/link';

// Format tiền VND
function formatCurrency(amount) {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND'
  }).format(amount);
}

// Format ngày
function formatDate(dateStr) {
  if (!dateStr) return '';
  // Handle DD-MM-YYYY format
  if (dateStr.includes('-') && dateStr.split('-')[0].length === 2) {
    const [day, month, year] = dateStr.split('-');
    return `${day}/${month}/${year}`;
  }
  // Handle YYYY-MM-DD format
  const d = new Date(dateStr);
  return d.toLocaleDateString('vi-VN');
}

export default function DashboardPage() {
  const [period, setPeriod] = useState('day');
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  // Load stats khi period hoặc date thay đổi
  useEffect(() => {
    const loadStats = async () => {
      setLoading(true);
      try {
        const res = await fetch(`/api/stats?period=${period}&date=${selectedDate}`);
        const data = await res.json();
        if (data.success) {
          setStats(data);
        }
      } catch (error) {
        console.error('Error loading stats:', error);
      } finally {
        setLoading(false);
      }
    };

    loadStats();
  }, [period, selectedDate]);

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <Link href="/" className="text-sky-600 hover:text-sky-700">
                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                </svg>
              </Link>
              <h1 className="text-xl font-bold text-gray-800">
                Quản Lý Doanh Thu
              </h1>
            </div>
            <div className="text-sm text-gray-500">
              CÔNG TY TNHH VÕ CÚC PHƯƠNG
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-6">
        {/* Filters */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-4 mb-6">
          <div className="flex flex-wrap items-center gap-4">
            {/* Period selector */}
            <div className="flex items-center gap-2">
              <span className="text-sm font-medium text-gray-600">Xem theo:</span>
              <div className="flex rounded-lg border border-gray-300 overflow-hidden">
                {[
                  { value: 'day', label: 'Ngày' },
                  { value: 'week', label: 'Tuần' },
                  { value: 'month', label: 'Tháng' }
                ].map(opt => (
                  <button
                    key={opt.value}
                    onClick={() => setPeriod(opt.value)}
                    className={`px-4 py-2 text-sm font-medium transition ${
                      period === opt.value
                        ? 'bg-sky-500 text-white'
                        : 'bg-white text-gray-700 hover:bg-gray-50'
                    }`}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Date picker */}
            <div className="flex items-center gap-2">
              <span className="text-sm font-medium text-gray-600">Chọn ngày:</span>
              <input
                type="date"
                value={selectedDate}
                onChange={(e) => setSelectedDate(e.target.value)}
                className="px-3 py-2 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-sky-500 focus:border-sky-500 outline-none"
              />
            </div>

            {/* Date range display */}
            {stats && (
              <div className="ml-auto text-sm text-gray-500">
                {stats.dateRange?.label}
              </div>
            )}
          </div>
        </div>

        {loading ? (
          <div className="flex items-center justify-center py-20">
            <div className="w-10 h-10 border-4 border-sky-500 border-t-transparent rounded-full animate-spin"></div>
          </div>
        ) : stats ? (
          <>
            {/* Summary Cards */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
              {/* Tổng doanh thu */}
              <div className="bg-gradient-to-br from-sky-500 to-sky-600 rounded-xl p-5 text-white shadow-lg">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sky-100 text-sm font-medium">Tổng Doanh Thu</span>
                  <svg className="w-8 h-8 text-sky-200" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <div className="text-2xl font-bold">
                  {formatCurrency(stats.summary?.totalRevenue || 0)}
                </div>
              </div>

              {/* Doanh thu Nhập Hàng */}
              <div className="bg-white rounded-xl p-5 border border-gray-200 shadow-sm">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-gray-500 text-sm font-medium">Nhập Hàng</span>
                  <svg className="w-8 h-8 text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                  </svg>
                </div>
                <div className="text-2xl font-bold text-gray-800">
                  {formatCurrency(stats.summary?.nhapHangRevenue || 0)}
                </div>
                <div className="text-sm text-gray-500 mt-1">
                  {stats.summary?.totalOrders || 0} đơn hàng
                </div>
              </div>

              {/* Doanh thu Hành Khách */}
              <div className="bg-white rounded-xl p-5 border border-gray-200 shadow-sm">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-gray-500 text-sm font-medium">Hành Khách</span>
                  <svg className="w-8 h-8 text-sky-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                  </svg>
                </div>
                <div className="text-2xl font-bold text-gray-800">
                  {formatCurrency(stats.summary?.tongHopRevenue || 0)}
                </div>
                <div className="text-sm text-gray-500 mt-1">
                  {stats.summary?.totalPassengers || 0} hành khách
                </div>
              </div>

              {/* Tổng số lượng */}
              <div className="bg-white rounded-xl p-5 border border-gray-200 shadow-sm">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-gray-500 text-sm font-medium">Tổng Giao Dịch</span>
                  <svg className="w-8 h-8 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
                  </svg>
                </div>
                <div className="text-2xl font-bold text-gray-800">
                  {(stats.summary?.totalOrders || 0) + (stats.summary?.totalPassengers || 0)}
                </div>
                <div className="text-sm text-gray-500 mt-1">
                  giao dịch
                </div>
              </div>
            </div>

            {/* Detail Sections */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Nhập Hàng Details */}
              <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                <div className="bg-emerald-50 px-5 py-3 border-b border-emerald-100">
                  <h2 className="font-bold text-emerald-800 flex items-center gap-2">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
                    </svg>
                    Chi Tiết Nhập Hàng
                  </h2>
                </div>
                <div className="p-5">
                  {/* Stats overview */}
                  <div className="grid grid-cols-3 gap-3 mb-4">
                    <div className="text-center p-3 bg-gray-50 rounded-lg">
                      <div className="text-lg font-bold text-gray-800">
                        {stats.nhapHang?.overview?.totalOrders || 0}
                      </div>
                      <div className="text-xs text-gray-500">Tổng đơn</div>
                    </div>
                    <div className="text-center p-3 bg-emerald-50 rounded-lg">
                      <div className="text-lg font-bold text-emerald-600">
                        {stats.nhapHang?.overview?.deliveredOrders || 0}
                      </div>
                      <div className="text-xs text-gray-500">Đã giao</div>
                    </div>
                    <div className="text-center p-3 bg-amber-50 rounded-lg">
                      <div className="text-lg font-bold text-amber-600">
                        {stats.nhapHang?.overview?.pendingOrders || 0}
                      </div>
                      <div className="text-xs text-gray-500">Chờ xử lý</div>
                    </div>
                  </div>

                  {/* Payment stats */}
                  <div className="flex justify-between items-center p-3 bg-sky-50 rounded-lg mb-4">
                    <div>
                      <div className="text-sm text-gray-600">Đã thanh toán</div>
                      <div className="font-bold text-sky-600">
                        {formatCurrency(stats.nhapHang?.overview?.paidAmount || 0)}
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-sm text-gray-600">Chưa thanh toán</div>
                      <div className="font-bold text-red-500">
                        {formatCurrency(stats.nhapHang?.overview?.unpaidAmount || 0)}
                      </div>
                    </div>
                  </div>

                  {/* By Station */}
                  <h3 className="font-semibold text-gray-700 mb-2 text-sm">Theo Trạm</h3>
                  <div className="space-y-2 max-h-48 overflow-y-auto">
                    {stats.nhapHang?.byStation?.length > 0 ? (
                      stats.nhapHang.byStation.map((item, idx) => (
                        <div key={idx} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                          <span className="text-sm text-gray-700 truncate flex-1">{item.station}</span>
                          <span className="text-sm font-medium text-gray-500 mx-2">{item.orderCount} đơn</span>
                          <span className="text-sm font-bold text-emerald-600">{formatCurrency(item.revenue)}</span>
                        </div>
                      ))
                    ) : (
                      <div className="text-center text-gray-400 py-4">Chưa có dữ liệu</div>
                    )}
                  </div>
                </div>
              </div>

              {/* Tổng Hợp Details */}
              <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                <div className="bg-sky-50 px-5 py-3 border-b border-sky-100">
                  <h2 className="font-bold text-sky-800 flex items-center gap-2">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    Chi Tiết Hành Khách
                  </h2>
                </div>
                <div className="p-5">
                  {/* Stats overview */}
                  <div className="grid grid-cols-2 gap-3 mb-4">
                    <div className="text-center p-3 bg-gray-50 rounded-lg">
                      <div className="text-lg font-bold text-gray-800">
                        {stats.tongHop?.overview?.totalBookings || 0}
                      </div>
                      <div className="text-xs text-gray-500">Tổng booking</div>
                    </div>
                    <div className="text-center p-3 bg-sky-50 rounded-lg">
                      <div className="text-lg font-bold text-sky-600">
                        {formatCurrency(stats.tongHop?.overview?.paidAmount || 0)}
                      </div>
                      <div className="text-xs text-gray-500">Đã thu</div>
                    </div>
                  </div>

                  {/* By Route */}
                  <h3 className="font-semibold text-gray-700 mb-2 text-sm">Theo Tuyến</h3>
                  <div className="space-y-2 mb-4">
                    {stats.tongHop?.byRoute?.length > 0 ? (
                      stats.tongHop.byRoute.map((item, idx) => (
                        <div key={idx} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                          <span className="text-sm text-gray-700 truncate flex-1">{item.route || 'Không xác định'}</span>
                          <span className="text-sm font-medium text-gray-500 mx-2">{item.bookingCount} vé</span>
                          <span className="text-sm font-bold text-sky-600">{formatCurrency(item.revenue)}</span>
                        </div>
                      ))
                    ) : (
                      <div className="text-center text-gray-400 py-4">Chưa có dữ liệu</div>
                    )}
                  </div>

                  {/* By Date */}
                  <h3 className="font-semibold text-gray-700 mb-2 text-sm">Theo Ngày</h3>
                  <div className="space-y-2 max-h-32 overflow-y-auto">
                    {stats.tongHop?.byDate?.length > 0 ? (
                      stats.tongHop.byDate.map((item, idx) => (
                        <div key={idx} className="flex items-center justify-between p-2 bg-gray-50 rounded">
                          <span className="text-sm text-gray-700">{formatDate(item.date)}</span>
                          <span className="text-sm font-medium text-gray-500">{item.bookingCount} booking</span>
                          <span className="text-sm font-bold text-sky-600">{formatCurrency(item.revenue)}</span>
                        </div>
                      ))
                    ) : (
                      <div className="text-center text-gray-400 py-4">Chưa có dữ liệu</div>
                    )}
                  </div>
                </div>
              </div>
            </div>

            {/* Nhập Hàng By Date */}
            {stats.nhapHang?.byDate?.length > 0 && (
              <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden mt-6">
                <div className="bg-gray-50 px-5 py-3 border-b border-gray-100">
                  <h2 className="font-bold text-gray-800 flex items-center gap-2">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                    </svg>
                    Nhập Hàng Theo Ngày
                  </h2>
                </div>
                <div className="p-5">
                  <div className="overflow-x-auto">
                    <table className="w-full text-sm">
                      <thead>
                        <tr className="border-b border-gray-200">
                          <th className="text-left py-2 px-3 font-semibold text-gray-600">Ngày</th>
                          <th className="text-right py-2 px-3 font-semibold text-gray-600">Số đơn</th>
                          <th className="text-right py-2 px-3 font-semibold text-gray-600">Doanh thu</th>
                        </tr>
                      </thead>
                      <tbody>
                        {stats.nhapHang.byDate.map((item, idx) => (
                          <tr key={idx} className="border-b border-gray-100 hover:bg-gray-50">
                            <td className="py-2 px-3 text-gray-700">{formatDate(item.date)}</td>
                            <td className="py-2 px-3 text-right text-gray-600">{item.orderCount}</td>
                            <td className="py-2 px-3 text-right font-semibold text-emerald-600">
                              {formatCurrency(item.revenue)}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            )}
          </>
        ) : (
          <div className="text-center py-20 text-gray-500">
            Không thể tải dữ liệu
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-gray-200 mt-10">
        <div className="max-w-7xl mx-auto px-4 py-4 text-center text-sm text-gray-500">
          Hệ thống quản lý nội bộ - CÔNG TY TNHH VÕ CÚC PHƯƠNG
        </div>
      </footer>
    </div>
  );
}
