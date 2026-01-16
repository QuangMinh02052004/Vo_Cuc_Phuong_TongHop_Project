'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';

interface Product {
    id: string;
    sender_name: string;
    sender_phone: string;
    sender_station: string;
    receiver_name: string;
    receiver_phone: string;
    receiver_station: string;
    product_type: string;
    quantity: number;
    total_amount: number;
    payment_status: string;
    status: string;
    send_date: string;
    created_at: string;
}

export default function NhapHangPage() {
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [filterStatus, setFilterStatus] = useState('all');
    const [filterDate, setFilterDate] = useState(new Date().toISOString().split('T')[0]);

    useEffect(() => {
        fetchProducts();
    }, [filterDate, filterStatus]);

    const fetchProducts = async () => {
        try {
            setLoading(true);
            const params = new URLSearchParams();
            if (filterDate) params.append('date', filterDate);
            if (filterStatus !== 'all') params.append('status', filterStatus);

            const res = await fetch(`/api/products?${params}`);
            const data = await res.json();
            if (data.success) {
                setProducts(data.products);
            }
        } catch (error) {
            console.error('Error fetching products:', error);
        } finally {
            setLoading(false);
        }
    };

    const filteredProducts = products.filter(p =>
        p.sender_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.receiver_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
        p.sender_phone.includes(searchTerm) ||
        p.receiver_phone.includes(searchTerm)
    );

    const getStatusBadge = (status: string) => {
        switch (status) {
            case 'completed':
                return <span className="badge badge-success">Đã giao</span>;
            case 'shipping':
                return <span className="badge badge-info">Đang vận chuyển</span>;
            case 'pending':
            default:
                return <span className="badge badge-warning">Chờ xử lý</span>;
        }
    };

    const getPaymentBadge = (status: string) => {
        return status === 'paid'
            ? <span className="badge badge-success">Đã thu</span>
            : <span className="badge badge-danger">Chưa thu</span>;
    };

    return (
        <div>
            {/* Header */}
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Quản lý hàng hóa</h1>
                    <p className="text-slate-500">Danh sách hàng hóa nhập vào hệ thống</p>
                </div>
                <Link href="/nhap-hang/them-moi" className="btn btn-primary">
                    ➕ Thêm hàng mới
                </Link>
            </div>

            {/* Filters */}
            <div className="card mb-6">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div className="form-group mb-0">
                        <label className="form-label">Tìm kiếm</label>
                        <input
                            type="text"
                            className="form-input"
                            placeholder="Tên, SĐT, mã hàng..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>
                    <div className="form-group mb-0">
                        <label className="form-label">Ngày gửi</label>
                        <input
                            type="date"
                            className="form-input"
                            value={filterDate}
                            onChange={(e) => setFilterDate(e.target.value)}
                        />
                    </div>
                    <div className="form-group mb-0">
                        <label className="form-label">Trạng thái</label>
                        <select
                            className="form-input"
                            value={filterStatus}
                            onChange={(e) => setFilterStatus(e.target.value)}
                        >
                            <option value="all">Tất cả</option>
                            <option value="pending">Chờ xử lý</option>
                            <option value="shipping">Đang vận chuyển</option>
                            <option value="completed">Đã giao</option>
                        </select>
                    </div>
                    <div className="form-group mb-0 flex items-end">
                        <button onClick={fetchProducts} className="btn btn-secondary w-full">
                            🔄 Làm mới
                        </button>
                    </div>
                </div>
            </div>

            {/* Products Table */}
            <div className="card">
                {loading ? (
                    <div className="text-center py-12 text-slate-400">
                        <div className="text-4xl mb-4">⏳</div>
                        Đang tải dữ liệu...
                    </div>
                ) : filteredProducts.length === 0 ? (
                    <div className="text-center py-12 text-slate-400">
                        <div className="text-4xl mb-4">📦</div>
                        Không có hàng hóa nào
                    </div>
                ) : (
                    <div className="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Mã hàng</th>
                                    <th>Người gửi</th>
                                    <th>Người nhận</th>
                                    <th>Loại hàng</th>
                                    <th>Số lượng</th>
                                    <th>Tiền cước</th>
                                    <th>Thu tiền</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filteredProducts.map((product) => (
                                    <tr key={product.id}>
                                        <td className="font-mono text-sm font-medium text-sky-600">
                                            {product.id}
                                        </td>
                                        <td>
                                            <div className="font-medium">{product.sender_name}</div>
                                            <div className="text-sm text-slate-500">{product.sender_phone}</div>
                                            <div className="text-xs text-slate-400">{product.sender_station}</div>
                                        </td>
                                        <td>
                                            <div className="font-medium">{product.receiver_name}</div>
                                            <div className="text-sm text-slate-500">{product.receiver_phone}</div>
                                            <div className="text-xs text-slate-400">{product.receiver_station}</div>
                                        </td>
                                        <td>{product.product_type}</td>
                                        <td className="text-center">{product.quantity}</td>
                                        <td className="font-medium">
                                            {product.total_amount?.toLocaleString('vi-VN')}đ
                                        </td>
                                        <td>{getPaymentBadge(product.payment_status)}</td>
                                        <td>{getStatusBadge(product.status)}</td>
                                        <td>
                                            <div className="flex gap-2">
                                                <button className="text-sky-500 hover:text-sky-700" title="Xem chi tiết">
                                                    👁️
                                                </button>
                                                <button className="text-amber-500 hover:text-amber-700" title="Sửa">
                                                    ✏️
                                                </button>
                                                <button className="text-green-500 hover:text-green-700" title="In phiếu">
                                                    🖨️
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}

                {/* Summary */}
                {!loading && filteredProducts.length > 0 && (
                    <div className="mt-4 pt-4 border-t border-slate-200 flex flex-wrap gap-6 text-sm">
                        <div>
                            <span className="text-slate-500">Tổng:</span>{' '}
                            <span className="font-semibold">{filteredProducts.length} đơn</span>
                        </div>
                        <div>
                            <span className="text-slate-500">Tổng cước:</span>{' '}
                            <span className="font-semibold text-green-600">
                                {filteredProducts.reduce((sum, p) => sum + (p.total_amount || 0), 0).toLocaleString('vi-VN')}đ
                            </span>
                        </div>
                        <div>
                            <span className="text-slate-500">Chưa thu:</span>{' '}
                            <span className="font-semibold text-red-600">
                                {filteredProducts.filter(p => p.payment_status !== 'paid').length} đơn
                            </span>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
