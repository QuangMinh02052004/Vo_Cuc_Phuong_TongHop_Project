import { queryTongHop } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// POST /api/tong-hop/customers - Save customer info
export async function POST(request) {
  try {
    const { phone, fullName, pickupType, pickupLocation, dropoffType, dropoffLocation, notes } = await request.json();

    if (!phone || !fullName) {
      return NextResponse.json({ error: 'Missing required fields: phone, fullName' }, { status: 400 });
    }

    // Try to create/update customer in database
    // For now, just upsert into TH_Customers table
    try {
      await queryTongHop(`
        INSERT INTO "TH_Customers" (phone, "fullName", "pickupType", "pickupLocation", "dropoffType", "dropoffLocation", notes, "updatedAt")
        VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
        ON CONFLICT (phone) DO UPDATE SET
          "fullName" = EXCLUDED."fullName",
          "pickupType" = EXCLUDED."pickupType",
          "pickupLocation" = EXCLUDED."pickupLocation",
          "dropoffType" = EXCLUDED."dropoffType",
          "dropoffLocation" = EXCLUDED."dropoffLocation",
          notes = EXCLUDED.notes,
          "updatedAt" = NOW()
      `, [phone, fullName, pickupType || null, pickupLocation || null, dropoffType || null, dropoffLocation || null, notes || null]);

      return NextResponse.json({ success: true, message: 'Customer saved' });
    } catch (dbError) {
      // Table might not exist, just log and continue
      console.log('Note: TH_Customers table may not exist yet. Customer not saved.');
      return NextResponse.json({ success: true, message: 'Customer data received (table not initialized)' });
    }
  } catch (error) {
    console.error('Error saving customer:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
