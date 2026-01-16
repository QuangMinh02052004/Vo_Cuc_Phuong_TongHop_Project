import { queryTongHop, queryOneTongHop } from '../../../../../../lib/database';
import { NextResponse } from 'next/server';

// GET /api/tong-hop/customers/search/[phone] - Search customer by phone
export async function GET(request, { params }) {
  try {
    const resolvedParams = await params;
    const phone = resolvedParams.phone;

    if (!phone || phone.length < 10) {
      return NextResponse.json({ found: false, message: 'Phone number too short' });
    }

    // First try to find in TH_Customers table
    try {
      const customer = await queryOneTongHop(`
        SELECT * FROM "TH_Customers" WHERE phone = $1
      `, [phone]);

      if (customer) {
        return NextResponse.json({
          found: true,
          customer: {
            phone: customer.phone,
            fullName: customer.fullName,
            pickupType: customer.pickupType,
            pickupLocation: customer.pickupLocation,
            dropoffType: customer.dropoffType,
            dropoffLocation: customer.dropoffLocation,
            notes: customer.notes
          }
        });
      }
    } catch (e) {
      // Table might not exist, continue to next search
    }

    // If not found in customers table, search in recent bookings
    try {
      const booking = await queryOneTongHop(`
        SELECT * FROM "TH_Bookings" WHERE phone = $1 ORDER BY "createdAt" DESC LIMIT 1
      `, [phone]);

      if (booking) {
        return NextResponse.json({
          found: true,
          customer: {
            phone: booking.phone,
            fullName: booking.name,
            pickupType: booking.pickupMethod,
            pickupLocation: booking.pickupAddress,
            dropoffType: booking.dropoffMethod,
            dropoffLocation: booking.dropoffAddress,
            notes: booking.note
          }
        });
      }
    } catch (e) {
      // Bookings table might have different schema
    }

    return NextResponse.json({ found: false });
  } catch (error) {
    console.error('Error searching customer:', error);
    return NextResponse.json({ found: false, error: error.message });
  }
}
