import { NextRequest, NextResponse } from 'next/server';
import { queryWithValues } from '@/lib/db';

// GET - Lấy danh sách hàng hóa
export async function GET(request: NextRequest) {
    try {
        const { searchParams } = new URL(request.url);
        const date = searchParams.get('date');
        const status = searchParams.get('status');

        let query = 'SELECT * FROM nh_products WHERE 1=1';
        const params: any[] = [];
        let paramIndex = 1;

        if (date) {
            query += ` AND send_date = $${paramIndex++}`;
            params.push(date);
        }

        if (status && status !== 'all') {
            query += ` AND status = $${paramIndex++}`;
            params.push(status);
        }

        query += ' ORDER BY created_at DESC';

        const products = await queryWithValues(query, params);

        return NextResponse.json({ success: true, products });
    } catch (error) {
        console.error('Error fetching products:', error);
        return NextResponse.json(
            { success: false, error: 'Failed to fetch products' },
            { status: 500 }
        );
    }
}

// POST - Thêm hàng hóa mới
export async function POST(request: NextRequest) {
    try {
        const body = await request.json();
        const {
            senderName,
            senderPhone,
            senderStation,
            receiverName,
            receiverPhone,
            receiverStation,
            productType,
            quantity,
            vehicle,
            insurance,
            totalAmount,
            paymentStatus,
            employee,
            sendDate,
            notes,
        } = body;

        // Generate product ID
        const dateStr = new Date(sendDate).toLocaleDateString('vi-VN', {
            day: '2-digit',
            month: '2-digit',
            year: '2-digit'
        }).replace(/\//g, '');

        // Get station code
        const stationCode = senderStation.split(' ')[0] || '00';

        // Get next counter
        const counterKey = `${stationCode}_${dateStr}`;
        const counterResult = await queryWithValues<{ value: number }>(
            `INSERT INTO nh_counters (counter_key, value, station, date_key)
             VALUES ($1, 1, $2, $3)
             ON CONFLICT (counter_key)
             DO UPDATE SET value = nh_counters.value + 1, last_updated = NOW()
             RETURNING value`,
            [counterKey, senderStation, dateStr]
        );

        const counter = counterResult[0]?.value || 1;
        const productId = `${stationCode}-${dateStr}-${counter.toString().padStart(3, '0')}`;

        // Insert product
        await queryWithValues(
            `INSERT INTO nh_products (
                id, sender_name, sender_phone, sender_station,
                receiver_name, receiver_phone, receiver_station,
                product_type, quantity, vehicle, insurance,
                total_amount, payment_status, employee, send_date, notes, created_by
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)`,
            [
                productId, senderName, senderPhone, senderStation,
                receiverName, receiverPhone, receiverStation,
                productType, quantity || 1, vehicle, insurance || 0,
                totalAmount || 0, paymentStatus || 'unpaid', employee, sendDate, notes, 'admin'
            ]
        );

        return NextResponse.json({
            success: true,
            productId,
            message: 'Thêm hàng hóa thành công'
        });
    } catch (error) {
        console.error('Error creating product:', error);
        return NextResponse.json(
            { success: false, error: 'Failed to create product' },
            { status: 500 }
        );
    }
}
