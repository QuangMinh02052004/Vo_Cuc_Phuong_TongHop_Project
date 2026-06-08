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
│
├── VoCucPhuong_BackupData/        ← Snapshot SQL dump của 3 DB Neon (file .sql backup định kỳ)
│
├── BaoCao/                        ← Tài liệu đồ án tốt nghiệp
│   ├── 01-database-schema.md       Schema chi tiết 3 DB
│   ├── 02-erd.md                   Sơ đồ ERD (mermaid)
│   ├── 03-use-case.md              Use Case diagrams + ma trận phân quyền
│   ├── 04-sequence-diagrams.md     Sequence (RD) cho 7 luồng nghiệp vụ chính
│   ├── 05-mo-ta-nghiep-vu.md       Mô tả nghiệp vụ đầy đủ
│   ├── images/                     PNG export sẵn từ mermaid (12 sơ đồ)
│   ├── export-diagrams.sh          Script sinh PNG từ .md
│   └── bao-cao-tuan/               BaoCao_Tuan3.docx → Tuan7.docx
│
├── Auto_Update_Data/              ← Tool tự động đồng bộ dữ liệu từ hệ thống ngoài
│   └── o2bsoft-to-nhaphang.user.js  Tampermonkey scrape O2BSoft → POST sang NhapHang API
│
├── infrastructure/                ← Cấu hình self-host (Docker + nginx). Hiện không dùng vì đã deploy Vercel.
│                                    Giữ phòng khi cần chạy local hoặc chuyển sang VPS riêng.
│
├── .env / .env.example            ← Biến môi trường (KHÔNG commit .env thật)
├── .gitignore
├── .github/                       ← CI workflows
└── .claude/                       ← Cấu hình Claude Code
```

## 3 cơ sở dữ liệu Neon PostgreSQL

| DB | Project Neon | Mục đích chính |
|---|---|---|
| **NhapHang** | `ep-dark-paper` | Đơn hàng vận chuyển (Products), Stations, Counters, Users kho |
| **TongHop** | `ep-autumn-sun` | Vé xe khách (TH_Bookings), TimeSlots, Routes, SeatLocks, Drivers, Vehicles |
| **DatVe** | `ep-holy-recipe` | Đặt vé online, Booking, Payment, NextAuth Users |

## URL Production

| Tên | URL | Vai trò |
|---|---|---|
| **Quản trị nội bộ** | https://vocucphuongmanage.vercel.app | NhapHang + TongHop + APIs |
| **Đặt vé khách** | https://vocucphuong.vercel.app | Web khách hàng + driver quét QR |

## Lệnh build & deploy

| App | Lệnh |
|---|---|
| Web nội bộ (Public Web) | `cd VoCucPhuong_PublicWeb && npx vercel --prod --yes` |
| Web đặt vé khách | `cd VoCucPhuong_DatVe && npx vercel --prod --yes` |
| TongHop React (sau khi sửa source) | `cd VoCucPhuong_TongHop/quan-ly-xe-khach && npm run build && cp -r build/* ../../VoCucPhuong_PublicWeb/public/tong-hop/` rồi deploy PublicWeb |
| Flutter APK khách | `./VoCucPhuong_DatVeApp/build-apk.sh` |
| Flutter APK nội bộ | `./VoCucPhuong_FlutterApp/build-apk.sh` |

Yêu cầu build Flutter: JDK 17 (Temurin), Android SDK tại `/opt/homebrew/share/android-commandlinetools`, keystore release tại `~/.vocucphuong-keystore/`.

## Tài liệu đồ án

→ Xem chi tiết trong [BaoCao/README.md](BaoCao/README.md). Có sẵn 12 PNG sơ đồ trong [BaoCao/images/](BaoCao/images/) để chèn vào Word.

## Liên kết khác

- GitHub: https://github.com/QuangMinh02052004/Vo_Cuc_Phuong_TongHop_Project.git
- Báo cáo tuần: [BaoCao/bao-cao-tuan/](BaoCao/bao-cao-tuan/)
