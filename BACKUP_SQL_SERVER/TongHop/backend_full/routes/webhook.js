const express = require('express');
const router = express.Router();
const { getConnection, sql } = require('../config/database');

// ===========================================
// WEBHOOK: NHẬN BOOKING TỪ HỆ THỐNG ĐẶT VÉ
// ===========================================
// POST /api/webhook/datve

router.post('/datve', async (req, res) => {
  try {
    console.log('📥 [Webhook] Nhận booking từ Đặt Vé:', req.body);

    const {
      bookingCode,
      customerName,
      customerPhone,
      date,
      departureTime,    // Khung giờ (ví dụ: "9:30")
      seats,
      totalPrice,
      route,            // Tuyến (ví dụ: "Sài Gòn → Long Khánh")
      notes,
      source = 'DATVE'
    } = req.body;

    // Validate
    if (!customerName || !customerPhone) {
      return res.status(400).json({
        success: false,
        error: 'Thiếu thông tin bắt buộc',
        details: 'Cần có customerName và customerPhone'
      });
    }

    const pool = await getConnection();

    // Convert date format: YYYY-MM-DD -> DD-MM-YYYY (format TongHop dùng)
    let formattedDate = date || '';
    if (date && date.includes('-') && date.split('-')[0].length === 4) {
      // Date is YYYY-MM-DD, convert to DD-MM-YYYY
      const [year, month, day] = date.split('-');
      formattedDate = `${day}-${month}-${year}`;
      console.log('📅 [Webhook] Converted date:', date, '->', formattedDate);
    }

    // Xác định tuyến từ route string
    let routeName = route || '';
    let pickupAddress = '';
    let dropoffAddress = '';

    // Parse route để xác định tuyến (điểm trả mặc định "Tại bến" cho tuyến cố định)
    if (route) {
      if (route.includes('Sài Gòn') && route.includes('Long Khánh')) {
        if (route.indexOf('Sài Gòn') < route.indexOf('Long Khánh')) {
          // Sài Gòn → Long Khánh
          routeName = 'Sài Gòn- Long Khánh';
        } else {
          // Long Khánh → Sài Gòn
          routeName = 'Long Khánh - Sài Gòn';
        }
        // Tuyến cố định: điểm trả tại bến
        pickupAddress = '';
        dropoffAddress = '';
      }
    }

    // Tìm TimeSlot phù hợp theo khung giờ và ngày
    let timeSlotId = null;
    if (departureTime && formattedDate) {
      console.log('🔍 [Webhook] Tìm TimeSlot với time:', departureTime, 'date:', formattedDate, 'route:', routeName);

      // Tìm TimeSlot khớp với time, date và route (nếu có)
      let timeSlotResult;

      if (routeName) {
        // Tìm theo time, date và route
        timeSlotResult = await pool.request()
          .input('time', sql.VarChar(10), departureTime)
          .input('date', sql.VarChar(20), formattedDate)
          .input('route', sql.NVarChar(100), routeName)
          .query(`
            SELECT TOP 1 id, route FROM TimeSlots
            WHERE time = @time AND date = @date AND route = @route
            ORDER BY id
          `);
      }

      // Nếu không tìm thấy với route, thử tìm chỉ theo time và date
      if (!timeSlotResult || timeSlotResult.recordset.length === 0) {
        timeSlotResult = await pool.request()
          .input('time', sql.VarChar(10), departureTime)
          .input('date', sql.VarChar(20), formattedDate)
          .query(`
            SELECT TOP 1 id, route FROM TimeSlots
            WHERE time = @time AND date = @date
            ORDER BY id
          `);
      }

      if (timeSlotResult.recordset.length > 0) {
        timeSlotId = timeSlotResult.recordset[0].id;
        console.log('✅ [Webhook] Tìm thấy TimeSlot:', timeSlotId, '| Route:', timeSlotResult.recordset[0].route);
      } else {
        console.log('⚠️ [Webhook] Không tìm thấy TimeSlot cho time:', departureTime, 'date:', formattedDate);
      }
    }

    // Insert booking vào database
    const result = await pool.request()
      .input('timeSlotId', sql.Int, timeSlotId)
      .input('phone', sql.VarChar(20), customerPhone || '')
      .input('name', sql.NVarChar(200), customerName || '')
      .input('gender', sql.VarChar(10), '')
      .input('nationality', sql.NVarChar(100), '')
      .input('pickupMethod', sql.NVarChar(50), '')
      .input('pickupAddress', sql.NVarChar(500), pickupAddress)
      .input('dropoffMethod', sql.NVarChar(50), '')
      .input('dropoffAddress', sql.NVarChar(500), dropoffAddress)
      .input('note', sql.NVarChar(1000), `${bookingCode || ''} - ${customerName} - ${seats || 1} ghế${notes ? ' | ' + notes : ''}`)
      .input('seatNumber', sql.Int, seats || 1)
      .input('amount', sql.Decimal(18, 2), totalPrice || 0)
      .input('paid', sql.Decimal(18, 2), 0)
      .input('timeSlot', sql.VarChar(10), departureTime || '')
      .input('date', sql.VarChar(20), formattedDate || '')
      .input('route', sql.NVarChar(100), routeName)
      .query(`
        INSERT INTO Bookings (
          timeSlotId, phone, name, gender, nationality, pickupMethod,
          pickupAddress, dropoffMethod, dropoffAddress, note, seatNumber, amount, paid,
          timeSlot, date, route
        )
        OUTPUT INSERTED.*
        VALUES (
          @timeSlotId, @phone, @name, @gender, @nationality, @pickupMethod,
          @pickupAddress, @dropoffMethod, @dropoffAddress, @note, @seatNumber, @amount, @paid,
          @timeSlot, @date, @route
        )
      `);

    const newBooking = result.recordset[0];
    console.log('✅ [Webhook] Đã tạo booking từ Đặt Vé:', newBooking.id);

    res.status(201).json({
      success: true,
      message: 'Đã nhận booking từ Đặt Vé',
      data: {
        id: newBooking.id,
        customerName: newBooking.name,
        customerPhone: newBooking.phone,
        timeSlot: newBooking.timeSlot,
        date: newBooking.date,
        route: newBooking.route,
        seatNumber: newBooking.seatNumber
      }
    });

  } catch (err) {
    console.error('[Webhook] Lỗi nhận booking từ Đặt Vé:', err);
    res.status(500).json({
      success: false,
      error: 'Lỗi server',
      message: err.message
    });
  }
});

// GET - Health check
router.get('/datve', (req, res) => {
  res.json({
    success: true,
    message: 'Webhook Đặt Vé endpoint is active',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;
