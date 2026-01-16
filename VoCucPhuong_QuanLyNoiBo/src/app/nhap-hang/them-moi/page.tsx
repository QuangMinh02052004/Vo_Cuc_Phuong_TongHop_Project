'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

interface Station {
    id: number;
    code: string;
    name: string;
    full_name: string;
}

export default function ThemHangMoiPage() {
    const router = useRouter();
    const [stations, setStations] = useState<Station[]>([]);
    const [loading, setLoading] = useState(false);
    const [formData, setFormData] = useState({
        senderName: '',
        senderPhone: '',
        senderStation: '',
        receiverName: '',
        receiverPhone: '',
        receiverStation: '',
        productType: '',
        quantity: 1,
        vehicle: '',
        insurance: 0,
        totalAmount: 0,
        paymentStatus: 'unpaid',
        employee: '',
        sendDate: new Date().toISOString().split('T')[0],
        notes: '',
    });

    useEffect(() => {
        fetchStations();
    }, []);

    const fetchStations = async () => {
        try {
            const res = await fetch('/api/stations');
            const data = await res.json();
            if (data.success) {
                setStations(data.stations);
            }
        } catch (error) {
            console.error('Error fetching stations:', error);
        }
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: ['quantity', 'insurance', 'totalAmount'].includes(name)
                ? parseFloat(value) || 0
                : value
        }));
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!formData.senderName || !formData.senderPhone || !formData.senderStation) {
            alert('Vui lòng điền thông tin người gửi');
            return;
        }

        if (!formData.receiverName || !formData.receiverPhone || !formData.receiverStation) {
            alert('Vui lòng điền thông tin người nhận');
            return;
        }

        if (!formData.productType) {
            alert('Vui lòng nhập loại hàng');
            return;
        }

        try {
            setLoading(true);
            const res = await fetch('/api/products', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(formData),
            });

            const data = await res.json();

            if (data.success) {
                alert(`Thêm hàng thành công!\nMã hàng: ${data.productId}`);
                router.push('/nhap-hang');
            } else {
                alert('Lỗi: ' + (data.error || 'Không thể thêm hàng'));
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Có lỗi xảy ra');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div>
            {/* Header */}
            <div className="mb-6">
                <h1 className="text-2xl font-bold text-slate-800">Thêm hàng mới</h1>
                <p className="text-slate-500">Nhập thông tin hàng hóa cần vận chuyển</p>
            </div>

            <form onSubmit={handleSubmit}>
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                    {/* Người gửi */}
                    <div className="card">
                        <h2 className="text-lg font-semibold mb-4 pb-4 border-b border-slate-200">
                            📤 Thông tin người gửi
                        </h2>
                        <div className="space-y-4">
                            <div className="form-group">
                                <label className="form-label">Họ tên người gửi *</label>
                                <input
                                    type="text"
                                    name="senderName"
                                    className="form-input"
                                    value={formData.senderName}
                                    onChange={handleChange}
                                    placeholder="Nhập họ tên"
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label className="form-label">Số điện thoại *</label>
                                <input
                                    type="tel"
                                    name="senderPhone"
                                    className="form-input"
                                    value={formData.senderPhone}
                                    onChange={handleChange}
                                    placeholder="0xxx xxx xxx"
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label className="form-label">Trạm gửi *</label>
                                <select
                                    name="senderStation"
                                    className="form-input"
                                    value={formData.senderStation}
                                    onChange={handleChange}
                                    required
                                >
                                    <option value="">-- Chọn trạm --</option>
                                    {stations.map(s => (
                                        <option key={s.id} value={s.full_name}>{s.full_name}</option>
                                    ))}
                                </select>
                            </div>
                        </div>
                    </div>

                    {/* Người nhận */}
                    <div className="card">
                        <h2 className="text-lg font-semibold mb-4 pb-4 border-b border-slate-200">
                            📥 Thông tin người nhận
                        </h2>
                        <div className="space-y-4">
                            <div className="form-group">
                                <label className="form-label">Họ tên người nhận *</label>
                                <input
                                    type="text"
                                    name="receiverName"
                                    className="form-input"
                                    value={formData.receiverName}
                                    onChange={handleChange}
                                    placeholder="Nhập họ tên"
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label className="form-label">Số điện thoại *</label>
                                <input
                                    type="tel"
                                    name="receiverPhone"
                                    className="form-input"
                                    value={formData.receiverPhone}
                                    onChange={handleChange}
                                    placeholder="0xxx xxx xxx"
                                    required
                                />
                            </div>
                            <div className="form-group">
                                <label className="form-label">Trạm nhận *</label>
                                <select
                                    name="receiverStation"
                                    className="form-input"
                                    value={formData.receiverStation}
                                    onChange={handleChange}
                                    required
                                >
                                    <option value="">-- Chọn trạm --</option>
                                    {stations.map(s => (
                                        <option key={s.id} value={s.full_name}>{s.full_name}</option>
                                    ))}
                                </select>
                            </div>
                        </div>
                    </div>

                    {/* Thông tin hàng */}
                    <div className="card">
                        <h2 className="text-lg font-semibold mb-4 pb-4 border-b border-slate-200">
                            📦 Thông tin hàng hóa
                        </h2>
                        <div className="space-y-4">
                            <div className="form-group">
                                <label className="form-label">Loại hàng *</label>
                                <input
                                    type="text"
                                    name="productType"
                                    className="form-input"
                                    value={formData.productType}
                                    onChange={handleChange}
                                    placeholder="VD: Quần áo, Đồ ăn, Linh kiện..."
                                    required
                                />
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div className="form-group">
                                    <label className="form-label">Số lượng</label>
                                    <input
                                        type="number"
                                        name="quantity"
                                        className="form-input"
                                        value={formData.quantity}
                                        onChange={handleChange}
                                        min="1"
                                    />
                                </div>
                                <div className="form-group">
                                    <label className="form-label">Xe vận chuyển</label>
                                    <input
                                        type="text"
                                        name="vehicle"
                                        className="form-input"
                                        value={formData.vehicle}
                                        onChange={handleChange}
                                        placeholder="Biển số xe"
                                    />
                                </div>
                            </div>
                            <div className="form-group">
                                <label className="form-label">Ghi chú</label>
                                <textarea
                                    name="notes"
                                    className="form-input"
                                    rows={3}
                                    value={formData.notes}
                                    onChange={handleChange}
                                    placeholder="Ghi chú thêm..."
                                />
                            </div>
                        </div>
                    </div>

                    {/* Thanh toán */}
                    <div className="card">
                        <h2 className="text-lg font-semibold mb-4 pb-4 border-b border-slate-200">
                            💰 Thanh toán
                        </h2>
                        <div className="space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div className="form-group">
                                    <label className="form-label">Tiền cước (đ)</label>
                                    <input
                                        type="number"
                                        name="totalAmount"
                                        className="form-input"
                                        value={formData.totalAmount}
                                        onChange={handleChange}
                                        min="0"
                                        step="1000"
                                    />
                                </div>
                                <div className="form-group">
                                    <label className="form-label">Bảo hiểm (đ)</label>
                                    <input
                                        type="number"
                                        name="insurance"
                                        className="form-input"
                                        value={formData.insurance}
                                        onChange={handleChange}
                                        min="0"
                                        step="1000"
                                    />
                                </div>
                            </div>
                            <div className="form-group">
                                <label className="form-label">Trạng thái thu tiền</label>
                                <select
                                    name="paymentStatus"
                                    className="form-input"
                                    value={formData.paymentStatus}
                                    onChange={handleChange}
                                >
                                    <option value="unpaid">Chưa thu</option>
                                    <option value="paid">Đã thu</option>
                                </select>
                            </div>
                            <div className="grid grid-cols-2 gap-4">
                                <div className="form-group">
                                    <label className="form-label">Ngày gửi</label>
                                    <input
                                        type="date"
                                        name="sendDate"
                                        className="form-input"
                                        value={formData.sendDate}
                                        onChange={handleChange}
                                    />
                                </div>
                                <div className="form-group">
                                    <label className="form-label">Nhân viên</label>
                                    <input
                                        type="text"
                                        name="employee"
                                        className="form-input"
                                        value={formData.employee}
                                        onChange={handleChange}
                                        placeholder="Tên nhân viên"
                                    />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Submit Buttons */}
                <div className="mt-6 flex gap-4">
                    <button
                        type="submit"
                        className="btn btn-primary"
                        disabled={loading}
                    >
                        {loading ? '⏳ Đang xử lý...' : '✅ Thêm hàng'}
                    </button>
                    <button
                        type="button"
                        className="btn btn-secondary"
                        onClick={() => router.back()}
                    >
                        ❌ Hủy
                    </button>
                </div>
            </form>
        </div>
    );
}
