import { queryNhapHang, queryOneNhapHang } from '../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

export const dynamic = 'force-dynamic';

// ===========================================
// API: Migration - Dọn dẹp DB & Sync users
// ===========================================
// GET /api/nhap-hang/migrate
//
// 1. Sync users từ NhapHangUsers → NH_Users (nếu chưa có)
// 2. Hash plain text passwords trong NH_Users
// 3. Drop bảng cũ (NhapHangUsers, Products, ProductLogs, Stations)

export async function GET(request) {
  try {
    const results = [];

    // ============================================================
    // 1. Sync users từ NhapHangUsers → NH_Users
    // ============================================================
    const oldUsers = await queryNhapHang(
      'SELECT * FROM "NhapHangUsers"'
    ).catch(() => []);

    if (oldUsers.length > 0) {
      for (const user of oldUsers) {
        // Kiểm tra xem user đã tồn tại trong NH_Users chưa
        const existing = await queryOneNhapHang(
          'SELECT id FROM "Users" WHERE username = $1',
          [user.username]
        );

        if (!existing) {
          // Hash password nếu chưa hash
          let hashedPassword = user.password;
          if (!user.password.startsWith('$2')) {
            hashedPassword = await bcrypt.hash(user.password, 10);
          }

          await queryNhapHang(`
            INSERT INTO "Users" (username, password, "fullName", phone, role, station, active)
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            ON CONFLICT (username) DO NOTHING
          `, [user.username, hashedPassword, user.fullName || user.fullname, user.phone || null, user.role, user.station, user.active]);

          results.push(`Synced user: ${user.username} (from NhapHangUsers → NH_Users)`);
        } else {
          results.push(`User ${user.username} already exists in NH_Users, skipped`);
        }
      }
    } else {
      results.push('No users found in NhapHangUsers (table may not exist)');
    }

    // ============================================================
    // 2. Hash any plain text passwords in NH_Users
    // ============================================================
    const nhUsers = await queryNhapHang('SELECT id, username, password FROM "Users"');

    for (const user of nhUsers) {
      if (user.password && !user.password.startsWith('$2')) {
        const hashed = await bcrypt.hash(user.password, 10);
        await queryNhapHang(
          'UPDATE "Users" SET password = $1 WHERE id = $2',
          [hashed, user.id]
        );
        results.push(`Hashed password for: ${user.username}`);
      }
    }

    // ============================================================
    // 3. Drop old redundant tables
    // ============================================================
    const oldTables = ['ProductLogs', 'Products', 'Stations', 'NhapHangUsers'];
    for (const table of oldTables) {
      await queryNhapHang(`DROP TABLE IF EXISTS "${table}" CASCADE`);
      results.push(`Dropped old table: ${table}`);
    }

    // ============================================================
    // 4. Verify NH_Users has admin
    // ============================================================
    const admin = await queryOneNhapHang(
      'SELECT id, username, role FROM "Users" WHERE username = $1',
      ['admin']
    );

    if (admin) {
      results.push(`Admin account verified: ${admin.username} (role: ${admin.role})`);
    } else {
      // Create admin if missing
      const hashedPassword = await bcrypt.hash('admin123', 10);
      await queryNhapHang(`
        INSERT INTO "Users" (username, password, "fullName", role, station, active)
        VALUES ($1, $2, $3, $4, $5, true)
      `, ['admin', hashedPassword, 'Admin Nhập Hàng', 'admin', null]);
      results.push('Created admin account (password: admin123)');
    }

    // ============================================================
    // 5. Show final state
    // ============================================================
    const finalUsers = await queryNhapHang(
      'SELECT id, username, "fullName", role, station, active FROM "Users" ORDER BY id'
    );

    return NextResponse.json({
      success: true,
      message: 'Migration completed!',
      results,
      currentUsers: finalUsers
    });

  } catch (error) {
    console.error('[Migration] Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
