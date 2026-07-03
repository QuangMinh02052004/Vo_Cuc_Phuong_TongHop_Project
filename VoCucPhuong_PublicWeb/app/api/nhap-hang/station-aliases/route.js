import { NextResponse } from 'next/server';
import { getAllStationAliases, updateStationAliases } from '../../../../lib/station-aliases';

export const dynamic = 'force-dynamic';

// ===========================================
// API: Station Aliases — từ viết tắt auto-fill trạm nhận (auto-booking NhapHang → TongHop)
// ===========================================
// GET  /api/nhap-hang/station-aliases          → danh sách 94 trạm + aliases
// PUT  /api/nhap-hang/station-aliases           → { stt, aliases: [...] } lưu aliases 1 trạm

export async function GET() {
  try {
    const data = await getAllStationAliases();
    return NextResponse.json({ success: true, data, count: data.length });
  } catch (error) {
    console.error('[StationAliases] GET Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}

export async function PUT(request) {
  try {
    const body = await request.json();
    const { stt, aliases } = body || {};
    if (!stt) {
      return NextResponse.json({ success: false, error: 'Thiếu stt' }, { status: 400 });
    }
    if (!Array.isArray(aliases)) {
      return NextResponse.json({ success: false, error: 'aliases phải là mảng' }, { status: 400 });
    }
    const row = await updateStationAliases(stt, aliases);
    if (!row) {
      return NextResponse.json({ success: false, error: 'Không tìm thấy trạm' }, { status: 404 });
    }
    return NextResponse.json({ success: true, data: row });
  } catch (error) {
    console.error('[StationAliases] PUT Error:', error);
    return NextResponse.json({ success: false, error: error.message }, { status: 500 });
  }
}
