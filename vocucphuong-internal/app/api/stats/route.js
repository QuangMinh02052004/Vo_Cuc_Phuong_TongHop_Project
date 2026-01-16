import { queryNhapHang, queryTongHop } from '../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: THỐNG KÊ DOANH THU - DOANH SỐ
// ===========================================
// GET /api/stats?period=day|week|month&date=YYYY-MM-DD

// Helper: Lấy khoảng thời gian theo period
function getDateRange(period, baseDate) {
  const date = new Date(baseDate);
  let startDate, endDate;

  switch (period) {
    case 'week':
      // Lấy tuần (Thứ 2 -> Chủ nhật)
      const dayOfWeek = date.getDay();
      const diff = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // Adjust for Monday start
      startDate = new Date(date);
      startDate.setDate(date.getDate() - diff);
      endDate = new Date(startDate);
      endDate.setDate(startDate.getDate() + 6);
      break;

    case 'month':
      // Lấy tháng
      startDate = new Date(date.getFullYear(), date.getMonth(), 1);
      endDate = new Date(date.getFullYear(), date.getMonth() + 1, 0);
      break;

    case 'day':
    default:
      // Lấy ngày
      startDate = new Date(date);
      endDate = new Date(date);
      break;
  }

  return {
    startDate: startDate.toISOString().split('T')[0],
    endDate: endDate.toISOString().split('T')[0]
  };
}

// Helper: Format date DD-MM-YYYY cho TongHop
function formatDateDDMMYYYY(dateStr) {
  const d = new Date(dateStr);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = d.getFullYear();
  return `${day}-${month}-${year}`;
}

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const period = searchParams.get('period') || 'day';
    const dateParam = searchParams.get('date') || new Date().toISOString().split('T')[0];

    const { startDate, endDate } = getDateRange(period, dateParam);

    // Format dates cho TongHop (DD-MM-YYYY)
    const startDateDDMM = formatDateDDMMYYYY(startDate);
    const endDateDDMM = formatDateDDMMYYYY(endDate);

    // =====================
    // 1. THỐNG KÊ NHẬP HÀNG
    // =====================
    const nhapHangStats = await queryNhapHang(`
      SELECT
        COUNT(*) as "totalOrders",
        COALESCE(SUM("totalAmount"), 0) as "totalRevenue",
        COALESCE(SUM(CASE WHEN "paymentStatus" = 'paid' THEN "totalAmount" ELSE 0 END), 0) as "paidAmount",
        COALESCE(SUM(CASE WHEN "paymentStatus" = 'unpaid' THEN "totalAmount" ELSE 0 END), 0) as "unpaidAmount",
        COUNT(CASE WHEN status = 'delivered' THEN 1 END) as "deliveredOrders",
        COUNT(CASE WHEN status = 'pending' THEN 1 END) as "pendingOrders"
      FROM "Products"
      WHERE DATE("sendDate") >= $1 AND DATE("sendDate") <= $2
    `, [startDate, endDate]);

    // Thống kê theo trạm
    const nhapHangByStation = await queryNhapHang(`
      SELECT
        station,
        COUNT(*) as "orderCount",
        COALESCE(SUM("totalAmount"), 0) as revenue
      FROM "Products"
      WHERE DATE("sendDate") >= $1 AND DATE("sendDate") <= $2
      GROUP BY station
      ORDER BY revenue DESC
      LIMIT 10
    `, [startDate, endDate]);

    // Thống kê theo ngày (cho biểu đồ)
    const nhapHangByDate = await queryNhapHang(`
      SELECT
        DATE("sendDate") as date,
        COUNT(*) as "orderCount",
        COALESCE(SUM("totalAmount"), 0) as revenue
      FROM "Products"
      WHERE DATE("sendDate") >= $1 AND DATE("sendDate") <= $2
      GROUP BY DATE("sendDate")
      ORDER BY date ASC
    `, [startDate, endDate]);

    // =====================
    // 2. THỐNG KÊ TỔNG HỢP (Hành khách)
    // =====================
    // Lấy tất cả ngày trong khoảng (format DD-MM-YYYY)
    const dates = [];
    let currentDate = new Date(startDate);
    const end = new Date(endDate);
    while (currentDate <= end) {
      dates.push(formatDateDDMMYYYY(currentDate));
      currentDate.setDate(currentDate.getDate() + 1);
    }

    let tongHopStats = { totalBookings: 0, totalPassengers: 0, totalRevenue: 0 };
    let tongHopByRoute = [];
    let tongHopByDate = [];

    if (dates.length > 0) {
      // Tổng quan
      const tongHopResult = await queryTongHop(`
        SELECT
          COUNT(*) as "totalBookings",
          COUNT(*) as "totalPassengers",
          COALESCE(SUM(amount), 0) as "totalRevenue",
          COALESCE(SUM(paid), 0) as "paidAmount"
        FROM "TH_Bookings"
        WHERE date = ANY($1::text[])
      `, [dates]);

      if (tongHopResult[0]) {
        tongHopStats = tongHopResult[0];
      }

      // Theo tuyến
      tongHopByRoute = await queryTongHop(`
        SELECT
          route,
          COUNT(*) as "bookingCount",
          COALESCE(SUM(amount), 0) as revenue
        FROM "TH_Bookings"
        WHERE date = ANY($1::text[])
        GROUP BY route
        ORDER BY revenue DESC
      `, [dates]);

      // Theo ngày
      tongHopByDate = await queryTongHop(`
        SELECT
          date,
          COUNT(*) as "bookingCount",
          COALESCE(SUM(amount), 0) as revenue
        FROM "TH_Bookings"
        WHERE date = ANY($1::text[])
        GROUP BY date
        ORDER BY date ASC
      `, [dates]);
    }

    // =====================
    // 3. TỔNG HỢP KẾT QUẢ
    // =====================
    const response = {
      success: true,
      period,
      dateRange: {
        from: startDate,
        to: endDate,
        label: period === 'day' ? startDate : `${startDate} - ${endDate}`
      },

      // Tổng quan
      summary: {
        totalRevenue: Number(nhapHangStats[0]?.totalRevenue || 0) + Number(tongHopStats.totalRevenue || 0),
        nhapHangRevenue: Number(nhapHangStats[0]?.totalRevenue || 0),
        tongHopRevenue: Number(tongHopStats.totalRevenue || 0),
        totalOrders: Number(nhapHangStats[0]?.totalOrders || 0),
        totalPassengers: Number(tongHopStats.totalPassengers || 0),
      },

      // Chi tiết Nhập Hàng
      nhapHang: {
        overview: nhapHangStats[0] || {},
        byStation: nhapHangByStation,
        byDate: nhapHangByDate
      },

      // Chi tiết Tổng Hợp
      tongHop: {
        overview: tongHopStats,
        byRoute: tongHopByRoute,
        byDate: tongHopByDate
      }
    };

    return NextResponse.json(response);

  } catch (error) {
    console.error('[Stats API] Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
