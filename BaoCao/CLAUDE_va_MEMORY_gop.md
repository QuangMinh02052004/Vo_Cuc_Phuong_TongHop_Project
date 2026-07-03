# Tài liệu tổng hợp: CLAUDE.md + MEMORY.md

> File gộp phục vụ viết báo cáo. Gồm 2 phần: (1) CLAUDE.md — hướng dẫn dự án; (2) MEMORY.md — bộ nhớ tích luỹ.

---

# PHẦN 1 — CLAUDE.md (Hướng dẫn dự án)

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

---

# PHẦN 2 — MEMORY.md (Bộ nhớ dự án)

# Project Memory - Vo Cuc Phuong

## Project Structure
- **Monorepo**: `/Users/lequangminh/VoCucPhuong_TongHop/Vo_Cuc_Phuong/`
- **Next.js app** (API + hosting): `VoCucPhuong_PublicWeb/` - deployed at https://vocucphuongmanage.vercel.app
- **React CRA app** (quan-ly-xe-khach): `VoCucPhuong_TongHop/quan-ly-xe-khach/` - built and copied to `VoCucPhuong_PublicWeb/public/tong-hop/`
- **NhapHang frontend**: `VoCucPhuong_PublicWeb/public/nhap-hang/`
- **NhapHang source**: `VoCucPhuong_NhapHang/` (gốc, cần sync với VoCucPhuong_PublicWeb/public/nhap-hang/)
- **DatVe app**: `VoCucPhuong_DatVe/` - deployed at https://vocucphuong.vercel.app
- **Flutter mobile app**: `VoCucPhuong_FlutterApp/`
- **GitHub**: https://github.com/QuangMinh02052004/Vo_Cuc_Phuong_TongHop_Project.git

## Databases (Neon PostgreSQL)
- **NhapHang**: ep-dark-paper (products, productlogs, users, stations, counters)
- **TongHop**: ep-autumn-sun (bookings, timeslots, customers, seat-locks, drivers, vehicles, freight, users)
- **DatVe**: ep-holy-recipe (bookings, payments, users, routes, buses, schedules)

## Build & Deploy Workflow
1. `cd quan-ly-xe-khach && npm run build`
2. `cp -r build/* ../VoCucPhuong_PublicWeb/public/tong-hop/`
3. `cd VoCucPhuong_PublicWeb && npx vercel --prod --yes`
- **Auto-deploy after every fix** — user preference

## Key Files - TongHop (quan-ly-xe-khach)
- `src/context/BookingContext.js` - Central state: bookings, timeslots, transfer queue, seat locks
- `src/components/SeatMapNew.jsx` - Seat map with 28 seats, transfer/swap, drag-drop ticket list
- `src/components/PassengerFormNew.jsx` - Booking form with auto-detect station from note
- `src/data/stations.js` - Station aliases for auto-detect (e.g., 'tco' -> 'Tra Co')
- `src/services/api.js` - API service layer
- `src/pages/UserManagementPage.jsx` - Quản lý user (admin only), dùng axios trực tiếp (không qua api.js)

## Key Features Implemented
- **Transfer queue** (multi-select): `transferQueue` array in BookingContext, button on each card to add/remove from queue
- **Seat lock system**: Prevents concurrent seat selection by different users (15s refresh)
- **Toast notifications**: Non-blocking floating notifications (auto-dismiss 3s)
- **Fire-and-forget**: NhapHang backend returns response immediately, logs/sync run in background
- **Station auto-detect**: Note field auto-detects station abbreviations on blur
- **Custom modals** (thay thế alert/confirm): NhapHang dùng `modal.js` (Promise-based showConfirmModal/showAlertModal). TongHop React dùng `ConfirmModal.jsx` component.
- **Auto-format VND**: Input tiền tự động format 1000→1.000, 1000000→1.000.000. Logic nằm trong `modal.js` (formatVNDCurrency/parseVNDCurrency/setupVNDCurrencyInput). NhapHang: ô totalAmount + deliveredAmount. TongHop React: amount/deposit/paid trong PassengerFormNew.
- **Audit log người sửa**: api.js gửi `changedBy: getCurrentUserName()` khi update/delete product
- **Soft delete (cancel) đơn hàng**: Bấm "Xóa" → đánh dấu status='cancelled' (không xóa thật). Đơn hủy hiện màu xám + gạch ngang, không cho chỉnh sửa/in. Modal hủy có ô ghi chú lý do. Đơn hủy KHÔNG tính vào thống kê + doanh thu dashboard. CSS class: `.row-cancelled`, `.status-cancelled`. Fixed 2026-03-24.
- **Product ID format**: `YYMMDD.SSNN` — SS = mã trạm NHẬN (từ dropdown), NN = số thứ tự. Server sinh mã chính thức qua counter API (atomic upsert). Client gọi GET `/api/nhap-hang/counters?station=XX` để preview.

## User Preferences
- Prefers toast notifications over alert() dialogs
- Wants minimal clicks - direct actions on cards rather than opening forms
- Vietnamese UI language
- Prefers fast iteration: implement -> deploy -> test -> feedback loop
- **Auto-deploy**: Sau mỗi lần sửa code, tự động deploy lên Vercel không cần hỏi
- **Auto-save to memory**: Sau mỗi lần sửa, ghi lại vào memory để nhớ cho lần sau

