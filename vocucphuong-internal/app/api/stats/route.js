import { queryNhapHang, queryTongHop, queryDatVe } from '../../../lib/database';
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

// Helper: Lấy khoảng thời gian kỳ TRƯỚC để so sánh
function getPreviousDateRange(period, baseDate) {
  const date = new Date(baseDate);

  switch (period) {
    case 'week':
      // Tuần trước
      date.setDate(date.getDate() - 7);
      break;
    case 'month':
      // Tháng trước
      date.setMonth(date.getMonth() - 1);
      break;
    case 'day':
    default:
      // Hôm qua
      date.setDate(date.getDate() - 1);
      break;
  }

  return getDateRange(period, date.toISOString().split('T')[0]);
}

// Helper: Tính phần trăm thay đổi
function calcChange(current, previous) {
  if (!previous || previous === 0) {
    return current > 0 ? 100 : 0;
  }
  return Math.round(((current - previous) / previous) * 100);
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
    const { startDate: prevStartDate, endDate: prevEndDate } = getPreviousDateRange(period, dateParam);

    // =====================
    // 1. THỐNG KÊ NHẬP HÀNG (KỲ HIỆN TẠI)
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
    // 1b. NHẬP HÀNG KỲ TRƯỚC (để so sánh)
    // =====================
    const nhapHangPrevStats = await queryNhapHang(`
      SELECT
        COALESCE(SUM("totalAmount"), 0) as "totalRevenue",
        COUNT(*) as "totalOrders"
      FROM "Products"
      WHERE DATE("sendDate") >= $1 AND DATE("sendDate") <= $2
    `, [prevStartDate, prevEndDate]);

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
    // 2b. TỔNG HỢP KỲ TRƯỚC (để so sánh)
    // =====================
    let tongHopPrevStats = { totalRevenue: 0, totalPassengers: 0 };
    const prevDates = [];
    let prevCurrentDate = new Date(prevStartDate);
    const prevEnd = new Date(prevEndDate);
    while (prevCurrentDate <= prevEnd) {
      prevDates.push(formatDateDDMMYYYY(prevCurrentDate));
      prevCurrentDate.setDate(prevCurrentDate.getDate() + 1);
    }

    if (prevDates.length > 0) {
      const tongHopPrevResult = await queryTongHop(`
        SELECT
          COUNT(*) as "totalPassengers",
          COALESCE(SUM(amount), 0) as "totalRevenue"
        FROM "TH_Bookings"
        WHERE date = ANY($1::text[])
      `, [prevDates]);

      if (tongHopPrevResult[0]) {
        tongHopPrevStats = tongHopPrevResult[0];
      }
    }

    // =====================
    // 3. THỐNG KÊ ĐẶT VÉ ONLINE (KỲ HIỆN TẠI)
    // =====================
    let datVeStats = { totalBookings: 0, totalRevenue: 0, paidAmount: 0, confirmedBookings: 0, pendingBookings: 0 };
    let datVeByRoute = [];
    let datVeByDate = [];

    try {
      // Tổng quan DatVe
      const datVeResult = await queryDatVe(`
        SELECT
          COUNT(*) as "totalBookings",
          COALESCE(SUM(total_price), 0) as "totalRevenue",
          COUNT(CASE WHEN status = 'confirmed' THEN 1 END) as "confirmedBookings",
          COUNT(CASE WHEN status = 'pending' THEN 1 END) as "pendingBookings"
        FROM bookings
        WHERE DATE(date) >= $1 AND DATE(date) <= $2
      `, [startDate, endDate]);

      if (datVeResult[0]) {
        datVeStats = datVeResult[0];
      }

      // Tổng tiền đã thanh toán từ payments
      const datVePaidResult = await queryDatVe(`
        SELECT COALESCE(SUM(p.amount), 0) as "paidAmount"
        FROM payments p
        JOIN bookings b ON p.booking_id = b.id
        WHERE DATE(b.date) >= $1 AND DATE(b.date) <= $2
          AND p.status = 'completed'
      `, [startDate, endDate]);

      if (datVePaidResult[0]) {
        datVeStats.paidAmount = datVePaidResult[0].paidAmount;
      }

      // Theo tuyến đường
      datVeByRoute = await queryDatVe(`
        SELECT
          CONCAT(r.origin, ' → ', r.destination) as route,
          COUNT(*) as "bookingCount",
          COALESCE(SUM(b.total_price), 0) as revenue
        FROM bookings b
        LEFT JOIN routes r ON b.route_id = r.id
        WHERE DATE(b.date) >= $1 AND DATE(b.date) <= $2
        GROUP BY r.origin, r.destination
        ORDER BY revenue DESC
      `, [startDate, endDate]);

      // Theo ngày
      datVeByDate = await queryDatVe(`
        SELECT
          DATE(date) as date,
          COUNT(*) as "bookingCount",
          COALESCE(SUM(total_price), 0) as revenue
        FROM bookings
        WHERE DATE(date) >= $1 AND DATE(date) <= $2
        GROUP BY DATE(date)
        ORDER BY date ASC
      `, [startDate, endDate]);

    } catch (datVeError) {
      console.error('[Stats API] DatVe query error:', datVeError.message);
      // Tiếp tục với dữ liệu mặc định nếu DatVe lỗi
    }

    // =====================
    // 3b. ĐẶT VÉ KỲ TRƯỚC (để so sánh)
    // =====================
    let datVePrevStats = { totalRevenue: 0, totalBookings: 0 };

    try {
      const datVePrevResult = await queryDatVe(`
        SELECT
          COUNT(*) as "totalBookings",
          COALESCE(SUM(total_price), 0) as "totalRevenue"
        FROM bookings
        WHERE DATE(date) >= $1 AND DATE(date) <= $2
      `, [prevStartDate, prevEndDate]);

      if (datVePrevResult[0]) {
        datVePrevStats = datVePrevResult[0];
      }
    } catch (datVeError) {
      console.error('[Stats API] DatVe prev query error:', datVeError.message);
    }

    // =====================
    // 4. TỔNG HỢP KẾT QUẢ
    // =====================
    const currentNhapHangRevenue = Number(nhapHangStats[0]?.totalRevenue || 0);
    const currentTongHopRevenue = Number(tongHopStats.totalRevenue || 0);
    const currentDatVeRevenue = Number(datVeStats.totalRevenue || 0);
    const currentTotalRevenue = currentNhapHangRevenue + currentTongHopRevenue + currentDatVeRevenue;

    const prevNhapHangRevenue = Number(nhapHangPrevStats[0]?.totalRevenue || 0);
    const prevTongHopRevenue = Number(tongHopPrevStats.totalRevenue || 0);
    const prevDatVeRevenue = Number(datVePrevStats.totalRevenue || 0);
    const prevTotalRevenue = prevNhapHangRevenue + prevTongHopRevenue + prevDatVeRevenue;

    const currentOrders = Number(nhapHangStats[0]?.totalOrders || 0);
    const prevOrders = Number(nhapHangPrevStats[0]?.totalOrders || 0);
    const currentPassengers = Number(tongHopStats.totalPassengers || 0);
    const prevPassengers = Number(tongHopPrevStats.totalPassengers || 0);
    const currentOnlineBookings = Number(datVeStats.totalBookings || 0);
    const prevOnlineBookings = Number(datVePrevStats.totalBookings || 0);

    const periodLabel = period === 'day' ? 'hôm qua' : period === 'week' ? 'tuần trước' : 'tháng trước';

    const response = {
      success: true,
      period,
      dateRange: {
        from: startDate,
        to: endDate,
        label: period === 'day' ? startDate : `${startDate} - ${endDate}`
      },
      prevDateRange: {
        from: prevStartDate,
        to: prevEndDate,
        label: periodLabel
      },

      // Tổng quan + So sánh
      summary: {
        totalRevenue: currentTotalRevenue,
        totalRevenueChange: calcChange(currentTotalRevenue, prevTotalRevenue),
        nhapHangRevenue: currentNhapHangRevenue,
        nhapHangRevenueChange: calcChange(currentNhapHangRevenue, prevNhapHangRevenue),
        tongHopRevenue: currentTongHopRevenue,
        tongHopRevenueChange: calcChange(currentTongHopRevenue, prevTongHopRevenue),
        datVeRevenue: currentDatVeRevenue,
        datVeRevenueChange: calcChange(currentDatVeRevenue, prevDatVeRevenue),
        totalOrders: currentOrders,
        totalOrdersChange: calcChange(currentOrders, prevOrders),
        totalPassengers: currentPassengers,
        totalPassengersChange: calcChange(currentPassengers, prevPassengers),
        totalOnlineBookings: currentOnlineBookings,
        totalOnlineBookingsChange: calcChange(currentOnlineBookings, prevOnlineBookings),
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
      },

      // Chi tiết Đặt Vé Online
      datVe: {
        overview: {
          totalBookings: Number(datVeStats.totalBookings || 0),
          totalRevenue: currentDatVeRevenue,
          paidAmount: Number(datVeStats.paidAmount || 0),
          confirmedBookings: Number(datVeStats.confirmedBookings || 0),
          pendingBookings: Number(datVeStats.pendingBookings || 0)
        },
        byRoute: datVeByRoute,
        byDate: datVeByDate
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
