const express = require('express');
const router = express.Router();
const { getConnection } = require('../config/database');

// Thời gian khóa ghế (10 phút = 600000ms)
const LOCK_DURATION_MINUTES = 10;

// GET - Lấy tất cả locks hiện tại (chưa hết hạn)
router.get('/', async (req, res) => {
  try {
    const pool = await getConnection();

    // Xóa các lock hết hạn trước
    await pool.request().query(`
      DELETE FROM SeatLocks WHERE expiresAt < GETDATE()
    `);

    // Lấy các lock còn hiệu lực
    const result = await pool.request().query(`
      SELECT * FROM SeatLocks WHERE expiresAt > GETDATE()
      ORDER BY lockedAt DESC
    `);

    res.json(result.recordset);
  } catch (err) {
    console.error('Lỗi lấy seat locks:', err);
    res.status(500).json({ error: 'Lỗi server', message: err.message });
  }
});

// GET - Lấy locks theo ngày và tuyến
router.get('/by-date-route', async (req, res) => {
  try {
    const { date, route } = req.query;

    if (!date || !route) {
      return res.status(400).json({ error: 'Thiếu thông tin date hoặc route' });
    }

    const pool = await getConnection();

    // Xóa các lock hết hạn trước
    await pool.request().query(`
      DELETE FROM SeatLocks WHERE expiresAt < GETDATE()
    `);

    // Lấy các lock còn hiệu lực cho ngày và tuyến cụ thể
    const result = await pool.request()
      .input('date', date)
      .input('route', route)
      .query(`
        SELECT * FROM SeatLocks
        WHERE date = @date AND route = @route AND expiresAt > GETDATE()
      `);

    res.json(result.recordset);
  } catch (err) {
    console.error('Lỗi lấy seat locks:', err);
    res.status(500).json({ error: 'Lỗi server', message: err.message });
  }
});

// DEV ONLY: Xóa tất cả locks (dùng để test) - PHẢI đặt TRƯỚC route /:id
router.delete('/clear-all', async (req, res) => {
  try {
    const pool = await getConnection();
    const result = await pool.request().query('DELETE FROM SeatLocks');
    res.json({
      success: true,
      message: `Đã xóa ${result.rowsAffected[0]} locks`
    });
  } catch (err) {
    console.error('Lỗi xóa tất cả locks:', err);
    res.status(500).json({ error: 'Lỗi server', message: err.message });
  }
});

// DELETE - Xóa lock theo thông tin ghế (dùng khi đóng form hoặc booking thành công)
// PHẢI đặt TRƯỚC route /:id
router.delete('/by-seat', async (req, res) => {
  try {
    const { timeSlotId, seatNumber, date, route, lockedBy } = req.body;

    console.log('🔓 Yêu cầu xóa lock:', { timeSlotId, seatNumber, date, route, lockedBy });

    if (!timeSlotId || !seatNumber || !date || !route) {
      return res.status(400).json({ error: 'Thiếu thông tin bắt buộc' });
    }

    const pool = await getConnection();

    let query = `
      DELETE FROM SeatLocks
      WHERE timeSlotId = @timeSlotId
      AND seatNumber = @seatNumber
      AND date = @date
      AND route = @route
    `;

    // Nếu có lockedBy, chỉ xóa lock của người đó
    if (lockedBy) {
      query += ' AND lockedBy = @lockedBy';
    }

    const request = pool.request()
      .input('timeSlotId', timeSlotId)
      .input('seatNumber', seatNumber)
      .input('date', date)
      .input('route', route);

    if (lockedBy) {
      request.input('lockedBy', lockedBy);
    }

    const result = await request.query(query);

    console.log(`✅ Đã xóa ${result.rowsAffected[0]} lock cho ghế ${seatNumber}`);

    res.json({
      success: true,
      message: 'Đã xóa lock',
      deleted: result.rowsAffected[0]
    });
  } catch (err) {
    console.error('Lỗi xóa seat lock:', err);
    res.status(500).json({ error: 'Lỗi server', message: err.message });
  }
});

