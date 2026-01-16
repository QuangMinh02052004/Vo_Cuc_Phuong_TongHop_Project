import { query, queryOne } from '../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

export async function GET(request) {
  const results = [];

  try {
    // Tạo bảng Products
    await query(`
      CREATE TABLE IF NOT EXISTS "Products" (
        id VARCHAR(50) PRIMARY KEY,
        "senderName" VARCHAR(200),
        "senderPhone" VARCHAR(20),
        "senderStation" VARCHAR(200),
        "receiverName" VARCHAR(200) NOT NULL,
        "receiverPhone" VARCHAR(20) NOT NULL,
        station VARCHAR(200) NOT NULL,
        "productType" VARCHAR(200),
        quantity VARCHAR(200),
        vehicle VARCHAR(100),
        insurance DECIMAL(18, 2) DEFAULT 0,
        "totalAmount" DECIMAL(18, 2) DEFAULT 0,
        "paymentStatus" VARCHAR(20) DEFAULT 'unpaid',
        status VARCHAR(20) DEFAULT 'pending',
        "deliveryStatus" VARCHAR(50) DEFAULT 'pending',
        employee VARCHAR(100),
        "createdBy" VARCHAR(100),
        notes TEXT,
        "sendDate" TIMESTAMP DEFAULT NOW(),
        "deliveredAt" TIMESTAMP,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✅ Products table ready');

    // Tạo bảng ProductLogs
    await query(`
      CREATE TABLE IF NOT EXISTS "ProductLogs" (
        "logId" SERIAL PRIMARY KEY,
        "productId" VARCHAR(50) NOT NULL,
        action VARCHAR(20) NOT NULL,
        field VARCHAR(50),
        "oldValue" TEXT,
        "newValue" TEXT,
        "changedBy" VARCHAR(100) NOT NULL,
        "changedAt" TIMESTAMP DEFAULT NOW(),
        "ipAddress" VARCHAR(50)
      )
    `);
    results.push('✅ ProductLogs table ready');

    // Tạo bảng NhapHangUsers
    await query(`
      CREATE TABLE IF NOT EXISTS "NhapHangUsers" (
        id VARCHAR(50) PRIMARY KEY,
        username VARCHAR(100) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        "fullName" VARCHAR(200) NOT NULL,
        role VARCHAR(20) DEFAULT 'employee',
        station VARCHAR(200),
        active BOOLEAN DEFAULT true,
        "createdAt" TIMESTAMP DEFAULT NOW(),
        "updatedAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✅ NhapHangUsers table ready');

    // Tạo bảng Stations
    await query(`
      CREATE TABLE IF NOT EXISTS "Stations" (
        id SERIAL PRIMARY KEY,
        code VARCHAR(10) NOT NULL,
        name VARCHAR(200) NOT NULL,
        address VARCHAR(500),
        phone VARCHAR(20),
        "isActive" BOOLEAN DEFAULT true,
        "createdAt" TIMESTAMP DEFAULT NOW()
      )
    `);
    results.push('✅ Stations table ready');

    // Seed admin user
    const existingAdmin = await queryOne('SELECT id FROM "NhapHangUsers" WHERE username = $1', ['admin']);
    if (!existingAdmin) {
      const hashedPassword = await bcrypt.hash('123456', 10);
      await query(`
        INSERT INTO "NhapHangUsers" (id, username, password, "fullName", role, station, active)
        VALUES ($1, $2, $3, $4, $5, $6, true)
      `, ['ADMIN001', 'admin', hashedPassword, 'Admin Nhập Hàng', 'admin', '01 - An Đông']);
      results.push('✅ Admin user created (admin/123456)');
    } else {
      results.push('⚠️ Admin user already exists');
    }

    // Seed staffad user
    const existingStaff = await queryOne('SELECT id FROM "NhapHangUsers" WHERE username = $1', ['staffad']);
    if (!existingStaff) {
      const hashedPassword = await bcrypt.hash('123456', 10);
      await query(`
        INSERT INTO "NhapHangUsers" (id, username, password, "fullName", role, station, active)
        VALUES ($1, $2, $3, $4, $5, $6, true)
      `, ['STAFF001', 'staffad', hashedPassword, 'Staff An Đông', 'employee', '01 - An Đông']);
      results.push('✅ Staff user created (staffad/123456)');
    } else {
      results.push('⚠️ Staff user already exists');
    }

    // Seed stations
    const existingStation = await queryOne('SELECT id FROM "Stations" LIMIT 1');
    if (!existingStation) {
      const stations = [
        { code: '01', name: 'An Đông', address: 'Chợ An Đông, Q5' },
        { code: '02', name: 'Metro', address: 'Metro Q2' },
        { code: '03', name: 'Long Khánh', address: 'Long Khánh, Đồng Nai' },
        { code: '04', name: 'Biên Hòa', address: 'Biên Hòa, Đồng Nai' }
      ];

      for (const st of stations) {
        await query(`
          INSERT INTO "Stations" (code, name, address, "isActive")
          VALUES ($1, $2, $3, true)
        `, [st.code, st.name, st.address]);
      }
      results.push('✅ Stations seeded');
    } else {
      results.push('⚠️ Stations already exist');
    }

    return NextResponse.json({
      success: true,
      message: 'Database setup completed!',
      results
    });

  } catch (error) {
    return NextResponse.json({
      success: false,
      message: error.message,
      results
    }, { status: 500 });
  }
}
