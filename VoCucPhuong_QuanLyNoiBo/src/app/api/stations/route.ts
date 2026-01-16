import { NextResponse } from 'next/server';
import { queryWithValues } from '@/lib/db';

export async function GET() {
    try {
        const stations = await queryWithValues(
            `SELECT * FROM stations WHERE is_active = true ORDER BY code`
        );
        return NextResponse.json({ success: true, stations });
    } catch (error) {
        console.error('Error fetching stations:', error);
        return NextResponse.json(
            { success: false, error: 'Failed to fetch stations' },
            { status: 500 }
        );
    }
}
