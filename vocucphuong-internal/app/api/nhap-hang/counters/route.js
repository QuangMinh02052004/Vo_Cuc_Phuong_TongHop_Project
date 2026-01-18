import { queryNhapHang, queryOneNhapHang } from '../../../../lib/database';
import { NextResponse } from 'next/server';

// ===========================================
// API: NH_Counters - Sinh mã đơn tự động
// ===========================================
// GET /api/nhap-hang/counters?station=01&date=2025-01-18 - Lấy mã tiếp theo
// POST /api/nhap-hang/counters - Increment counter và trả về mã mới

// Helper: Format date to DDMMYY
function formatDateKey(date) {
  const d = new Date(date);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = String(d.getFullYear()).slice(-2);
  return `${day}${month}${year}`;
}

// Helper: Format date to YYMMDD
function formatYYMMDD(date) {
  const d = new Date(date);
  const day = String(d.getDate()).padStart(2, '0');
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const year = String(d.getFullYear()).slice(-2);
  return `${year}${month}${day}`;
}

// Helper: Generate product ID
// Format: YYMMDD.SSNN (YY=year, MM=month, DD=day, SS=station code, NN=sequence)
function generateProductId(date, stationCode, sequence) {
  const yymmdd = formatYYMMDD(date);
  const ss = stationCode.padStart(2, '0');
  const nn = String(sequence).padStart(2, '0');
  return `${yymmdd}.${ss}${nn}`;
}

export async function GET(request) {
  try {
    const { searchParams } = new URL(request.url);
    const station = searchParams.get('station');
    const date = searchParams.get('date') || new Date().toISOString().split('T')[0];

    if (!station) {
      return NextResponse.json({
        success: false,
        error: 'station là bắt buộc'
      }, { status: 400 });
    }

    const dateKey = formatDateKey(date);
    const counterKey = `counter_${station}_${dateKey}`;

    // Lấy counter hiện tại
    const counter = await queryOneNhapHang(`
      SELECT * FROM "NH_Counters" WHERE "counterKey" = $1
    `, [counterKey]);

    const currentValue = counter ? counter.value : 0;
    const nextValue = currentValue + 1;
    const nextProductId = generateProductId(date, station, nextValue);

    return NextResponse.json({
      success: true,
      data: {
        counterKey,
        station,
        dateKey,
        currentValue,
        nextValue,
        nextProductId
      }
    });

  } catch (error) {
    console.error('[NH_Counters] GET Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}

export async function POST(request) {
  try {
    const body = await request.json();
    const { station, date } = body;

    if (!station) {
      return NextResponse.json({
        success: false,
        error: 'station là bắt buộc'
      }, { status: 400 });
    }

    const sendDate = date || new Date().toISOString().split('T')[0];
    const dateKey = formatDateKey(sendDate);
    const counterKey = `counter_${station}_${dateKey}`;

    // Upsert counter và lấy giá trị mới
    const result = await queryOneNhapHang(`
      INSERT INTO "NH_Counters" ("counterKey", station, "dateKey", value, "lastUpdated")
      VALUES ($1, $2, $3, 1, NOW())
      ON CONFLICT ("counterKey")
      DO UPDATE SET value = "NH_Counters".value + 1, "lastUpdated" = NOW()
      RETURNING *
    `, [counterKey, station, dateKey]);

    const productId = generateProductId(sendDate, station, result.value);

    return NextResponse.json({
      success: true,
      data: {
        ...result,
        productId
      }
    });

  } catch (error) {
    console.error('[NH_Counters] POST Error:', error);
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}
