-- =============================================
-- SCRIPT: Insert dữ liệu mẫu cho Hệ Thống Quản Lý Hàng Hóa
-- Project: NhapHang (Migration từ Firebase sang SQL Server)
-- Ngày tạo: 04-12-2025
-- =============================================

USE [VoCucPhuong_NhapHang];
GO

PRINT '═══════════════════════════════════════════════════════════════';
PRINT '📥 THÊM DỮ LIỆU MẪU';
PRINT '═══════════════════════════════════════════════════════════════';
GO

-- =============================================
-- THÊM USERS (Người dùng mặc định)
-- =============================================
PRINT '';
PRINT '👥 Thêm Users...';

-- Xóa users cũ nếu có
DELETE FROM Users WHERE id IN ('1', '2', '3');

INSERT INTO Users (id, username, password, fullName, role, station, active, createdAt) VALUES
    ('1', 'admin', 'admin123', N'Quản trị viên', 'admin', '01 - AN ĐÔNG', 1, GETDATE()),
    ('2', 'lethanhtam', '123456', N'Lê Thanh Tâm', 'employee', '01 - AN ĐÔNG', 1, GETDATE()),
    ('3', 'nhanvien1', '123456', N'Nhân viên 1', 'employee', '02 - HÀNG XANH', 1, GETDATE());

PRINT '✅ Đã thêm 3 users (admin, lethanhtam, nhanvien1)';
GO

-- =============================================
-- THÊM STATIONS (Các trạm)
-- =============================================
PRINT '';
PRINT '🚉 Thêm Stations...';

-- Xóa stations cũ nếu có
DELETE FROM Stations;

INSERT INTO Stations (code, name, fullName, isActive) VALUES
    ('00', N'DỌC ĐƯỜNG', '00 - DỌC ĐƯỜNG', 1),
    ('01', N'AN ĐÔNG', '01 - AN ĐÔNG', 1),
    ('02', N'HÀNG XANH', '02 - HÀNG XANH', 1),
    ('03', N'LONG KHÁNH', '03 - LONG KHÁNH', 1),
    ('04', N'TRẠM 97', '04 - TRẠM 97', 1),
    ('05', N'XUÂN TRƯỜNG', '05 - XUÂN TRƯỜNG', 1),
    ('06', N'SÔNG RAY', '06 - SÔNG RAY', 1),
    ('07', N'XUÂN LỮ', '07 - XUÂN LỮ', 1),
    ('08', N'BẢO BÌNH', '08 - BẢO BÌNH', 1),
    ('09', N'HAI MÃO', '09 - HAI MÃO', 1),
    ('10', N'ÔNG ĐÔN', '10 - ÔNG ĐÔN', 1),
    ('11', N'XUÂN ĐÀ', '11 - XUÂN ĐÀ', 1),
    ('13', N'XUÂN HƯNG', '13 - XUÂN HƯNG', 1);

PRINT '✅ Đã thêm 13 stations';
GO

-- =============================================
-- THÊM DỮ LIỆU MẪU PRODUCTS (Tùy chọn)
-- =============================================
PRINT '';
PRINT '📦 Thêm Products mẫu...';

-- Xóa products cũ nếu có
DELETE FROM Products WHERE id LIKE 'SAMPLE%';

-- Thêm một số products mẫu
INSERT INTO Products (
    id, senderName, senderPhone, senderStation,
    receiverName, receiverPhone, station,
    productType, vehicle, insurance, totalAmount,
    paymentStatus, employee, createdBy, sendDate, status
) VALUES
(
    'SAMPLE-001',
    N'Nguyễn Văn A',
    '0901234567',
    '01 - AN ĐÔNG',
    N'Trần Thị B',
    '0912345678',
    '03 - LONG KHÁNH',
    N'03 - Thùng',
    '01031',
    10000,
    50000,
    'paid',
    N'Lê Thanh Tâm',
    N'Lê Thanh Tâm',
    GETDATE(),
    'pending'
),
(
    'SAMPLE-002',
    N'Lê Văn C',
    '0923456789',
    '02 - HÀNG XANH',
    N'Phạm Thị D',
    '0934567890',
    '05 - XUÂN TRƯỜNG',
    N'24 - Thực phẩm',
    '04145',
    5000,
    30000,
    'unpaid',
    N'Nhân viên 1',
    N'Nhân viên 1',
    GETDATE(),
    'pending'
),
(
    'SAMPLE-003',
    N'Hoàng Văn E',
    '0945678901',
    '01 - AN ĐÔNG',
    N'Vũ Thị F',
    '0956789012',
    '08 - BẢO BÌNH',
    N'21 - Điện tử',
    '05307',
    20000,
    150000,
    'paid',
    N'Lê Thanh Tâm',
    N'Lê Thanh Tâm',
    GETDATE(),
    'delivered'
);

PRINT '✅ Đã thêm 3 products mẫu';
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '✅ ✅ ✅ HOÀN TẤT THÊM DỮ LIỆU MẪU! ✅ ✅ ✅';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT '📋 Dữ liệu đã thêm:';
PRINT '   • 3 Users (admin, lethanhtam, nhanvien1)';
PRINT '   • 13 Stations';
PRINT '   • 3 Products mẫu';
PRINT '';
PRINT '🔐 Tài khoản đăng nhập:';
PRINT '   • Username: admin      | Password: admin123 | Role: admin';
PRINT '   • Username: lethanhtam | Password: 123456   | Role: employee';
PRINT '   • Username: nhanvien1  | Password: 123456   | Role: employee';
PRINT '';
PRINT '🚀 Bước tiếp theo:';
PRINT '   1. Chạy script migration để import dữ liệu từ Firebase (nếu có)';
PRINT '   2. Setup backend API cho NhapHang';
PRINT '   3. Cập nhật frontend để kết nối với SQL Server';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
GO
