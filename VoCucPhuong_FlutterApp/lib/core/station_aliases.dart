/// Map viết tắt 2-3 ký tự -> tên trạm đầy đủ. Dùng để auto-detect trạm
/// nhận từ note khi nhân viên nhập đơn nhanh.
const Map<String, String> kStationAliases = {
  'tco': 'Trà Cổ',
  'tc': 'Trà Cổ',
  'mc': 'Móng Cái',
  'mcai': 'Móng Cái',
  'hl': 'Hạ Long',
  'hlg': 'Hạ Long',
  'ck': 'Cẩm Phả',
  'cp': 'Cẩm Phả',
  'qn': 'Quảng Ninh',
  'hn': 'Hà Nội',
  'hp': 'Hải Phòng',
  'tp': 'Tiên Yên',
  'ty': 'Tiên Yên',
  'dh': 'Đầm Hà',
  'bc': 'Bình Liêu',
  'vd': 'Vân Đồn',
};

String? detectStationFromNote(String note) {
  if (note.trim().isEmpty) return null;
  final tokens = note
      .toLowerCase()
      .split(RegExp(r'[\s,;./\-]+'))
      .where((s) => s.isNotEmpty);
  for (final t in tokens) {
    final hit = kStationAliases[t];
    if (hit != null) return hit;
  }
  return null;
}
