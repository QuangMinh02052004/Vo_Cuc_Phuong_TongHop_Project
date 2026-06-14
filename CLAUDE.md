# CLAUDE.md — Võ Cúc Phương Platform

Hướng dẫn làm việc với AI assistant (Claude / Cursor / Copilot) cho project quản lý nhà xe Võ Cúc Phương.

## Bối cảnh

Nền tảng quản lý nhà xe Võ Cúc Phương — 2 luồng nghiệp vụ song song trên cùng hạ tầng:

- **Hành khách**: đặt vé online (DatVe) + bán vé tại quầy (TongHop) + tài xế quét QR (`/driver`).
- **Hàng hoá**: vận chuyển ký gửi (NhapHang) + đồng bộ ngược với TongHop cho đơn dọc đường.

## Kiến trúc

- Monorepo `Vo_Cuc_Phuong/` — naming convention `VoCucPhuong_*`.
- `VoCucPhuong_PublicWeb` (Next.js App Router) là backend chung — host `/api/nhap-hang/*` + `/api/tong-hop/*`, serve static `/nhap-hang/` và `/tong-hop/`. Deploy: `vocucphuongmanage.vercel.app`.
- `VoCucPhuong_DatVe` (Next.js) là web khách + `/driver`. Deploy: `vocucphuong.vercel.app`.
- `VoCucPhuong_NhapHang` — source HTML/JS, sync với `VoCucPhuong_PublicWeb/public/nhap-hang/`.
- `VoCucPhuong_TongHop/quan-ly-xe-khach/` — React CRA, build → copy sang `VoCucPhuong_PublicWeb/public/tong-hop/`.
- `VoCucPhuong_DatVeApp` (Flutter khách) + `VoCucPhuong_FlutterApp` (Flutter nội bộ 3 tab có login).
- `Auto_Update_Data/` — userscript Tampermonkey sync O2BSoft → NhapHang.
- 3 DB Neon PostgreSQL **riêng biệt** — KHÔNG trộn schema:
  - **NhapHang** `ep-dark-paper`: Products, ProductLogs, Stations, Counters, Users.
  - **TongHop** `ep-autumn-sun`: TH_Bookings, TH_TimeSlots, TH_Routes, TH_SeatLocks, Drivers, Vehicles, TH_Users.
  - **DatVe** `ep-holy-recipe`: Booking, Payment, Routes, Buses, Schedules, NextAuth Users.

## Build & Deploy

```bash
# Backend chung + static (NhapHang, TongHop public)
cd VoCucPhuong_PublicWeb && npx vercel --prod --yes

# Web khách + driver
cd VoCucPhuong_DatVe && npx vercel --prod --yes

# TongHop React (build trước rồi deploy PublicWeb)
cd VoCucPhuong_TongHop/quan-ly-xe-khach && npm run build && \
  cp -r build/* ../../VoCucPhuong_PublicWeb/public/tong-hop/
```

Không dùng `vercel --cwd` (gây empty deploy). Luôn `cd` vào thư mục app trước.

## Nguyên tắc khi cải thiện / tối ưu

1. **Đụng dữ liệu nào, deploy đúng app đó.** Đổi API `nhap-hang`/`tong-hop` → deploy `VoCucPhuong_PublicWeb`. Đổi web khách → deploy `VoCucPhuong_DatVe`. Build TongHop React phải copy sang `public/tong-hop/` trước.

2. **Realtime nhẹ, không dịch vụ trả phí.** Dùng polling `?since=` + `clientReqId` (3s delta) + BroadcastChannel `vcp-route-sync` cho multi-tab. KHÔNG đề xuất Pusher/Ably/Firebase/Socket.io.

3. **Idempotency bắt buộc.** Mọi POST tạo đơn/booking phải có `clientReqId` (hoặc id ngoại sinh như mã O2BSoft) + UNIQUE index + `ON CONFLICT` để retry không sinh trùng.

4. **Phân quyền JSONB + scope theo trạm.**
   - TongHop: 15 perm keys mang trong JWT, mỗi route check `hasPerm()`.
   - NhapHang: `hasPerm()` + `hasGlobalStationAccess()` — user trạm chỉ thấy đơn của trạm mình.
   - Password plain-text cũ tự rehash bcrypt khi user login lần đầu.

