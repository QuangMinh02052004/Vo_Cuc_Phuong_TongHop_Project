-- =============================================
-- SCRIPT: Tạo Database cho Hệ Thống Quản Lý Hàng Hóa
-- Project: NhapHang (Migration từ Firebase sang SQL Server)
-- Ngày tạo: 04-12-2025
-- =============================================

-- Tạo database nếu chưa có
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'VoCucPhuong_NhapHang')
BEGIN
    CREATE DATABASE [VoCucPhuong_NhapHang];
    PRINT '✅ Đã tạo database VoCucPhuong_NhapHang';
END
ELSE
BEGIN
    PRINT '⚠️  Database VoCucPhuong_NhapHang đã tồn tại';
END
GO

-- Sử dụng database
USE [VoCucPhuong_NhapHang];
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '✅ Database VoCucPhuong_NhapHang đã sẵn sàng!';
PRINT '═══════════════════════════════════════════════════════════════';
GO
