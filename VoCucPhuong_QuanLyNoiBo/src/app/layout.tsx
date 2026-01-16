'use client';

import './globals.css';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useState } from 'react';

export default function RootLayout({
    children,
}: {
    children: React.ReactNode;
}) {
    const pathname = usePathname();
    const [sidebarOpen, setSidebarOpen] = useState(false);

    const navItems = [
        {
            section: 'Tổng quan',
            items: [
                { href: '/', icon: '📊', label: 'Dashboard' },
            ]
        },
        {
            section: 'Nhập hàng',
            items: [
                { href: '/nhap-hang', icon: '📦', label: 'Quản lý hàng hóa' },
                { href: '/nhap-hang/them-moi', icon: '➕', label: 'Thêm hàng mới' },
                { href: '/nhap-hang/thong-ke', icon: '📈', label: 'Thống kê' },
            ]
        },
        {
            section: 'Tổng hợp',
            items: [
                { href: '/tong-hop', icon: '🚌', label: 'Quản lý chuyến xe' },
                { href: '/tong-hop/dat-ve', icon: '🎫', label: 'Đặt vé' },
                { href: '/tong-hop/hang-hoa', icon: '📦', label: 'Hàng hóa theo xe' },
                { href: '/tong-hop/khach-hang', icon: '👥', label: 'Khách hàng' },
            ]
        },
        {
            section: 'Hệ thống',
            items: [
                { href: '/cai-dat', icon: '⚙️', label: 'Cài đặt' },
                { href: '/tram', icon: '🏢', label: 'Quản lý trạm' },
            ]
        }
    ];

    return (
        <html lang="vi">
            <head>
                <title>Võ Cúc Phương - Quản Lý Nội Bộ</title>
                <meta name="viewport" content="width=device-width, initial-scale=1" />
            </head>
            <body>
                {/* Mobile Menu Button */}
                <button
                    className="fixed top-4 left-4 z-50 lg:hidden bg-slate-800 text-white p-2 rounded-lg"
                    onClick={() => setSidebarOpen(!sidebarOpen)}
                >
                    {sidebarOpen ? '✕' : '☰'}
                </button>

                {/* Sidebar */}
                <aside className={`sidebar ${sidebarOpen ? 'open' : ''}`}>
                    <div className="sidebar-header">
                        <div className="text-3xl mb-2">🚌</div>
                        <h1 className="text-xl font-bold">Võ Cúc Phương</h1>
                        <p className="text-sm text-slate-400">Quản Lý Nội Bộ</p>
                    </div>

                    <nav className="sidebar-nav">
                        {navItems.map((section, idx) => (
                            <div key={idx} className="nav-section">
                                <div className="nav-section-title">{section.section}</div>
                                {section.items.map((item) => (
                                    <Link
                                        key={item.href}
                                        href={item.href}
                                        className={`nav-item ${pathname === item.href ? 'active' : ''}`}
                                        onClick={() => setSidebarOpen(false)}
                                    >
                                        <span className="nav-icon">{item.icon}</span>
                                        <span>{item.label}</span>
                                    </Link>
                                ))}
                            </div>
                        ))}
                    </nav>

                    {/* User Info */}
                    <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-slate-700">
                        <div className="flex items-center gap-3">
                            <div className="w-10 h-10 bg-sky-500 rounded-full flex items-center justify-center text-white font-bold">
                                A
                            </div>
                            <div>
                                <p className="text-sm font-medium">Admin</p>
                                <p className="text-xs text-slate-400">Quản trị viên</p>
                            </div>
                        </div>
                    </div>
                </aside>

                {/* Main Content */}
                <main className="main-content">
                    {children}
                </main>

                {/* Overlay for mobile */}
                {sidebarOpen && (
                    <div
                        className="fixed inset-0 bg-black/50 z-40 lg:hidden"
                        onClick={() => setSidebarOpen(false)}
                    />
                )}
            </body>
        </html>
    );
}
