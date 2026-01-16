import { NextRequest, NextResponse } from 'next/server';
import { queryWithValues } from '@/lib/db';

// GET - Lấy danh sách khung giờ
export async function GET(request: NextRequest) {
    try {
        const { searchParams } = new URL(request.url);
        const date = searchParams.get('date');
        const route = searchParams.get('route');

        let query = `
            SELECT
                t.*,
                (SELECT COUNT(*) FROM th_bookings b WHERE b.time_slot_id = t.id) as booking_count,
                (SELECT COUNT(*) FROM th_freight f WHERE f.time_slot_id = t.id) as freight_count
            FROM th_timeslots t
            WHERE 1=1
        `;
        const params: any[] = [];
        let paramIndex = 1;

        if (date) {
            query += ` AND t.date = $${paramIndex++}`;
            params.push(date);
        }

        if (route && route !== 'all') {
            query += ` AND t.route = $${paramIndex++}`;
            params.push(route);
        }

        query += ' ORDER BY t.route, t.time';

        const timeSlots = await queryWithValues(query, params);

        return NextResponse.json({ success: true, timeSlots });
    } catch (error) {
        console.error('Error fetching timeslots:', error);
        return NextResponse.json(
            { success: false, error: 'Failed to fetch timeslots' },
            { status: 500 }
        );
    }
}
