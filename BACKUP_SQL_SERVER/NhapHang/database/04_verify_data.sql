-- =============================================
-- SCRIPT: Verify dữ liệu sau migration
-- =============================================

USE [VoCucPhuong_NhapHang];
GO

PRINT '═══════════════════════════════════════════════════════════════';
PRINT '📊 KIỂM TRA DỮ LIỆU SAU MIGRATION';
PRINT '═══════════════════════════════════════════════════════════════';
GO

-- Đếm tổng số records
PRINT '';
PRINT '📈 Tổng số records:';
SELECT 'Users' as TableName, COUNT(*) as TotalRecords FROM Users
UNION ALL
SELECT 'Stations', COUNT(*) FROM Stations
UNION ALL
SELECT 'Products', COUNT(*) FROM Products
UNION ALL
SELECT 'Counters', COUNT(*) FROM Counters;
GO

-- Xem 10 products gần nhất
PRINT '';
PRINT '📦 10 Products gần nhất:';
SELECT TOP 10
    id,
    receiverName,
    station,
    productType,
    totalAmount,
    paymentStatus,
    sendDate
FROM Products
ORDER BY sendDate DESC;
GO

-- Thống kê theo trạm nhận
PRINT '';
PRINT '🚉 Thống kê theo trạm nhận:';
SELECT
    station as [Trạm nhận],
    COUNT(*) as [Số lượng hàng],
    SUM(totalAmount) as [Tổng tiền],
    SUM(CASE WHEN paymentStatus = 'paid' THEN 1 ELSE 0 END) as [Đã thanh toán],
    SUM(CASE WHEN paymentStatus = 'unpaid' THEN 1 ELSE 0 END) as [Chưa thanh toán]
FROM Products
GROUP BY station
ORDER BY COUNT(*) DESC;
GO

-- Thống kê theo trạm gửi
PRINT '';
PRINT '📤 Thống kê theo trạm gửi:';
SELECT
    senderStation as [Trạm gửi],
    COUNT(*) as [Số lượng hàng],
    SUM(totalAmount) as [Tổng tiền]
FROM Products
GROUP BY senderStation
ORDER BY COUNT(*) DESC;
GO

-- Xem tất cả users
PRINT '';
PRINT '👥 Danh sách Users:';
SELECT
    id,
    username,
    fullName,
    role,
    station,
    active,
    createdAt
FROM Users
ORDER BY role DESC, username;
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '✅ HOÀN TẤT KIỂM TRA!';
PRINT '═══════════════════════════════════════════════════════════════';
GO
