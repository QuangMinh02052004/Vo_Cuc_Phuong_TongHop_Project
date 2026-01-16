'use client';

import { useEffect, useState } from 'react';

interface Stats {
    todayProducts: number;
    todayBookings: number;
    todayRevenue: number;
    pendingProducts: number;
}

export default function Dashboard() {
    const [stats, setStats] = useState<Stats>({
        todayProducts: 0,
        todayBookings: 0,
        todayRevenue: 0,
        pendingProducts: 0,
    });
    const [recentProducts, setRecentProducts] = useState<any[]>([]);
    const [recentBookings, setRecentBookings] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchDashboardData();
    }, []);

    const fetchDashboardData = async () => {
        try {
            const res = await fetch('/api/dashboard');
            const data = await res.json();
            if (data.success) {
                setStats(data.stats);
                setRecentProducts(data.recentProducts || []);
                setRecentBookings(data.recentBookings || []);
            }
        } catch (error) {
            console.error('Error fetching dashboard:', error);
        } finally {
            setLoading(false);
        }
    };

    const today = new Date().toLocaleDateString('vi-VN', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });

    return (
        <div>
            {/* Header */}
            <div className="mb-6">
                <h1 className="text-2xl font-bold text-slate-800">Dashboard</h1>
                <p className="text-slate-500">{today}</p>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
                <div className="stat-card">
                    <div className="stat-icon bg-blue-100 text-blue-600">📦</div>
                    <div>
                        <div className="stat-value">{stats.todayProducts}</div>
                        <div className="stat-label">Hàng hóa hôm nay</div>
                    </div>
                </div>

                <div className="stat-card">
                    <div className="stat-icon bg-green-100 text-green-600">🎫</div>
                    <div>
                        <div className="stat-value">{stats.todayBookings}</div>
                        <div className="stat-label">Đặt vé hôm nay</div>
                    </div>
                </div>

                <div className="stat-card">
                    <div className="stat-icon bg-amber-100 text-amber-600">💰</div>
                    <div>
                        <div className="stat-value">
                            {stats.todayRevenue.toLocaleString('vi-VN')}đ
                        </div>
                        <div className="stat-label">Doanh thu hôm nay</div>
                    </div>
                </div>

                <div className="stat-card">
                    <div className="stat-icon bg-red-100 text-red-600">⏳</div>
                    <div>
                        <div className="stat-value">{stats.pendingProducts}</div>
                        <div className="stat-label">Chờ xử lý</div>
                    </div>
                </div>
            </div>

            {/* Two Column Layout */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                {/* Recent Products */}
                <div className="card">
                    <div className="card-header">
                        <h2 className="text-lg font-semibold">Hàng hóa gần đây</h2>
                        <a href="/nhap-hang" className="text-sky-500 text-sm hover:underline">
                            Xem tất cả →
                        </a>
                    </div>
                    {loading ? (
                        <div className="text-center py-8 text-slate-400">Đang tải...</div>
                    ) : recentProducts.length === 0 ? (
                        <div className="text-center py-8 text-slate-400">
                            Chưa có hàng hóa nào
                        </div>
                    ) : (
                        <div className="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Mã</th>
                                        <th>Người gửi</th>
                                        <th>Trạm</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {recentProducts.map((product) => (
                                        <tr key={product.id}>
                                            <td className="font-mono text-sm">{product.id}</td>
                                            <td>{product.sender_name}</td>
                                            <td>{product.sender_station}</td>
                                            <td>
                                                <span className={`badge ${
                                                    product.status === 'completed' ? 'badge-success' :
                                                    product.status === 'pending' ? 'badge-warning' :
                                                    'badge-info'
                                                }`}>
                                                    {product.status === 'completed' ? 'Đã giao' :
                                                     product.status === 'pending' ? 'Chờ xử lý' :
                                                     'Đang vận chuyển'}
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>

                {/* Recent Bookings */}
                <div className="card">
                    <div className="card-header">
                        <h2 className="text-lg font-semibold">Đặt vé gần đây</h2>
                        <a href="/tong-hop/dat-ve" className="text-sky-500 text-sm hover:underline">
                            Xem tất cả →
                        </a>
                    </div>
                    {loading ? (
                        <div className="text-center py-8 text-slate-400">Đang tải...</div>
                    ) : recentBookings.length === 0 ? (
                        <div className="text-center py-8 text-slate-400">
                            Chưa có đặt vé nào
                        </div>
                    ) : (
                        <div className="table-container">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Khách hàng</th>
                                        <th>SĐT</th>
                                        <th>Tuyến</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {recentBookings.map((booking) => (
                                        <tr key={booking.id}>
                                            <td>{booking.customer_name}</td>
                                            <td>{booking.customer_phone}</td>
                                            <td className="text-sm">{booking.route}</td>
                                            <td>
                                                <span className={`badge ${
                                                    booking.status === 'confirmed' ? 'badge-success' :
                                                    booking.status === 'pending' ? 'badge-warning' :
                                                    'badge-info'
                                                }`}>
                                                    {booking.status === 'confirmed' ? 'Đã xác nhận' :
                                                     booking.status === 'pending' ? 'Chờ xác nhận' :
                                                     'Đang xử lý'}
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    )}
                </div>
            </div>

            {/* Quick Actions */}
            <div className="mt-6">
                <h2 className="text-lg font-semibold mb-4">Thao tác nhanh</h2>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <a href="/nhap-hang/them-moi" className="card hover:shadow-md transition-shadow cursor-pointer text-center py-6">
                        <div className="text-3xl mb-2">📦</div>
                        <div className="font-medium">Thêm hàng mới</div>
                    </a>
                    <a href="/tong-hop/dat-ve" className="card hover:shadow-md transition-shadow cursor-pointer text-center py-6">
                        <div className="text-3xl mb-2">🎫</div>
                        <div className="font-medium">Đặt vé</div>
                    </a>
                    <a href="/tong-hop" className="card hover:shadow-md transition-shadow cursor-pointer text-center py-6">
                        <div className="text-3xl mb-2">🚌</div>
                        <div className="font-medium">Quản lý chuyến</div>
                    </a>
                    <a href="/tong-hop/khach-hang" className="card hover:shadow-md transition-shadow cursor-pointer text-center py-6">
                        <div className="text-3xl mb-2">👥</div>
                        <div className="font-medium">Khách hàng</div>
                    </a>
                </div>
            </div>
        </div>
    );
}
