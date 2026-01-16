import { NextRequest, NextResponse } from 'next/server';
import { queryWithValues } from '@/lib/db';

// POST - Tạo khung giờ cho ngày
export async function POST(request: NextRequest) {
    try {
        const { date } = await request.json();

        if (!date) {
            return NextResponse.json(
                { success: false, error: 'Date is required' },
                { status: 400 }
            );
        }

        // Check if timeslots already exist for this date
        const existing = await queryWithValues<{ count: string }>(
            'SELECT COUNT(*) as count FROM th_timeslots WHERE date = $1',
            [date]
        );

        if (parseInt(existing[0]?.count || '0') > 0) {
            return NextResponse.json({
                success: false,
                error: 'Timeslots already exist for this date'
            });
        }

        // Generate timeslots for Sài Gòn - Long Khánh (05:30 - 20:00)
        const sgLkTimes = [];
        for (let hour = 5; hour <= 20; hour++) {
            if (hour === 5) {
                sgLkTimes.push('05:30');
            } else {
                sgLkTimes.push(`${hour.toString().padStart(2, '0')}:00`);
                if (hour < 20) {
                    sgLkTimes.push(`${hour.toString().padStart(2, '0')}:30`);
                }
            }
        }

        // Generate timeslots for Long Khánh - Sài Gòn (03:30 - 18:00)
        const lkSgTimes = [];
        for (let hour = 3; hour <= 18; hour++) {
            if (hour === 3) {
                lkSgTimes.push('03:30');
            } else {
                lkSgTimes.push(`${hour.toString().padStart(2, '0')}:00`);
                if (hour < 18) {
                    lkSgTimes.push(`${hour.toString().padStart(2, '0')}:30`);
                }
            }
        }

        // Insert timeslots
        for (const time of sgLkTimes) {
            await queryWithValues(
                `INSERT INTO th_timeslots (time, date, route, type) VALUES ($1, $2, $3, $4)`,
                [time, date, 'Sài Gòn - Long Khánh', 'Xe 28G']
            );
        }

        for (const time of lkSgTimes) {
            await queryWithValues(
                `INSERT INTO th_timeslots (time, date, route, type) VALUES ($1, $2, $3, $4)`,
                [time, date, 'Long Khánh - Sài Gòn', 'Xe 28G']
            );
        }

        return NextResponse.json({
            success: true,
            message: `Created ${sgLkTimes.length + lkSgTimes.length} timeslots for ${date}`
        });
    } catch (error) {
        console.error('Error generating timeslots:', error);
        return NextResponse.json(
            { success: false, error: 'Failed to generate timeslots' },
            { status: 500 }
        );
    }
}
