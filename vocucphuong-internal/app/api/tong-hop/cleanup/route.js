import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: DỌN DẸP DUPLICATE TIMESLOTS
// ===========================================
// POST /api/tong-hop/cleanup

export async function POST(request) {
  try {
    console.log('[Cleanup] Starting duplicate cleanup...');

    // 1. Đếm trước khi xóa
    const beforeCount = await queryTongHop('SELECT COUNT(*) as count FROM "TH_TimeSlots"');
    console.log(`[Cleanup] Before: ${beforeCount[0].count} timeslots`);

    // 2. Xóa duplicates - giữ lại timeslot có ID nhỏ nhất cho mỗi (date, time, route)
    const deleteResult = await queryTongHop(`
      DELETE FROM "TH_TimeSlots"
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM "TH_TimeSlots"
        GROUP BY date, time, route
      )
    `);

    // 3. Đếm sau khi xóa
    const afterCount = await queryTongHop('SELECT COUNT(*) as count FROM "TH_TimeSlots"');
    console.log(`[Cleanup] After: ${afterCount[0].count} timeslots`);

    const deleted = Number(beforeCount[0].count) - Number(afterCount[0].count);

    return NextResponse.json({
      success: true,
      message: `Đã xóa ${deleted} duplicate timeslots`,
      before: Number(beforeCount[0].count),
      after: Number(afterCount[0].count),
      deleted
    });

  } catch (error) {
    console.error('[Cleanup] Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

// GET - Xem thống kê duplicates
export async function GET(request) {
  try {
    // Đếm tổng
    const totalCount = await queryTongHop('SELECT COUNT(*) as count FROM "TH_TimeSlots"');

    // Đếm unique
    const uniqueCount = await queryTongHop(`
      SELECT COUNT(*) as count FROM (
        SELECT DISTINCT date, time, route FROM "TH_TimeSlots"
      ) t
    `);

    // Top duplicates
    const topDuplicates = await queryTongHop(`
      SELECT date, time, route, COUNT(*) as duplicate_count
      FROM "TH_TimeSlots"
      GROUP BY date, time, route
      HAVING COUNT(*) > 1
      ORDER BY duplicate_count DESC
      LIMIT 10
    `);

    return NextResponse.json({
      success: true,
      total: Number(totalCount[0].count),
      unique: Number(uniqueCount[0].count),
      duplicates: Number(totalCount[0].count) - Number(uniqueCount[0].count),
      topDuplicates
    });

  } catch (error) {
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
