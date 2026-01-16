'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';

interface TimeSlot {
    id: number;
    time: string;
    date: string;
    route: string;
    type: string;
    code: string;
    driver: string;
    phone: string;
    booking_count?: number;
    freight_count?: number;
}

export default function TongHopPage() {
    const [timeSlots, setTimeSlots] = useState<TimeSlot[]>([]);
    const [loading, setLoading] = useState(true);
    const [selectedDate, setSelectedDate] = useState(
        new Date().toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' }).split('/').join('-')
    );
    const [selectedRoute, setSelectedRoute] = useState('all');

    const routes = [
        'Sài Gòn - Long Khánh',
        'Long Khánh - Sài Gòn'
    ];

    useEffect(() => {
        fetchTimeSlots();
    }, [selectedDate, selectedRoute]);

    const fetchTimeSlots = async () => {
        try {
            setLoading(true);
            const params = new URLSearchParams();
            params.append('date', selectedDate);
            if (selectedRoute !== 'all') {
                params.append('route', selectedRoute);
            }

            const res = await fetch(`/api/timeslots?${params}`);
            const data = await res.json();
            if (data.success) {
                setTimeSlots(data.timeSlots);
            }
        } catch (error) {
            console.error('Error fetching timeslots:', error);
        } finally {
            setLoading(false);
        }
    };

    const formatDateForInput = (dateStr: string) => {
        // Convert DD-MM-YYYY to YYYY-MM-DD for input
        const parts = dateStr.split('-');
        if (parts.length === 3 && parts[0].length === 2) {
            return `${parts[2]}-${parts[1]}-${parts[0]}`;
        }
        return dateStr;
    };

    const handleDateChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const inputDate = e.target.value; // YYYY-MM-DD
        const parts = inputDate.split('-');
        const formattedDate = `${parts[2]}-${parts[1]}-${parts[0]}`; // DD-MM-YYYY
        setSelectedDate(formattedDate);
    };

    return (
        <div>
            {/* Header */}
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4 mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-slate-800">Quản lý chuyến xe</h1>
                    <p className="text-slate-500">Xem và quản lý các khung giờ chạy xe</p>
                </div>
                <Link href="/tong-hop/dat-ve" className="btn btn-primary">
                    🎫 Đặt vé mới
                </Link>
            </div>

            {/* Filters */}
            <div className="card mb-6">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div className="form-group mb-0">
                        <label className="form-label">Ngày</label>
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
                            <option value="all">Tất cả tuyến</option>
                            {routes.map(r => (
                                <option key={r} value={r}>{r}</option>
                            ))}
                        </select>
                    </div>
                    <div className="form-group mb-0 flex items-end">
                        <button onClick={fetchTimeSlots} className="btn btn-secondary w-full">
                            🔄 Làm mới
                        </button>
                    </div>
                </div>
            </div>

            {/* Time Slots Grid */}
            {loading ? (
                <div className="card text-center py-12 text-slate-400">
                    <div className="text-4xl mb-4">⏳</div>
                    Đang tải dữ liệu...
                </div>
            ) : timeSlots.length === 0 ? (
                <div className="card text-center py-12 text-slate-400">
                    <div className="text-4xl mb-4">🚌</div>
                    Không có khung giờ nào cho ngày này
                    <div className="mt-4">
                        <button
                            onClick={async () => {
                                const res = await fetch('/api/timeslots/generate', {
                                    method: 'POST',
                                    headers: { 'Content-Type': 'application/json' },
                                    body: JSON.stringify({ date: selectedDate })
                                });
                                if (res.ok) {
                                    fetchTimeSlots();
                                }
                            }}
                            className="btn btn-primary"
                        >
                            ➕ Tạo khung giờ cho ngày này
                        </button>
                    </div>
                </div>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {routes.map(route => {
                        const routeSlots = timeSlots.filter(s => s.route === route);
                        if (selectedRoute !== 'all' && selectedRoute !== route) return null;

                        return (
                            <div key={route} className="card">
                                <div className="card-header">
                                    <h2 className="text-lg font-semibold flex items-center gap-2">
                                        🚌 {route}
                                    </h2>
                                    <span className="text-sm text-slate-500">
                                        {routeSlots.length} chuyến
                                    </span>
                                </div>

                                <div className="grid grid-cols-4 sm:grid-cols-5 md:grid-cols-6 gap-2">
                                    {routeSlots.map(slot => (
                                        <Link
                                            key={slot.id}
                                            href={`/tong-hop/chuyen/${slot.id}`}
                                            className={`p-3 rounded-lg text-center transition-all hover:scale-105 cursor-pointer ${
                                                (slot.booking_count || 0) > 0
                                                    ? 'bg-green-100 border-2 border-green-300 text-green-700'
                                                    : 'bg-slate-100 hover:bg-sky-100 text-slate-600'
                                            }`}
                                        >
                                            <div className="font-bold text-lg">{slot.time}</div>
                                            <div className="text-xs mt-1">
                                                {(slot.booking_count || 0) > 0 ? (
                                                    <span className="text-green-600">
                                                        {slot.booking_count} vé
                                                    </span>
                                                ) : (
                                                    <span className="text-slate-400">Trống</span>
                                                )}
                                            </div>
                                        </Link>
                                    ))}
                                </div>

                                {routeSlots.length === 0 && (
                                    <div className="text-center py-6 text-slate-400">
                                        Chưa có khung giờ
                                    </div>
                                )}
                            </div>
                        );
                    })}
                </div>
            )}

            {/* Summary */}
            {!loading && timeSlots.length > 0 && (
                <div className="mt-6 card">
                    <h3 className="font-semibold mb-4">Tổng kết ngày {selectedDate}</h3>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                        <div className="text-center p-4 bg-slate-50 rounded-lg">
                            <div className="text-2xl font-bold text-slate-700">
                                {timeSlots.length}
                            </div>
                            <div className="text-sm text-slate-500">Tổng chuyến</div>
                        </div>
                        <div className="text-center p-4 bg-green-50 rounded-lg">
                            <div className="text-2xl font-bold text-green-600">
                                {timeSlots.filter(s => (s.booking_count || 0) > 0).length}
                            </div>
                            <div className="text-sm text-slate-500">Có khách</div>
                        </div>
                        <div className="text-center p-4 bg-sky-50 rounded-lg">
                            <div className="text-2xl font-bold text-sky-600">
                                {timeSlots.reduce((sum, s) => sum + (s.booking_count || 0), 0)}
                            </div>
                            <div className="text-sm text-slate-500">Tổng vé</div>
                        </div>
                        <div className="text-center p-4 bg-amber-50 rounded-lg">
                            <div className="text-2xl font-bold text-amber-600">
                                {timeSlots.reduce((sum, s) => sum + (s.freight_count || 0), 0)}
                            </div>
                            <div className="text-sm text-slate-500">Hàng hóa</div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
