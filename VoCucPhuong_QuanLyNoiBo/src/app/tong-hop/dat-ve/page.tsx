'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

interface TimeSlot {
    id: number;
    time: string;
    date: string;
    route: string;
}

export default function DatVePage() {
    const router = useRouter();
    const [loading, setLoading] = useState(false);
    const [timeSlots, setTimeSlots] = useState<TimeSlot[]>([]);
    const [selectedDate, setSelectedDate] = useState(
        new Date().toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' }).split('/').join('-')
    );
    const [selectedRoute, setSelectedRoute] = useState('Sài Gòn - Long Khánh');

    const [formData, setFormData] = useState({
        timeSlotId: '',
        customerName: '',
        customerPhone: '',
        pickupType: 'Tại bến',
        pickupAddress: '',
        dropoffType: 'Tại bến',
        dropoffAddress: '',
        seatNumber: '',
        amount: 80000,
        paymentStatus: 'unpaid',
        notes: '',
    });

    const routes = [
        'Sài Gòn - Long Khánh',
        'Long Khánh - Sài Gòn'
    ];

    useEffect(() => {
        fetchTimeSlots();
    }, [selectedDate, selectedRoute]);

    const fetchTimeSlots = async () => {
        try {
            const params = new URLSearchParams();
            params.append('date', selectedDate);
            params.append('route', selectedRoute);

            const res = await fetch(`/api/timeslots?${params}`);
            const data = await res.json();
            if (data.success) {
                setTimeSlots(data.timeSlots);
            }
        } catch (error) {
            console.error('Error fetching timeslots:', error);
        }
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: name === 'amount' ? parseInt(value) || 0 : value
        }));
    };

    const formatDateForInput = (dateStr: string) => {
        const parts = dateStr.split('-');
        if (parts.length === 3 && parts[0].length === 2) {
            return `${parts[2]}-${parts[1]}-${parts[0]}`;
        }
        return dateStr;
    };

    const handleDateChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const inputDate = e.target.value;
        const parts = inputDate.split('-');
        const formattedDate = `${parts[2]}-${parts[1]}-${parts[0]}`;
        setSelectedDate(formattedDate);
    };

    // Tìm khách hàng theo SĐT
    const searchCustomer = async () => {
        if (!formData.customerPhone || formData.customerPhone.length < 10) return;

        try {
            const res = await fetch(`/api/customers/search?phone=${formData.customerPhone}`);
            const data = await res.json();
            if (data.success && data.customer) {
                setFormData(prev => ({
                    ...prev,
                    customerName: data.customer.full_name || prev.customerName,
                    pickupType: data.customer.pickup_type || prev.pickupType,
                    pickupAddress: data.customer.pickup_location || prev.pickupAddress,
                    dropoffType: data.customer.dropoff_type || prev.dropoffType,
                    dropoffAddress: data.customer.dropoff_location || prev.dropoffAddress,
                }));
            }
        } catch (error) {
            console.error('Error searching customer:', error);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!formData.timeSlotId) {
            alert('Vui lòng chọn khung giờ');
            return;
        }

        if (!formData.customerName || !formData.customerPhone) {
            alert('Vui lòng nhập thông tin khách hàng');
            return;
        }

        try {
            setLoading(true);
            const res = await fetch('/api/bookings', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    ...formData,
                    route: selectedRoute,
                }),
            });

            const data = await res.json();

            if (data.success) {
                alert('Đặt vé thành công!');
                // Reset form
                setFormData({
                    timeSlotId: '',
                    customerName: '',
                    customerPhone: '',
                    pickupType: 'Tại bến',
                    pickupAddress: '',
                    dropoffType: 'Tại bến',
                    dropoffAddress: '',
                    seatNumber: '',
                    amount: 80000,
                    paymentStatus: 'unpaid',
                    notes: '',
                });
                fetchTimeSlots();
            } else {
                alert('Lỗi: ' + (data.error || 'Không thể đặt vé'));
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
                <h1 className="text-2xl font-bold text-slate-800">Đặt vé</h1>
                <p className="text-slate-500">Đặt vé cho khách hàng</p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Left: Form */}
                <div className="lg:col-span-2">
                    <form onSubmit={handleSubmit}>
                        {/* Chọn chuyến */}
                        <div className="card mb-6">
                            <h2 className="text-lg font-semibold mb-4 pb-4 border-b border-slate-200">
                                🚌 Chọn chuyến xe
                            </h2>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                                <div className="form-group mb-0">
                                    <label className="form-label">Ngày đi</label>
                                    <input
                                        type="date"
                                        className="form-input"
                                        value={formatDateForInput(selectedDate)}
                                        onChange={handleDateChange}
                                    />
                                </div>
                                <div className="form-group mb-0">
                                    <label className="form-label">Tuyến đường</label>
                                    <select
                                        className="form-input"
                                        value={selectedRoute}
                                        onChange={(e) => setSelectedRoute(e.target.value)}
                                    >
                                        {routes.map(r => (
                                            <option key={r} value={r}>{r}</option>
                                        ))}
                                    </select>
                                </div>
                                <div className="form-group mb-0">
                                    <label className="form-label">Giờ khởi hành *</label>
                                    <select
                                        name="timeSlotId"
                                        className="form-input"
                                        value={formData.timeSlotId}
                                        onChange={handleChange}
                                        required
                                    >
                                        <option value="">-- Chọn giờ --</option>
                                        {timeSlots.map(slot => (
                                            <option key={slot.id} value={slot.id}>
                                                {slot.time}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                            </div>
                        </div>

                        {/* Thông tin khách hàng */}
                        <div className="card mb-6">
                            <h2 className="text-lg font-semibold mb-4 pb-4 border-b border-slate-200">
                                👤 Thông tin khách hàng
                            </h2>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="form-group">
                                    <label className="form-label">Số điện thoại *</label>
                                    <div className="flex gap-2">
                                        <input
                                            type="tel"
                                            name="customerPhone"
                                            className="form-input flex-1"
                                            value={formData.customerPhone}
                                            onChange={handleChange}
                                            onBlur={searchCustomer}
                                            placeholder="0xxx xxx xxx"
                                            required
                                        />
                                        <button
                                            type="button"
                                            onClick={searchCustomer}
                                            className="btn btn-secondary"
                                        >
                                            🔍
                                        </button>
                                    </div>
                                </div>
                                <div className="form-group">
                                    <label className="form-label">Họ tên *</label>
                                    <input
                                        type="text"
                                        name="customerName"
                                        className="form-input"
                                        value={formData.customerName}
                                        onChange={handleChange}
                                        placeholder="Nhập họ tên"
                                        required
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Điểm đón/trả */}
                        <div className="card mb-6">
                            <h2 className="text-lg font-semibold mb-4 pb-4 border-b border-slate-200">
                                📍 Điểm đón - trả
                            </h2>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                {/* Điểm đón */}
                                <div>
                                    <h3 className="font-medium text-green-600 mb-3">🟢 Điểm đón</h3>
                                    <div className="form-group">
                                        <label className="form-label">Loại</label>
                                        <select
                                            name="pickupType"
                                            className="form-input"
                                            value={formData.pickupType}
                                            onChange={handleChange}
                                        >
                                            <option value="Tại bến">Tại bến</option>
                                            <option value="Dọc đường">Dọc đường</option>
                                        </select>
                                    </div>
                                    {formData.pickupType === 'Dọc đường' && (
                                        <div className="form-group">
                                            <label className="form-label">Địa chỉ đón</label>
                                            <input
                                                type="text"
                                                name="pickupAddress"
                                                className="form-input"
                                                value={formData.pickupAddress}
                                                onChange={handleChange}
                                                placeholder="Nhập địa chỉ đón"
                                            />
                                        </div>
                                    )}
                                </div>

                                {/* Điểm trả */}
                                <div>
                                    <h3 className="font-medium text-red-600 mb-3">🔴 Điểm trả</h3>
                                    <div className="form-group">
                                        <label className="form-label">Loại</label>
                                        <select
                                            name="dropoffType"
                                            className="form-input"
                                            value={formData.dropoffType}
                                            onChange={handleChange}
                                        >
                                            <option value="Tại bến">Tại bến</option>
                                            <option value="Dọc đường">Dọc đường</option>
                                        </select>
                                    </div>
                                    {formData.dropoffType === 'Dọc đường' && (
                                        <div className="form-group">
                                            <label className="form-label">Địa chỉ trả</label>
                                            <input
                                                type="text"
                                                name="dropoffAddress"
                                                className="form-input"
                                                value={formData.dropoffAddress}
                                                onChange={handleChange}
                                                placeholder="Nhập địa chỉ trả"
                                            />
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>

                        {/* Thanh toán */}
                        <div className="card mb-6">
                            <h2 className="text-lg font-semibold mb-4 pb-4 border-b border-slate-200">
                                💰 Thanh toán
                            </h2>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div className="form-group">
                                    <label className="form-label">Số ghế</label>
                                    <input
                                        type="text"
                                        name="seatNumber"
                                        className="form-input"
                                        value={formData.seatNumber}
                                        onChange={handleChange}
                                        placeholder="VD: A1, B2..."
                                    />
                                </div>
                                <div className="form-group">
                                    <label className="form-label">Tiền vé (đ)</label>
                                    <input
                                        type="number"
                                        name="amount"
                                        className="form-input"
                                        value={formData.amount}
                                        onChange={handleChange}
                                        min="0"
                                        step="1000"
                                    />
                                </div>
                                <div className="form-group">
                                    <label className="form-label">Trạng thái</label>
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
                            </div>
                            <div className="form-group">
                                <label className="form-label">Ghi chú</label>
                                <textarea
                                    name="notes"
                                    className="form-input"
                                    rows={2}
                                    value={formData.notes}
                                    onChange={handleChange}
                                    placeholder="Ghi chú thêm..."
                                />
                            </div>
                        </div>

                        {/* Submit */}
                        <div className="flex gap-4">
                            <button
                                type="submit"
                                className="btn btn-primary"
                                disabled={loading}
                            >
                                {loading ? '⏳ Đang xử lý...' : '✅ Đặt vé'}
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

                {/* Right: Quick Info */}
                <div>
                    <div className="card sticky top-4">
                        <h3 className="font-semibold mb-4">📋 Thông tin chuyến</h3>
                        <div className="space-y-3 text-sm">
                            <div className="flex justify-between">
                                <span className="text-slate-500">Ngày:</span>
                                <span className="font-medium">{selectedDate}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-slate-500">Tuyến:</span>
                                <span className="font-medium">{selectedRoute}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-slate-500">Giờ:</span>
                                <span className="font-medium">
                                    {formData.timeSlotId
                                        ? timeSlots.find(s => s.id === parseInt(formData.timeSlotId))?.time || '--'
                                        : '--'}
                                </span>
                            </div>
                            <hr />
                            <div className="flex justify-between">
                                <span className="text-slate-500">Khách hàng:</span>
                                <span className="font-medium">{formData.customerName || '--'}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-slate-500">SĐT:</span>
                                <span className="font-medium">{formData.customerPhone || '--'}</span>
                            </div>
                            <hr />
                            <div className="flex justify-between text-lg">
                                <span className="text-slate-600">Tổng tiền:</span>
                                <span className="font-bold text-green-600">
                                    {formData.amount.toLocaleString('vi-VN')}đ
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