// POST - Tạo lock mới cho ghế
router.post('/', async (req, res) => {
  try {
    const { timeSlotId, seatNumber, lockedBy, lockedByUserId, date, route } = req.body;

    if (!timeSlotId || !seatNumber || !lockedBy || !date || !route) {
      return res.status(400).json({
        error: 'Thiếu thông tin bắt buộc',
        required: ['timeSlotId', 'seatNumber', 'lockedBy', 'date', 'route']
      });
    }

    const pool = await getConnection();

    // Xóa các lock hết hạn trước
    await pool.request().query(`
      DELETE FROM SeatLocks WHERE expiresAt < GETDATE()
    `);

    // Kiểm tra xem ghế đã bị khóa chưa
    const existingLock = await pool.request()
      .input('timeSlotId', timeSlotId)
      .input('seatNumber', seatNumber)
      .input('date', date)
      .input('route', route)
      .query(`
        SELECT * FROM SeatLocks
        WHERE timeSlotId = @timeSlotId
        AND seatNumber = @seatNumber
        AND date = @date
        AND route = @route
        AND expiresAt > GETDATE()
      `);

    if (existingLock.recordset.length > 0) {
      const lock = existingLock.recordset[0];
      // Nếu cùng người khóa, gia hạn lock
      if (lock.lockedBy === lockedBy) {
        const newExpiresAt = new Date(Date.now() + LOCK_DURATION_MINUTES * 60 * 1000);
        await pool.request()
          .input('id', lock.id)
          .input('expiresAt', newExpiresAt)
          .query(`
            UPDATE SeatLocks SET expiresAt = @expiresAt WHERE id = @id
          `);

        return res.json({
          success: true,
          message: 'Đã gia hạn lock',
          lock: { ...lock, expiresAt: newExpiresAt }
        });
      }

      // Ghế đã bị người khác khóa
      return res.status(409).json({
        error: 'Ghế đã bị khóa',
        lockedBy: lock.lockedBy,
        expiresAt: lock.expiresAt,
        message: `Ghế ${seatNumber} đang được ${lock.lockedBy} điền thông tin. Vui lòng chọn ghế khác.`
      });
    }

    // Tạo lock mới
    const expiresAt = new Date(Date.now() + LOCK_DURATION_MINUTES * 60 * 1000);

    const result = await pool.request()
      .input('timeSlotId', timeSlotId)
      .input('seatNumber', seatNumber)
      .input('lockedBy', lockedBy)
      .input('lockedByUserId', lockedByUserId || null)
      .input('expiresAt', expiresAt)
      .input('date', date)
      .input('route', route)
      .query(`
        INSERT INTO SeatLocks (timeSlotId, seatNumber, lockedBy, lockedByUserId, expiresAt, date, route)
        OUTPUT INSERTED.*
        VALUES (@timeSlotId, @seatNumber, @lockedBy, @lockedByUserId, @expiresAt, @date, @route)
      `);

    res.status(201).json({
      success: true,
      message: `Đã khóa ghế ${seatNumber} trong ${LOCK_DURATION_MINUTES} phút`,
      lock: result.recordset[0]
    });

  } catch (err) {
    console.error('Lỗi tạo seat lock:', err);
    res.status(500).json({ error: 'Lỗi server', message: err.message });
  }
});

// DELETE - Xóa lock (khi hủy hoặc hoàn tất booking)
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const pool = await getConnection();

    await pool.request()
      .input('id', id)
      .query('DELETE FROM SeatLocks WHERE id = @id');

    res.json({ success: true, message: 'Đã xóa lock' });
  } catch (err) {
    console.error('Lỗi xóa seat lock:', err);
    res.status(500).json({ error: 'Lỗi server', message: err.message });
  }
});

// POST - Xóa tất cả lock của một user (dùng khi user logout hoặc đóng tab)
router.post('/release-all', async (req, res) => {
  try {
    const { lockedBy } = req.body;

    if (!lockedBy) {
      return res.status(400).json({ error: 'Thiếu thông tin lockedBy' });
    }

    const pool = await getConnection();

    const result = await pool.request()
      .input('lockedBy', lockedBy)
      .query('DELETE FROM SeatLocks WHERE lockedBy = @lockedBy');

    res.json({
      success: true,
      message: `Đã xóa ${result.rowsAffected[0]} lock của ${lockedBy}`
    });
  } catch (err) {
    console.error('Lỗi xóa seat locks:', err);
    res.status(500).json({ error: 'Lỗi server', message: err.message });
  }
});

module.exports = router;
