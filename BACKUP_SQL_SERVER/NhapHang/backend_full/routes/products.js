/**
 * Products Routes
 */

const express = require('express');
const router = express.Router();
const { query, queryOne, sql } = require('../config/database');
const { verifyToken } = require('../middleware/auth');
const tonghopService = require('../services/tonghop-service');

/**
 * Helper function để ghi log thay đổi
 */
async function logProductChange(productId, action, field, oldValue, newValue, changedBy, ipAddress) {
    try {
        await query(`
            INSERT INTO ProductLogs (productId, action, field, oldValue, newValue, changedBy, ipAddress)
            VALUES (@productId, @action, @field, @oldValue, @newValue, @changedBy, @ipAddress)
        `, {
            productId,
            action,
            field: field || null,
            oldValue: oldValue !== undefined ? String(oldValue) : null,
            newValue: newValue !== undefined ? String(newValue) : null,
            changedBy,
            ipAddress: ipAddress || null
        });
    } catch (error) {
        console.error('Error logging product change:', error.message);
    }
}

/**
 * Lấy IP từ request
 */
function getClientIP(req) {
    return req.headers['x-forwarded-for']?.split(',')[0] || req.socket?.remoteAddress || null;
}

/**
 * @route   GET /api/products
 * @desc    Get all products with filters
 * @access  Private
 */
