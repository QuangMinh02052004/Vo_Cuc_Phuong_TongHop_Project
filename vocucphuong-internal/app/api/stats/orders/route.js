import { queryNhapHang, queryTongHop, queryDatVe } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: Chi tiết đơn hàng / booking
// ===========================================
// GET /api/stats/orders?type=nhaphang&date=YYYY-MM-DD&station=...
// GET /api/stats/orders?type=tonghop&date=DD-MM-YYYY&route=...

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const type = searchParams.get('type'); // 'nhaphang' or 'tonghop'
    const date = searchParams.get('date');
    const station = searchParams.get('station');
    const route = searchParams.get('route');
    const fromDate = searchParams.get('fromDate');
    const toDate = searchParams.get('toDate');

    if (type === 'nhaphang') {
      // Lấy chi tiết đơn Nhập Hàng
      let query = `
        SELECT
          id,
          "senderName", "senderPhone", "senderStation",
          "receiverName", "receiverPhone", station,
          "productType", quantity, "totalAmount",
          "paymentStatus", status, "deliveryStatus",
          "sendDate", notes, "createdAt"
        FROM "NH_Products"
        WHERE 1=1
      `;
      const params = [];
      let paramIndex = 1;

      // Filter by date range
      if (fromDate && toDate) {
        query += ` AND DATE("sendDate") >= $${paramIndex} AND DATE("sendDate") <= $${paramIndex + 1}`;
        params.push(fromDate, toDate);
        paramIndex += 2;
      } else if (date) {
        query += ` AND DATE("sendDate") = $${paramIndex}`;
        params.push(date);
        paramIndex++;
      }

      // Filter by station
      if (station) {
        query += ` AND station = $${paramIndex}`;
        params.push(station);
        paramIndex++;
      }

      query += ` ORDER BY "sendDate" DESC LIMIT 100`;

      const orders = await queryNhapHang(query, params);

      // Sanitize sendDate
      const sanitizedOrders = orders.map(order => {
        if (order.sendDate) {
          if (order.sendDate instanceof Date) {
            const d = order.sendDate;
            order.sendDate = `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, '0')}-${String(d.getUTCDate()).padStart(2, '0')}T${String(d.getUTCHours()).padStart(2, '0')}:${String(d.getUTCMinutes()).padStart(2, '0')}:${String(d.getUTCSeconds()).padStart(2, '0')}`;
          } else if (typeof order.sendDate === 'string') {
            order.sendDate = order.sendDate.replace('Z', '').replace(/[+-]\d{2}:\d{2}$/, '');
          }
        }
        return order;
      });

      return NextResponse.json({
        success: true,
        type: 'nhaphang',
        data: sanitizedOrders,
        count: sanitizedOrders.length
      });

    } else if (type === 'tonghop') {
      // Lấy chi tiết booking TongHop
      let query = `
        SELECT
          id, phone, name,
          "pickupMethod", "pickupAddress",
          "dropoffMethod", "dropoffAddress",
          note, "seatNumber",
          amount, paid,
          "timeSlot", date, route,
          "createdAt"
        FROM "TH_Bookings"
        WHERE 1=1
      `;
      const params = [];
      let paramIndex = 1;

      // Filter by date (format DD-MM-YYYY)
      if (date) {
        query += ` AND date = $${paramIndex}`;
        params.push(date);
        paramIndex++;
      }

      // Filter by date range (convert YYYY-MM-DD to DD-MM-YYYY array)
      if (fromDate && toDate) {
        const dates = [];
        let currentDate = new Date(fromDate);
        const endDate = new Date(toDate);
        while (currentDate <= endDate) {
          const day = String(currentDate.getDate()).padStart(2, '0');
          const month = String(currentDate.getMonth() + 1).padStart(2, '0');
          const year = currentDate.getFullYear();
          dates.push(`${day}-${month}-${year}`);
          currentDate.setDate(currentDate.getDate() + 1);
        }
        if (dates.length > 0) {
          query += ` AND date = ANY($${paramIndex}::text[])`;
          params.push(dates);
          paramIndex++;
        }
      }

      // Filter by route
      if (route) {
        query += ` AND route = $${paramIndex}`;
        params.push(route);
        paramIndex++;
      }

      query += ` ORDER BY date DESC, "timeSlot" DESC LIMIT 100`;

      const bookings = await queryTongHop(query, params);

      return NextResponse.json({
        success: true,
        type: 'tonghop',
        data: bookings,
        count: bookings.length
      });

    } else if (type === 'datve') {
      // Lấy chi tiết đặt vé online
      let query = `
        SELECT
          b.id,
          b.booking_code,
          b.customer_name,
          b.customer_phone,
          b.customer_email,
          b.date,
          b.departure_time,
          b.seats,
          b.total_price,
          b.status,
          b.created_at,
          CONCAT(r.origin, ' → ', r.destination) as route,
          COALESCE((
            SELECT SUM(p.amount)
            FROM payments p
            WHERE p.booking_id = b.id AND p.status = 'completed'
          ), 0) as paid_amount
        FROM bookings b
        LEFT JOIN routes r ON b.route_id = r.id
        WHERE 1=1
      `;
      const params = [];
      let paramIndex = 1;

      // Filter by date range
      if (fromDate && toDate) {
        query += ` AND DATE(b.date) >= $${paramIndex} AND DATE(b.date) <= $${paramIndex + 1}`;
        params.push(fromDate, toDate);
        paramIndex += 2;
      } else if (date) {
        query += ` AND DATE(b.date) = $${paramIndex}`;
        params.push(date);
        paramIndex++;
      }

      // Filter by route
      if (route) {
        query += ` AND CONCAT(r.origin, ' → ', r.destination) = $${paramIndex}`;
        params.push(route);
        paramIndex++;
      }

      query += ` ORDER BY b.date DESC, b.created_at DESC LIMIT 100`;

      const bookings = await queryDatVe(query, params);

      return NextResponse.json({
        success: true,
        type: 'datve',
        data: bookings,
        count: bookings.length
      });

    } else {
      return NextResponse.json({
        success: false,
        error: 'Invalid type. Use "nhaphang", "tonghop", or "datve"'
      }, { status: 400 });
    }

  } catch (error) {
    console.error('[Stats Orders] Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
