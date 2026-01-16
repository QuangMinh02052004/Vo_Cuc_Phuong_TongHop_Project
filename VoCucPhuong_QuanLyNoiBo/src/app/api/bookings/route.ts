import { NextRequest, NextResponse } from 'next/server';
import { queryWithValues } from '@/lib/db';

// GET - Lấy danh sách booking
export async function GET(request: NextRequest) {
    try {
        const { searchParams } = new URL(request.url);
        const timeSlotId = searchParams.get('timeSlotId');
        const date = searchParams.get('date');

        let query = `
            SELECT b.*, t.time, t.date, t.route
            FROM th_bookings b
            LEFT JOIN th_timeslots t ON b.time_slot_id = t.id
            WHERE 1=1
        `;
        const params: any[] = [];
        let paramIndex = 1;

        if (timeSlotId) {
            query += ` AND b.time_slot_id = $${paramIndex++}`;
            params.push(timeSlotId);
        }

        if (date) {
            query += ` AND t.date = $${paramIndex++}`;
            params.push(date);
        }

        query += ' ORDER BY b.created_at DESC';

        const bookings = await queryWithValues(query, params);

        return NextResponse.json({ success: true, bookings });
    } catch (error) {
        console.error('Error fetching bookings:', error);
        return NextResponse.json(
            { success: false, error: 'Failed to fetch bookings' },
            { status: 500 }
        );
    }
}

// POST - Tạo booking mới
export async function POST(request: NextRequest) {
    try {
        const body = await request.json();
        const {
            timeSlotId,
            customerName,
            customerPhone,
            pickupType,
            pickupAddress,
            dropoffType,
            dropoffAddress,
            seatNumber,
            amount,
            paymentStatus,
            route,
            notes,
        } = body;

        // Insert booking
        await queryWithValues(
            `INSERT INTO th_bookings (
                time_slot_id, customer_name, customer_phone,
                pickup_type, pickup_address, dropoff_type, dropoff_address,
                seat_number, amount, payment_status, route, notes, source
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)`,
            [
                timeSlotId, customerName, customerPhone,
                pickupType, pickupAddress || '', dropoffType, dropoffAddress || '',
                seatNumber || '', amount || 0, paymentStatus || 'unpaid',
                route, notes || '', 'TONGHOP'
            ]
        );

        // Upsert customer info
        await queryWithValues(
            `INSERT INTO th_customers (phone, full_name, pickup_type, pickup_location, dropoff_type, dropoff_location, total_bookings, last_booking_date)
             VALUES ($1, $2, $3, $4, $5, $6, 1, NOW())
             ON CONFLICT (phone)
             DO UPDATE SET
                full_name = EXCLUDED.full_name,
                pickup_type = EXCLUDED.pickup_type,
                pickup_location = EXCLUDED.pickup_location,
                dropoff_type = EXCLUDED.dropoff_type,
                dropoff_location = EXCLUDED.dropoff_location,
                total_bookings = th_customers.total_bookings + 1,
                last_booking_date = NOW(),
                updated_at = NOW()`,
            [customerPhone, customerName, pickupType, pickupAddress || '', dropoffType, dropoffAddress || '']
        );

        return NextResponse.json({
            success: true,
            message: 'Đặt vé thành công'
        });
    } catch (error) {
        console.error('Error creating booking:', error);
        return NextResponse.json(
            { success: false, error: 'Failed to create booking' },
            { status: 500 }
        );
    }
}