router.get('/', verifyToken, async (req, res, next) => {
    try {
        const {
            station,
            senderStation,
            paymentStatus,
            status,
            dateFrom,
            dateTo,
            search
        } = req.query;

        let sqlQuery = 'SELECT * FROM Products WHERE 1=1';
        const params = {};

        // Apply filters
        if (station) {
            sqlQuery += ' AND station = @station';
            params.station = station;
        }

        if (senderStation) {
            sqlQuery += ' AND senderStation = @senderStation';
            params.senderStation = senderStation;
        }

        if (paymentStatus) {
            sqlQuery += ' AND paymentStatus = @paymentStatus';
            params.paymentStatus = paymentStatus;
        }

        if (status) {
            sqlQuery += ' AND status = @status';
            params.status = status;
        }

        if (dateFrom) {
            sqlQuery += ' AND sendDate >= @dateFrom';
            params.dateFrom = dateFrom;
        }

        if (dateTo) {
            sqlQuery += ' AND sendDate <= @dateTo';
            params.dateTo = dateTo;
        }

        if (search) {
            sqlQuery += ' AND (receiverName LIKE @search OR senderName LIKE @search OR receiverPhone LIKE @search OR senderPhone LIKE @search OR id LIKE @search)';
            params.search = `%${search}%`;
        }

        sqlQuery += ' ORDER BY sendDate DESC';

        const products = await query(sqlQuery, params);

        res.json({
            success: true,
            count: products.length,
            products
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @route   GET /api/products/all-logs
 * @desc    Get all edit history logs (admin only)
 * @access  Private
 */
router.get('/all-logs', verifyToken, async (req, res, next) => {
    try {
        const {
            dateFrom, dateTo, action, changedBy, limit = 100,
            productId, senderName, receiverName, phone, senderStation, station, search
        } = req.query;

        // Join với bảng Products để lấy thêm thông tin đơn hàng
        let sqlQuery = `
            SELECT TOP (@limit)
                l.logId, l.productId, l.action, l.field, l.oldValue, l.newValue,
                l.changedBy, l.changedAt, l.ipAddress,
                p.senderName, p.senderPhone, p.senderStation,
                p.receiverName, p.receiverPhone, p.station,
                p.productType, p.quantity, p.totalAmount, p.vehicle
            FROM ProductLogs l
            LEFT JOIN Products p ON l.productId = p.id
            WHERE 1=1
        `;
        const params = { limit: parseInt(limit) };

        if (dateFrom) {
            sqlQuery += ' AND l.changedAt >= @dateFrom';
            params.dateFrom = dateFrom;
        }

        if (dateTo) {
            sqlQuery += ' AND l.changedAt <= @dateTo';
            params.dateTo = dateTo;
        }

        if (action) {
            sqlQuery += ' AND l.action = @action';
            params.action = action;
        }

        if (changedBy) {
            sqlQuery += ' AND l.changedBy LIKE @changedBy';
            params.changedBy = `%${changedBy}%`;
        }

        // Tìm kiếm theo mã đơn hàng
        if (productId) {
            sqlQuery += ' AND l.productId LIKE @productId';
            params.productId = `%${productId}%`;
        }

        // Tìm kiếm theo tên người gửi
        if (senderName) {
            sqlQuery += ' AND p.senderName LIKE @senderName';
            params.senderName = `%${senderName}%`;
        }

        // Tìm kiếm theo tên người nhận
        if (receiverName) {
            sqlQuery += ' AND p.receiverName LIKE @receiverName';
            params.receiverName = `%${receiverName}%`;
        }

        // Tìm kiếm theo số điện thoại (cả gửi và nhận)
        if (phone) {
            sqlQuery += ' AND (p.senderPhone LIKE @phone OR p.receiverPhone LIKE @phone)';
            params.phone = `%${phone}%`;
        }

        // Tìm kiếm theo trạm gửi
        if (senderStation) {
            sqlQuery += ' AND p.senderStation = @senderStation';
            params.senderStation = senderStation;
        }

        // Tìm kiếm theo trạm nhận
        if (station) {
            sqlQuery += ' AND p.station = @station';
            params.station = station;
        }

        // Tìm kiếm tổng hợp (mã, tên, điện thoại)
        if (search) {
            sqlQuery += ' AND (l.productId LIKE @search OR p.senderName LIKE @search OR p.receiverName LIKE @search OR p.senderPhone LIKE @search OR p.receiverPhone LIKE @search)';
            params.search = `%${search}%`;
        }

        sqlQuery += ' ORDER BY l.changedAt DESC';

        const logs = await query(sqlQuery, params);

        res.json({
            success: true,
            count: logs.length,
            logs
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @route   GET /api/products/:id
 * @desc    Get product by ID
 * @access  Private
 */
router.get('/:id', verifyToken, async (req, res, next) => {
    try {
        const product = await queryOne(
            'SELECT * FROM Products WHERE id = @id',
            { id: req.params.id }
        );

        if (!product) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy sản phẩm!'
            });
        }

        res.json({
            success: true,
            product
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @route   POST /api/products
 * @desc    Create new product
 * @access  Private
 */
router.post('/', verifyToken, async (req, res, next) => {
    try {
        let {
            id,
            senderName,
            senderPhone,
            senderStation,
            receiverName,
            receiverPhone,
            station,
            productType,
            quantity,
            vehicle,
            insurance,
            totalAmount,
            paymentStatus,
            notes
        } = req.body;

        // Validate required fields (senderName và senderPhone là optional)
        if (!receiverName || !receiverPhone || !station || !productType) {
            return res.status(400).json({
                success: false,
                message: 'Vui lòng nhập đầy đủ thông tin bắt buộc: Người nhận, Điện thoại nhận, Trạm đến, Loại hàng!'
            });
        }

        // Auto-generate ID với cơ chế chống trùng khi nhiều người nhập cùng lúc
        const MAX_RETRY = 5;
        let retryCount = 0;
        let insertSuccess = false;
        let generatedId = id;

        while (!insertSuccess && retryCount < MAX_RETRY) {
            try {
                // Nếu không có ID được cung cấp, tự động tạo
                if (!id || retryCount > 0) {
                    // Sử dụng TRẠM ĐẾN (station) để tạo mã, không phải trạm gửi
                    const destinationStation = station;
                    const stationCode = destinationStation.split(' - ')[0];

                    const now = new Date();
                    const year = now.getFullYear().toString().slice(-2);
                    const month = String(now.getMonth() + 1).padStart(2, '0');
                    const day = String(now.getDate()).padStart(2, '0');
                    const dateKey = `${year}${month}${day}`;
                    const stationCodePadded = stationCode.padStart(2, '0');
                    const idPrefix = `${dateKey}.${stationCodePadded}`;

                    // Tìm số thứ tự cao nhất cho trạm này trong ngày
                    // Ví dụ: 250103.011, 250103.012 -> lấy MAX là 2, +1 = 3
                    const maxResult = await queryOne(`
                        SELECT MAX(CAST(SUBSTRING(id, LEN(@prefix) + 1, 10) AS INT)) as maxCounter
                        FROM Products
                        WHERE id LIKE @prefix + '%'
                        AND LEN(id) > LEN(@prefix)
                    `, {
                        prefix: idPrefix
                    });

                    const nextCounter = (maxResult?.maxCounter || 0) + 1;
                    generatedId = `${idPrefix}${nextCounter}`;

                    console.log(`[ID Generation] Prefix: ${idPrefix}, MaxCounter: ${maxResult?.maxCounter || 0}, NextID: ${generatedId}, Retry: ${retryCount}`);
                }

                // Thử insert - nếu trùng ID sẽ throw error do UNIQUE constraint
                await query(`
                    INSERT INTO Products (
                        id, senderName, senderPhone, senderStation,
                        receiverName, receiverPhone, station,
                        productType, quantity, vehicle, insurance, totalAmount,
                        paymentStatus, employee, createdBy, sendDate, status, notes
                    ) VALUES (
                        @id, @senderName, @senderPhone, @senderStation,
                        @receiverName, @receiverPhone, @station,
                        @productType, @quantity, @vehicle, @insurance, @totalAmount,
                        @paymentStatus, @employee, @createdBy, @sendDate, @status, @notes
                    )
                `, {
                    id: generatedId,
                    senderName: senderName || '',
                    senderPhone: senderPhone || '',
                    senderStation: senderStation || req.user.station,
                    receiverName,
                    receiverPhone,
                    station,
                    productType,
                    quantity: quantity || null,
                    vehicle: vehicle || null,
                    insurance: insurance || 0,
                    totalAmount: totalAmount || 0,
                    paymentStatus: paymentStatus || 'unpaid',
                    employee: req.user.fullName,
                    createdBy: req.user.fullName,
                    sendDate: new Date(),
                    status: 'pending',
                    notes: notes || null
                });

                insertSuccess = true;
                id = generatedId;

            } catch (insertError) {
                // Kiểm tra nếu lỗi là do trùng ID (duplicate key)
                if (insertError.message && (
                    insertError.message.includes('duplicate') ||
                    insertError.message.includes('UNIQUE') ||
                    insertError.message.includes('PRIMARY KEY') ||
                    insertError.number === 2627 || // SQL Server duplicate key error
                    insertError.number === 2601    // SQL Server unique index error
                )) {
                    retryCount++;
                    console.log(`[ID Generation] Duplicate detected for ${generatedId}, retrying... (${retryCount}/${MAX_RETRY})`);

                    if (retryCount >= MAX_RETRY) {
                        return res.status(500).json({
                            success: false,
                            message: 'Không thể tạo mã đơn hàng do xung đột. Vui lòng thử lại.'
                        });
                    }
                    // Đợi ngẫu nhiên 50-150ms trước khi retry để tránh race condition
                    await new Promise(resolve => setTimeout(resolve, 50 + Math.random() * 100));
                } else {
                    // Lỗi khác, throw lại
                    throw insertError;
                }
            }
        }

        // Get created product
        const product = await queryOne('SELECT * FROM Products WHERE id = @id', { id });

        // Ghi log tạo mới
        await logProductChange(id, 'create', null, null, null, req.user.fullName, getClientIP(req));

        // TongHop Integration: Auto-create booking for "Dọc đường" products
        let warning = null;
        if (tonghopService.isEnabled() && tonghopService.shouldCreateBooking(product)) {
            try {
                const booking = await tonghopService.createBookingForProduct(product);
                console.log(`✅ [TongHop] Created booking ${booking.id} for product ${product.id}`);
            } catch (bookingError) {
                // Product creation still succeeds even if booking fails
                console.error(`❌ [TongHop] Booking failed for product ${product.id}:`, bookingError.message);
                warning = 'Sản phẩm đã tạo thành công nhưng không thể tự động đặt vé xe. Vui lòng tạo booking thủ công trong hệ thống TongHop.';
            }
        }

        res.status(201).json({
            success: true,
            message: 'Tạo đơn hàng thành công!',
            product,
            ...(warning && { warning })
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @route   PUT /api/products/:id
 * @desc    Update product
 * @access  Private
 */
router.put('/:id', verifyToken, async (req, res, next) => {
    try {
        const { id } = req.params;
        const updates = req.body;

        // Check if product exists
        const existing = await queryOne('SELECT * FROM Products WHERE id = @id', { id });
        if (!existing) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy sản phẩm!'
            });
        }

        // Kiểm tra giới hạn 1 phút sửa giá - CHỈ ÁP DỤNG BÊN NHẬP HÀNG
        // Bên giao hàng (trạm nhận) được phép sửa giá bất cứ lúc nào
        // Mục đích: Ngăn nhân viên nhập hàng tạo đơn với giá sai để ăn chặn
        const userStation = req.user.station;
        const senderStation = existing.senderStation; // Trạm tạo đơn (nhập hàng)
        const destinationStation = existing.station;   // Trạm nhận (giao hàng)

        // Chỉ áp dụng giới hạn nếu user đang ở TRẠM GỬI (nơi tạo đơn - trang nhập hàng)
        const isAtSenderStation = userStation === senderStation;

        if (updates.totalAmount !== undefined && req.user.role !== 'admin' && isAtSenderStation) {
            const existingAmount = existing.totalAmount || 0;
            const newAmount = updates.totalAmount;

            // Chỉ chặn nếu: đã có giá cũ > 0 VÀ đang cố thay đổi giá
            if (existingAmount > 0 && newAmount !== existingAmount) {
                const createdTime = new Date(existing.sendDate);
                const now = new Date();
                const diffMinutes = (now - createdTime) / (1000 * 60);

                console.log(`[DEBUG] Product ${id}: existingAmount=${existingAmount}, newAmount=${newAmount}, diffMinutes=${diffMinutes.toFixed(2)}, userStation=${userStation}`);

                // Nếu quá 1 phút từ lúc tạo đơn, không cho sửa giá
                if (diffMinutes > 1) {
                    console.log(`[DEBUG] BLOCKING price edit - time expired (sender station restriction)`);
                    return res.status(403).json({
                        success: false,
                        message: 'Đã quá thời gian cho phép sửa giá (1 phút kể từ khi tạo đơn). Vui lòng liên hệ quản trị viên.',
                        code: 'EDIT_TIME_EXPIRED'
                    });
                }
            }
        }
        // Bên giao hàng (trạm nhận) không bị giới hạn thời gian sửa giá

        // Build update query
        const allowedFields = [
            'senderName', 'senderPhone', 'senderStation',
            'receiverName', 'receiverPhone', 'station',
            'productType', 'quantity', 'vehicle', 'insurance', 'totalAmount',
            'paymentStatus', 'status', 'notes', 'deliveryStatus'
        ];

        const updateFields = [];
        const params = { id };

        allowedFields.forEach(field => {
            if (updates[field] !== undefined) {
                updateFields.push(`${field} = @${field}`);
                params[field] = updates[field];
            }
        });

        // Tự động cập nhật paymentStatus khi thay đổi totalAmount
        // >= 10000: paid, < 10000: unpaid
        if (updates.totalAmount !== undefined && updates.paymentStatus === undefined) {
            const newAmount = parseFloat(updates.totalAmount) || 0;
            const autoPaymentStatus = newAmount >= 10000 ? 'paid' : 'unpaid';

            // Chỉ cập nhật nếu paymentStatus thay đổi
            if (existing.paymentStatus !== autoPaymentStatus) {
                updateFields.push('paymentStatus = @autoPaymentStatus');
                params.autoPaymentStatus = autoPaymentStatus;
                // Thêm vào updates để ghi log
                updates.paymentStatus = autoPaymentStatus;
            }
        }

        // Nếu chuyển sang trạng thái 'delivered', lưu thời gian giao hàng
        if (updates.deliveryStatus === 'delivered' && existing.deliveryStatus !== 'delivered') {
            updateFields.push('deliveredAt = GETDATE()');
        }

        if (updateFields.length === 0) {
            return res.status(400).json({
                success: false,
                message: 'Không có dữ liệu để cập nhật!'
            });
        }

        // Add updatedAt
        updateFields.push('updatedAt = GETDATE()');

        const sqlQuery = `UPDATE Products SET ${updateFields.join(', ')} WHERE id = @id`;
        await query(sqlQuery, params);

        // Get updated product
        const product = await queryOne('SELECT * FROM Products WHERE id = @id', { id });

        // Ghi log tất cả thay đổi trong 1 record duy nhất
        const clientIP = getClientIP(req);
        const changes = [];
        for (const field of allowedFields) {
            if (updates[field] !== undefined && existing[field] !== updates[field]) {
                changes.push({
                    field,
                    oldValue: existing[field],
                    newValue: updates[field]
                });
            }
        }

        // Chỉ ghi log nếu có thay đổi
        if (changes.length > 0) {
            await logProductChange(
                id,
                'update',
                changes.length === 1 ? changes[0].field : `${changes.length} fields`,
                JSON.stringify(changes.map(c => ({ [c.field]: c.oldValue }))),
                JSON.stringify(changes.map(c => ({ [c.field]: c.newValue }))),
                req.user.fullName,
                clientIP
            );
        }

        res.json({
            success: true,
            message: 'Cập nhật đơn hàng thành công!',
            product
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @route   DELETE /api/products/:id
 * @desc    Delete product
 * @access  Private
 */
router.delete('/:id', verifyToken, async (req, res, next) => {
    try {
        const { id } = req.params;

        // Check if product exists
        const existing = await queryOne('SELECT * FROM Products WHERE id = @id', { id });
        if (!existing) {
            return res.status(404).json({
                success: false,
                message: 'Không tìm thấy sản phẩm!'
            });
        }

        // Ghi log xóa (lưu thông tin sản phẩm trước khi xóa)
        await logProductChange(
            id,
            'delete',
            'product_info',
            JSON.stringify({
                receiverName: existing.receiverName,
                receiverPhone: existing.receiverPhone,
                totalAmount: existing.totalAmount,
                station: existing.station
            }),
            null,
            req.user.fullName,
            getClientIP(req)
        );

        // Delete product
        await query('DELETE FROM Products WHERE id = @id', { id });

        res.json({
            success: true,
            message: 'Xóa đơn hàng thành công!'
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @route   GET /api/products/stats/summary
 * @desc    Get products statistics
 * @access  Private
 */
router.get('/stats/summary', verifyToken, async (req, res, next) => {
    try {
        const stats = await query(`
            SELECT
                COUNT(*) as totalProducts,
                SUM(totalAmount) as totalRevenue,
                SUM(CASE WHEN paymentStatus = 'paid' THEN 1 ELSE 0 END) as paidCount,
                SUM(CASE WHEN paymentStatus = 'unpaid' THEN 1 ELSE 0 END) as unpaidCount,
                SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pendingCount,
                SUM(CASE WHEN status = 'delivered' THEN 1 ELSE 0 END) as deliveredCount
            FROM Products
        `);

        res.json({
            success: true,
            stats: stats[0]
        });
    } catch (error) {
        next(error);
    }
});

/**
 * @route   GET /api/products/:id/logs
 * @desc    Get edit history logs for a product
 * @access  Private
 */
router.get('/:id/logs', verifyToken, async (req, res, next) => {
    try {
        const { id } = req.params;

        const logs = await query(`
            SELECT logId, productId, action, field, oldValue, newValue, changedBy, changedAt, ipAddress
            FROM ProductLogs
            WHERE productId = @id
            ORDER BY changedAt DESC
        `, { id });

        res.json({
            success: true,
            count: logs.length,
            logs
        });
    } catch (error) {
        next(error);
    }
});

module.exports = router;
