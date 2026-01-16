import { query, queryOne } from '../../../../../lib/database';
import { NextResponse } from 'next/server';
import bcrypt from 'bcryptjs';

export async function GET(request, { params }) {
  try {
    const user = await queryOne(
      'SELECT id, username, "fullName", role, station, active FROM "NhapHangUsers" WHERE id = $1',
      [params.id]
    );
    if (!user) {
      return NextResponse.json({ success: false, message: 'User not found' }, { status: 404 });
    }
    return NextResponse.json({ success: true, user });
  } catch (error) {
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}

export async function PUT(request, { params }) {
  try {
    const body = await request.json();
    const { username, password, fullName, role, station, active } = body;

    // Check if user exists
    const existingUser = await queryOne('SELECT id FROM "NhapHangUsers" WHERE id = $1', [params.id]);
    if (!existingUser) {
      return NextResponse.json({ success: false, message: 'User not found' }, { status: 404 });
    }

    // Build update query dynamically
    const updates = [];
    const values = [];
    let paramIndex = 1;

    if (username !== undefined) {
      updates.push(`username = $${paramIndex++}`);
      values.push(username);
    }
    if (password !== undefined && password.trim() !== '') {
      const hashedPassword = await bcrypt.hash(password, 10);
      updates.push(`password = $${paramIndex++}`);
      values.push(hashedPassword);
    }
    if (fullName !== undefined) {
      updates.push(`"fullName" = $${paramIndex++}`);
      values.push(fullName);
    }
    if (role !== undefined) {
      updates.push(`role = $${paramIndex++}`);
      values.push(role);
    }
    if (station !== undefined) {
      updates.push(`station = $${paramIndex++}`);
      values.push(station);
    }
    if (active !== undefined) {
      updates.push(`active = $${paramIndex++}`);
      values.push(active);
    }

    updates.push(`"updatedAt" = NOW()`);

    if (updates.length === 1) {
      return NextResponse.json({ success: false, message: 'No fields to update' }, { status: 400 });
    }

    values.push(params.id);
    const result = await query(
      `UPDATE "NhapHangUsers" SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING id, username, "fullName", role, station, active`,
      values
    );

    return NextResponse.json({ success: true, user: result[0] });
  } catch (error) {
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  try {
    const result = await query('DELETE FROM "NhapHangUsers" WHERE id = $1 RETURNING id', [params.id]);
    if (result.length === 0) {
      return NextResponse.json({ success: false, message: 'User not found' }, { status: 404 });
    }
    return NextResponse.json({ success: true, message: 'User deleted' });
  } catch (error) {
    return NextResponse.json({ success: false, message: error.message }, { status: 500 });
  }
}
