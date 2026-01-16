import { NextRequest, NextResponse } from 'next/server';
import { queryWithValues } from '@/lib/db';

// GET - Tìm khách hàng theo SĐT
export async function GET(request: NextRequest) {
    try {
        const { searchParams } = new URL(request.url);
        const phone = searchParams.get('phone');

        if (!phone) {
            return NextResponse.json(
                { success: false, error: 'Phone number is required' },
                { status: 400 }
            );
        }

        const customers = await queryWithValues(
            'SELECT * FROM th_customers WHERE phone = $1',
            [phone]
        );

        if (customers.length > 0) {
            return NextResponse.json({
                success: true,
                customer: customers[0]
            });
        }

        return NextResponse.json({
            success: true,
            customer: null
        });
    } catch (error) {
        console.error('Error searching customer:', error);
        return NextResponse.json(
            { success: false, error: 'Failed to search customer' },
            { status: 500 }
        );
    }
}
