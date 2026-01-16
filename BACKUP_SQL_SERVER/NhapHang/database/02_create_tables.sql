-- =============================================
-- SCRIPT: Tạo các bảng cho Hệ Thống Quản Lý Hàng Hóa
-- Project: NhapHang (Migration từ Firebase sang SQL Server)
-- Ngày tạo: 04-12-2025
-- =============================================

USE [VoCucPhuong_NhapHang];
GO

PRINT '═══════════════════════════════════════════════════════════════';
PRINT '📦 TẠO CÁC BẢNG CHO HỆ THỐNG QUẢN LÝ HÀNG HÓA';
PRINT '═══════════════════════════════════════════════════════════════';
GO

-- =============================================
-- BẢNG 1: USERS (Người dùng hệ thống)
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Users' and xtype='U')
BEGIN
    CREATE TABLE Users (
        id NVARCHAR(50) PRIMARY KEY,
        username NVARCHAR(50) NOT NULL UNIQUE,
        password NVARCHAR(255) NOT NULL,
        fullName NVARCHAR(100) NOT NULL,
        role NVARCHAR(20) NOT NULL DEFAULT 'employee', -- 'admin' hoặc 'employee'
        station NVARCHAR(100) NULL,
        active BIT NOT NULL DEFAULT 1,
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX idx_users_username ON Users(username);
    CREATE INDEX idx_users_station ON Users(station);

    PRINT '✅ Đã tạo bảng Users';
END
ELSE
BEGIN
    PRINT '⚠️  Bảng Users đã tồn tại';
END
GO

-- =============================================
-- BẢNG 2: STATIONS (Các trạm/điểm gửi hàng)
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Stations' and xtype='U')
BEGIN
    CREATE TABLE Stations (
        id INT IDENTITY(1,1) PRIMARY KEY,
        code NVARCHAR(10) NOT NULL UNIQUE, -- Ví dụ: '01', '02'
        name NVARCHAR(100) NOT NULL, -- Ví dụ: 'AN ĐỒNG'
        fullName NVARCHAR(150) NOT NULL, -- Ví dụ: '01 - AN ĐỒNG'
        address NVARCHAR(255) NULL,
        phone NVARCHAR(20) NULL,
        isActive BIT NOT NULL DEFAULT 1,
        createdAt DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX idx_stations_code ON Stations(code);
    CREATE INDEX idx_stations_name ON Stations(name);

    PRINT '✅ Đã tạo bảng Stations';
END
ELSE
BEGIN
    PRINT '⚠️  Bảng Stations đã tồn tại';
END
GO

-- =============================================
-- BẢNG 3: PRODUCTS (Hàng hóa)
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Products' and xtype='U')
BEGIN
    CREATE TABLE Products (
        id NVARCHAR(50) PRIMARY KEY, -- Ví dụ: 'SG-01-041225-001'

        -- Thông tin người gửi
        senderName NVARCHAR(100) NOT NULL,
        senderPhone NVARCHAR(20) NOT NULL,
        senderStation NVARCHAR(100) NOT NULL, -- Trạm gửi hàng (ví dụ: '01 - AN ĐỒNG')

        -- Thông tin người nhận
        receiverName NVARCHAR(100) NOT NULL,
        receiverPhone NVARCHAR(20) NOT NULL,
        station NVARCHAR(100) NOT NULL, -- Trạm nhận hàng (ví dụ: '02 - BÌNH DƯƠNG')

        -- Thông tin hàng hóa
        productType NVARCHAR(200) NOT NULL, -- Loại hàng (ví dụ: 'Quần áo', 'Thực phẩm')
        vehicle NVARCHAR(100) NULL, -- Phương tiện vận chuyển

        -- Thông tin tài chính
        insurance DECIMAL(10,2) NOT NULL DEFAULT 0, -- Tiền bảo hiểm
        totalAmount DECIMAL(10,2) NOT NULL DEFAULT 0, -- Tổng tiền
        paymentStatus NVARCHAR(20) NOT NULL DEFAULT 'unpaid', -- 'paid' hoặc 'unpaid'

        -- Thông tin nhân viên và thời gian
        employee NVARCHAR(100) NULL, -- Tên nhân viên xử lý
        createdBy NVARCHAR(100) NULL, -- Người tạo đơn
        sendDate DATETIME NOT NULL, -- Ngày gửi hàng

        -- Trạng thái và metadata
        status NVARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'in_transit', 'delivered', 'cancelled'
        notes NVARCHAR(500) NULL, -- Ghi chú
        createdAt DATETIME NOT NULL DEFAULT GETDATE(),
        updatedAt DATETIME NOT NULL DEFAULT GETDATE()
    );

    -- Indexes để tối ưu truy vấn
    CREATE INDEX idx_products_sendDate ON Products(sendDate);
    CREATE INDEX idx_products_senderStation ON Products(senderStation);
    CREATE INDEX idx_products_station ON Products(station);
    CREATE INDEX idx_products_paymentStatus ON Products(paymentStatus);
    CREATE INDEX idx_products_status ON Products(status);
    CREATE INDEX idx_products_receiverPhone ON Products(receiverPhone);
    CREATE INDEX idx_products_senderPhone ON Products(senderPhone);

    PRINT '✅ Đã tạo bảng Products';
END
ELSE
BEGIN
    PRINT '⚠️  Bảng Products đã tồn tại';
END
GO

-- =============================================
-- BẢNG 4: COUNTERS (Bộ đếm cho mã hàng)
-- =============================================
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Counters' and xtype='U')
BEGIN
    CREATE TABLE Counters (
        id INT IDENTITY(1,1) PRIMARY KEY,
        counterKey NVARCHAR(100) NOT NULL UNIQUE, -- Ví dụ: 'counter_01 - AN ĐỒNG_041225'
        value INT NOT NULL DEFAULT 0, -- Giá trị đếm hiện tại
        station NVARCHAR(100) NOT NULL, -- Trạm
        dateKey NVARCHAR(20) NOT NULL, -- Ngày (format: DDMMYY)
        lastUpdated DATETIME NOT NULL DEFAULT GETDATE()
    );

    CREATE INDEX idx_counters_station_date ON Counters(station, dateKey);
    CREATE INDEX idx_counters_key ON Counters(counterKey);

    PRINT '✅ Đã tạo bảng Counters';
END
ELSE
BEGIN
    PRINT '⚠️  Bảng Counters đã tồn tại';
END
GO

PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '✅ ✅ ✅ HOÀN TẤT TẠO CÁC BẢNG! ✅ ✅ ✅';
PRINT '═══════════════════════════════════════════════════════════════';
PRINT '';
PRINT '📋 Đã tạo các bảng:';
PRINT '   • Users (Người dùng hệ thống)';
PRINT '   • Stations (Các trạm gửi/nhận hàng)';
PRINT '   • Products (Hàng hóa)';
PRINT '   • Counters (Bộ đếm tự động)';
PRINT '';
PRINT '🚀 Bước tiếp theo:';
PRINT '   1. Chạy script 03_insert_sample_data.sql để thêm dữ liệu mẫu';
PRINT '   2. Chạy migration script để import dữ liệu từ Firebase';
PRINT '';
PRINT '═══════════════════════════════════════════════════════════════';
GO