5. **UI quy ước:**
   - Trang public/khách (`vocucphuong.com`, `/tin-tuc`, landing): **KHÔNG emoji, KHÔNG icon vui** — trang khách phải pro.
   - Trang nội bộ: **toast auto-dismiss 3s** thay `alert()`, **modal custom** thay `confirm()`, **VND auto-format** mọi ô tiền.
   - Vietnamese UI mặc định.
   - Default date filter = hôm nay.

6. **Soft-delete + audit log.** Không xoá vĩnh viễn đơn/booking. Set `status='cancelled'` + ghi `changedBy` vào `ProductLogs`. Đơn cancelled hiện gạch ngang xám, KHÔNG tính doanh thu/thống kê. TongHop dùng `deletedAt` cho routes. DatVe KHÔNG có nút Xoá.

7. **Tách doanh thu 3 nguồn.** Quầy (TongHop) / Online (DatVe) / Hàng (NhapHang) — 3 cột riêng trong dashboard, KHÔNG cộng dồn.

8. **Fire-and-forget cho việc phụ.** POST trả response ngay, log + sync TongHop chạy background qua `Promise.all(bgTasks).catch(()=>{})`. Reconciliation cron là safety net.

9. **Cache-bust JS tĩnh.** Khi sửa `modal.js / script.js / auth.js / warehouse.js` phải tăng `?v=X.X` trong HTML để tránh browser cache.

10. **Routes/Stations 2 chiều.** Pickup tự đảo hướng theo route (pickup ↔ dropoff). Webhook `/api/tong-hop/routes/by-datve/[id]` sync 2 chiều TongHop ↔ DatVe. Thống kê đọc chung từ 1 nguồn.

11. **NhapHang renderTable() destroys DOM.** Sau mỗi `tbody.innerHTML = ...` phải re-attach event listeners (VND format, click).

12. **Mã đơn NhapHang `YYMMDD.SSNN`** — SS = mã trạm NHẬN (từ dropdown), NN = seq. Server sinh qua atomic upsert `Counters`. Riêng đơn từ O2BSoft (v0.10+) dùng nguyên mã O2BSoft làm id.

## Ưu tiên khi gợi ý cải thiện

- Bỏ thao tác thừa cho nhân viên (giảm click, auto-detect station từ note, autocomplete khách quen, drag-drop ticket list).
- Bảo vệ chống race condition (lock ghế 10–15s, `isTransferring` boolean, atomic counter).
- Tối ưu cold-start Vercel (interval 30s, lazy mount, preload background).
- Tránh thay đổi schema DB chính nếu chỉ là UI/UX (đây là đồ án tốt nghiệp — schema đã document trong `BaoCao/01-database-schema.md`).

## KHÔNG tự ý

- Đổi DB schema khi không có yêu cầu rõ.
- Tách module thành microservice.
- Đề xuất Redis / Kafka / Docker prod (Vercel + Neon là đủ; `infrastructure/` giữ phòng VPS chứ không dùng).
- Refactor lớn ngoài scope task.
- Thêm dependency mới nếu không cần thiết (giữ bundle nhẹ).
- Dùng `git push --force`, `git reset --hard`, `--no-verify`.
- Skip hooks pre-commit.

## Workflow

- Sau mỗi lần sửa code: **auto deploy Vercel + auto push GitHub**, không hỏi yes/no.
- Không hỏi xác nhận từng bước cho task lớn — cứ làm thẳng, báo cáo cuối.
- Không tạo file `.md` plan/summary nếu user không yêu cầu.
- Comment trong code: chỉ viết khi *Why* không hiển nhiên. Không docstring dài.

## Tài liệu tham khảo

- `BaoCao/01-database-schema.md` — schema 3 DB.
- `BaoCao/02-erd.md` — ERD.
- `BaoCao/03-use-case.md` — Use Case Diagram.
- `BaoCao/04-sequence-diagrams.md` — Sequence.
- `BaoCao/05-mo-ta-nghiep-vu.md` — Mô tả nghiệp vụ.
- `BaoCao/bao-cao-tuan/` — Báo cáo tuần (Tuan3 → Tuan8).
- `README.md` — Tổng quan monorepo.
