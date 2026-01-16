import { NextResponse } from 'next/server';
import { queryWithValues } from '@/lib/db';

export async function GET() {
    try {
        const today = new Date().toISOString().split('T')[0];

        // Get today's products count
        const productsResult = await queryWithValues<{ count: string }>(
            `SELECT COUNT(*) as count FROM nh_products WHERE send_date = $1`,
            [today]
        );

        // Get today's bookings count
        const bookingsResult = await queryWithValues<{ count: string }>(
            `SELECT COUNT(*) as count FROM th_bookings WHERE DATE(created_at) = $1`,
            [today]
        );

        // Get today's revenue
        const revenueResult = await queryWithValues<{ total: string }>(
            `SELECT COALESCE(SUM(total_amount), 0) as total FROM nh_products WHERE send_date = $1`,
            [today]
        );

        // Get pending products count
        const pendingResult = await queryWithValues<{ count: string }>(
            `SELECT COUNT(*) as count FROM nh_products WHERE status = 'pending'`
        );

        // Get recent products
        const recentProducts = await queryWithValues(
            `SELECT id, sender_name, sender_station, status, created_at
             FROM nh_products
             ORDER BY created_at DESC
             LIMIT 5`
        );

        // Get recent bookings
        const recentBookings = await queryWithValues(
            `SELECT id, customer_name, customer_phone, route, status, created_at
             FROM th_bookings
             ORDER BY created_at DESC
             LIMIT 5`
        );

        return NextResponse.json({
            success: true,
            stats: {
                todayProducts: parseInt(productsResult[0]?.count || '0'),
                todayBookings: parseInt(bookingsResult[0]?.count || '0'),
                todayRevenue: parseFloat(revenueResult[0]?.total || '0'),
                pendingProducts: parseInt(pendingResult[0]?.count || '0'),
            },
            recentProducts,
            recentBookings,
        });
    } catch (error) {
        console.error('Dashboard API error:', error);
        return NextResponse.json(
            { success: false, error: 'Failed to fetch dashboard data' },
            { status: 500 }
        );
    }
}
