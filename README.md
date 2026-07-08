# Võ Cúc Phương — Hệ thống quản lý nhà xe

Đồ án tốt nghiệp: Hệ thống quản lý toàn diện cho nhà xe Võ Cúc Phương — đặt vé online, bán vé tại quầy, vận chuyển hàng hoá, tài xế quét QR.

## Cấu trúc thư mục

```
Vo_Cuc_Phuong/
│
├── VoCucPhuong_PublicWeb/         ← Backend Next.js + serve static (deploy: vocucphuongmanage.vercel.app)
│                                    Toàn bộ /api/nhap-hang/* + /api/tong-hop/*
│                                    Host public /nhap-hang/ và /tong-hop/
│
├── VoCucPhuong_DatVe/             ← Web Đặt Vé khách (Next.js, deploy: vocucphuong.vercel.app)
│                                    Có /driver cho tài xế quét QR vé
│
├── VoCucPhuong_NhapHang/          ← Source HTML/JS NhapHang (sync với VoCucPhuong_PublicWeb/public/nhap-hang/)
├── VoCucPhuong_TongHop/           ← Source React TongHop (quan-ly-xe-khach/)
│                                    Build copy sang VoCucPhuong_PublicWeb/public/tong-hop/
│
├── VoCucPhuong_DatVeApp/          ← Flutter app KHÁCH (VCP Đặt Vé, applicationId com.vocucphuong.datve)
├── VoCucPhuong_FlutterApp/        ← Flutter app NỘI BỘ (có login + 3 tab: Đặt Vé / Nhập Hàng / Tổng Hợp)
│
├── VoCucPhuong_PageOptions/       ← Landing page giới thiệu công ty (tĩnh)
├── VoCucPhuong_BackupData/        ← Snapshot SQL dump của 3 DB Neon (file .sql backup định kỳ)
│
├── .env / .env.example            ← Biến môi trường (KHÔNG commit .env thật)
├── .gitignore
├── .vscode/                       ← Cấu hình VS Code
└── CLAUDE.md                      ← Hướng dẫn làm việc với AI assistant
```

## 3 cơ sở dữ liệu Neon PostgreSQL

| DB | Project Neon | Mục đích chính |
|---|---|---|
| **NhapHang** | `ep-dark-paper` | Đơn hàng vận chuyển (Products), Stations, Counters, Users kho |
| **TongHop** | `ep-autumn-sun` | Vé xe khách (TH_Bookings), TimeSlots, Routes, SeatLocks, Drivers, Vehicles |
| **DatVe** | `ep-holy-recipe` | Đặt vé online, Booking, Payment, NextAuth Users |