## API Patterns
- Next.js App Router: `app/api/tong-hop/bookings/[id]/route.js`
- PATCH for partial updates, POST for create, DELETE for soft-delete (cancel)
- Booking fields: id, name, phone, seatNumber, timeSlotId, timeSlot, date, route, dropoffMethod, dropoffAddress, note, amount, paid
- Product DELETE → soft delete: set status='cancelled', log cancel note

## Common Issues & Solutions
- **Race condition on rapid clicks**: Use `isTransferring` boolean lock state
- **Data corruption from double-clicks**: Block all transfer clicks while transfer is in progress
- **Context window overflow**: Sessions get long - save progress to memory
- **Vercel cold start**: Auto-refresh interval set to 30s to reduce load
- **NaN currency display**: `totalAmount` từ PostgreSQL trả về string, cần `parseFloat()` trước khi cộng. Fixed 2026-03-24 trong statistics.js, script.js, warehouse.js (cả 2 thư mục nhap-hang)
- **Default date filter = today**: Tất cả trang có bộ lọc ngày mặc định chỉ hiện trong ngày hôm nay. User tự đổi ngày khi cần. Fixed 2026-03-24.
- **NhapHang renderTable() destroys DOM**: `tbody.innerHTML = ...` xóa sạch input cũ → phải re-attach event listeners (VND format) sau mỗi lần render. Fixed 2026-03-24.
- **NhapHang function name collision**: `showConfirmModal()` local trong script.js (form validation) trùng tên với `window.showConfirmModal()` từ modal.js (confirm dialog) → đổi local thành `showProductConfirmModal()`. Fixed 2026-03-24.
- **Cache-bust JS files**: Luôn thêm `?v=X.X` vào tất cả script tags trong HTML (modal.js, script.js, auth.js). Khi sửa file nào thì tăng version lên để tránh browser cache.
- **TH_Users thiếu cột**: Bảng gốc không có email/phone → thêm via ALTER TABLE trong setup route. Fixed 2026-03-24.
- **Product ID dùng trạm NHẬN**: Không phải trạm gửi. Client preview + server đều dùng trạm nhận từ dropdown. Fixed 2026-03-24.

## Key Files - NhapHang
- `js/modal.js` - Custom modals (showConfirmModal/showAlertModal) + VND currency formatting (formatVNDCurrency/parseVNDCurrency/setupVNDCurrencyInput)
- `js/script.js` - Main logic, renderTable(), form handling. Local `showProductConfirmModal()` cho form submit. `showCancelModal()` cho hủy đơn với ô ghi chú.
- `js/api.js` - API calls, `getCurrentUserName()` cho audit log. `deleteProduct(id, cancelNote)` gửi cancelNote.
- `js/warehouse.js` - Warehouse page logic, cũng có VND format cho deliveredAmount

## Memory Files (danh mục ghi chú)
- feedback_auto_deploy.md — Auto-deploy & auto-save memory preference
- feedback_auto_deploy_and_push.md — After every code edit: auto-deploy Vercel + auto-push GitHub, no asking
- reference_github_repo.md — GitHub repo URL for monorepo (push target)
- project_summary.md — Full project summary file location
- project_cskh_removed.md — CSKH module removed 2026-04-24 — do not recreate
- project_multitab_sync.md — TongHop multi-tab toast + refresh via BroadcastChannel('vcp-route-sync')
- project_routes_3way_sync.md — Routes 2-chiều TongHop↔DatVe + Thống kê đọc chung; webhook by-datve/[id]
- project_routes_delete_policy.md — TongHop soft-delete (deletedAt), DatVe không có nút Xóa
- project_realtime_sync.md — Realtime ~3s NhapHang↔TongHop: clientReqId + ?since= delta + polling, no paid services
- feedback_no_yesno_prompts.md — Không hỏi xin phép yes/no, cứ làm thẳng kể cả task lớn
- project_nhaphang_permissions.md — NhapHang permissions: cột Users.permissions JSONB + scope, hasPerm()/hasGlobalStationAccess()
- project_tonghop_permissions.md — TongHop permissions: 15 keys, JSONB column, JWT carries perms, plain→bcrypt rehash on login
- feedback_vercel_no_cwd_flag.md — Never use `vercel --cwd` flag; always `cd VoCucPhuong_PublicWeb && vercel --prod` to avoid empty deploys
- project_phase2_features.md — TongHop Phase 2 shipped 2026-05-02: báo cáo email Resend, dashboard heatmap, autocomplete khách
- project_datve_disable_booking.md — DatVe admin toggle tắt đặt vé online (booking_enabled flag, /admin/settings) shipped 2026-05-02
- feedback_no_emoji_on_public_web.md — Không dùng emoji/icon trên trang public (vocucphuong.com): trang web khách hàng phải trông pro
- project_repo_structure.md — Cấu trúc monorepo sau dọn 2026-06-08: docs/, infrastructure/, bao-cao-tuan/
