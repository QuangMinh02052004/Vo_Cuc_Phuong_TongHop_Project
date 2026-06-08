/**
 * Danh sách 94 địa chỉ trả + hàm matching viết tắt
 * Ported from NhapHang backend (stations.js + address-matcher.js)
 */

const stations = [
  { stt: '1', name: 'An Đông', aliases: ['an dong', 'a dong', 'adong'] },
  { stt: '2', name: 'Ngã 4 Trần Phú-Lê Hồng Phong', aliases: ['n4 tran phu le hong phong', 'nga 4 tran phu', 'tran phu le hong phong', 'n4 tphu lhp'] },
  { stt: '3', name: 'Ngã 4 Trần Phú-Trần Bình Trọng', aliases: ['n4 tran phu tran binh trong', 'nga 4 tran phu', 'tran phu tran binh trong', 'n4 tphu tbt'] },
  { stt: '4', name: 'Nhà Sách Nguyễn Thị Minh Khai', aliases: ['nha sach ntmk', 'nha sach nguyen thi minh khai', 'ns ntmk', 'nha sach'] },
  { stt: '5', name: 'BV Từ Dũ - Nguyễn Thị Minh Khai', aliases: ['bv tu du', 'benh vien tu du', 'tu du'] },
  { stt: '6', name: 'Sở Y Tế - Nguyễn Thị Minh Khai', aliases: ['so y te', 'so y te ntmk', 'syt ntmk', 'so y te nguyen thi minh khai'] },
  { stt: '7', name: 'CV Tao Đàn - Nguyễn Thị Minh Khai', aliases: ['cv tao dan', 'cong vien tao dan', 'tao dan'] },
  { stt: '7.1', name: 'Trương Định - Nguyễn Thị Minh Khai', aliases: ['truong dinh', 'truong dinh ntmk', 'td ntmk'] },
  { stt: '8', name: 'Cung VH Lao Động - Nguyễn Thị Minh Khai', aliases: ['cung vh lao dong', 'cung van hoa lao dong', 'cvh lao dong', 'van hoa lao dong'] },
  { stt: '9', name: 'N4 Nam Ki - Nguyễn Thị Minh Khai', aliases: ['n4 nam ki', 'nga 4 nam ki', 'nam ki'] },
  { stt: '10', name: 'Ngã 4 Pastuer - Nguyễn Thị Minh Khai', aliases: ['n4 pasteur', 'nga 4 pasteur', 'pasteur', 'n4 pastuer'] },
  { stt: '11', name: 'Nhà VH Thanh Niên  - Nguyễn Thị Minh Khai', aliases: ['nha vh thanh nien', 'nha van hoa thanh nien', 'nvh thanh nien', 'van hoa thanh nien'] },
  { stt: '12', name: 'Ngã 3 PK.Khoan - Nguyễn Thị Minh Khai', aliases: ['n3 pk khoan', 'nga 3 pk khoan', 'pk khoan', 'phan khoan'] },
  { stt: '13', name: 'Ngã 4 M.Đ.Chi - Nguyễn Thị Minh Khai', aliases: ['n4 md chi', 'nga 4 md chi', 'mai dong chi', 'md chi'] },
  { stt: '14', name: 'Sân VD Hoa Lư - Nguyễn Thị Minh Khai', aliases: ['san vd hoa lu', 'san van dong hoa lu', 'svd hoa lu', 'hoa lu'] },
  { stt: '14.1', name: 'Ngã 4.Đinh Tiên Hoàng - Nguyễn Thị Minh Khai', aliases: ['n4 dinh tien hoang', 'nga 4 dinh tien hoang', 'dinh tien hoang', 'n4 dth'] },
  { stt: '15', name: 'Cầu Đen', aliases: ['cau den', 'cauden'] },
  { stt: '16', name: 'Cầu Trắng', aliases: ['cau trang', 'cautrang'] },
  { stt: '17', name: 'Metro', aliases: ['meto', 'met ro', 'me tro'] },
  { stt: '18', name: 'Cantavil', aliases: ['canta vil', 'can ta vil', 'kantavil'] },
  { stt: '21', name: 'Ngã 4 MK', aliases: ['n4 mk', 'nga 4 mk', 'minh khai', 'nguyen thi minh khai'] },
  { stt: '22', name: 'Ngã 4 Bình Thái', aliases: ['n4 binh thai', 'nga 4 binh thai', 'binh thai'] },
  { stt: '23', name: 'Ngã 4 Thủ Đức', aliases: ['n4 thu duc', 'nga 4 thu duc', 'thu duc', 'n4 tduc'] },
  { stt: '24', name: 'Khu Công Nghệ Cao', aliases: ['kcnc', 'khu cong nghe cao', 'cong nghe cao'] },
  { stt: '25', name: 'Suối Tiên', aliases: ['suoi tien', 'cvvh suoi tien'] },
  { stt: '26', name: 'Ngã 4 621', aliases: ['n4 621', 'nga 4 621', '621'] },
  { stt: '27', name: 'Tân Vạn', aliases: ['tan van', 'tanvan', 't van'] },
  { stt: '28', name: 'Ngã 3 Vũng Tàu', aliases: ['n3 vung tau', 'nga 3 vung tau', 'vung tau', 'n3 vtau'] },
  { stt: '29', name: 'Bồn Nước', aliases: ['bon nuoc', 'bonnuoc', 'b nuoc'] },
  { stt: '30', name: 'Tam Hiệp', aliases: ['tam hiep', 'tamhiep', 't hiep'] },
  { stt: '31', name: 'Amata', aliases: ['amata', 'amt', 'kcn amata'] },
  { stt: '32', name: 'BV Nhi Đồng Nai', aliases: ['bv nhi dong nai', 'benh vien nhi dong nai', 'nhi dong nai', 'bv nhi'] },
  { stt: '33', name: 'Cầu Sập', aliases: ['csap', 'cau sap'] },
  { stt: '34', name: 'Bến xe Hố Nai', aliases: ['bx hnai', 'hnai', 'bxe hnai'] },
  { stt: '35', name: 'Chợ Sặt', aliases: ['csat', 'cho sat'] },
  { stt: '36', name: 'Công Viên 30/4', aliases: ['30/4', 'cv 30/4', '30.4', 'cv30.4'] },
  { stt: '37', name: 'Bệnh Viện Thánh Tâm', aliases: ['ttam', 'bv thanh tam', 'bv ttam', 'bv thanhtam'] },
  { stt: '38', name: 'Nhà thờ Thánh Tâm', aliases: ['nha tho thanh tam', 'nt thanh tam', 'thanh tam', 'nt ttam'] },
  { stt: '39', name: 'Cây Xăng Lộ Đức', aliases: ['cay xang lo duc', 'cx lo duc', 'xang lo duc', 'cx lduc', 'lduc', 'lo duc'] },
  { stt: '40', name: 'Nhà thờ Tiên Chu', aliases: ['nha tho tien chu', 'nt tien chu', 'tien chu', 'nt tchu'] },
  { stt: '41', name: 'Chợ Thái Bình', aliases: ['cho thai binh', 'thai binh', 'cho tbinh'] },
  { stt: '42', name: 'Nhà thờ Ngọc Đồng', aliases: ['nha tho ngoc dong', 'nt ngoc dong', 'ngoc dong', 'nt ndong'] },
  { stt: '43', name: 'Nhà thờ Ngô Xá', aliases: ['nha tho ngo xa', 'nt ngo xa', 'ngo xa', 'nt nxa'] },
  { stt: '44', name: 'Nhà thờ Sài Quất', aliases: ['nha tho sai quat', 'nt sai quat', 'sai quat', 'nt squat'] },
  { stt: '44.1', name: 'Ngũ Phúc', aliases: ['ngu phuc', 'nguphuc', 'npghuc'] },
  { stt: '45', name: 'Nhà thờ Thái Hoà', aliases: ['nha tho thai hoa', 'nt thai hoa', 'thoa', 'thaihoa', 'thai hoa', 'nt thoa'] },
  { stt: '45.1', name: 'Yên Thế', aliases: ['n3 yen the', 'yen the', 'yenthe', 'ythe'] },
  { stt: '46', name: 'Chợ chiều Thanh Hoá', aliases: ['cho chieu thanh hoa', 'cho thanh hoa', 'cho chieu thoa', 'thanh hoa'] },
  { stt: '46.1', name: 'Nhà thờ Thanh Hoá', aliases: ['nha tho thanh hoa', 'nt thanh hoa', 'nt thoa'] },
  { stt: '47', name: 'Ngã 3 Trị An', aliases: ['tri an', 'n3 tri an', 'nga 3 tri an'] },
  { stt: '47.1', name: 'Nhà thờ Bùi Chu', aliases: ['nha tho bui chu', 'nt bui chu', 'bui chu', 'nt bchu'] },
  { stt: '48', name: 'Bắc Sơn', aliases: ['bac son', 'bacson', 'bson'] },
  { stt: '49', name: 'Phú Sơn', aliases: ['phu son', 'pson', 'n3 pson', 'nga 3 phu son', 'n3 phu son'] },
  { stt: '50', name: 'Nhà thờ Tân Thành', aliases: ['nha tho tan thanh', 'nt tan thanh', 'tan thanh', 'nt tthanh'] },
  { stt: '51', name: 'Nhà thờ Tân Bắc', aliases: ['tbac', 'tanbac', 'nt tbac', 'nt tanbac', 'nt tan bac', 'nha tho tbac'] },
  { stt: '52', name: 'Suối Đĩa', aliases: ['suoi dia', 'suoidia', 'sdia'] },
  { stt: '53', name: 'Nhà thờ Tân Bình', aliases: ['tbinh', 'tanbinh', 'nt tbinh', 'ntho tanbinh', 'nt tan binh', 'nha tho tbinh'] },
  { stt: '54', name: 'Trà Cổ', aliases: ['tra co', 'traco', 'tco', 'nt tco', 'nt tra co', 'nt traco'] },
  { stt: '54.1', name: 'Bar Romance', aliases: ['bar romance', 'romance', 'bar'] },
  { stt: '55', name: 'Nhà thờ Quảng Biên', aliases: ['qbien', 'nt qbien', 'nt quang bien', 'nt quangbien'] },
  { stt: '56', name: 'Chợ Quảng Biên', aliases: ['cho quang bien', 'quang bien', 'cho qbien'] },
  { stt: '57', name: 'Sân Golf Trảng Bom', aliases: ['san golf trang bom', 'golf trang bom', 'san golf tbom', 'golf tbom'] },
  { stt: '58', name: 'Bưu điện Trảng Bom', aliases: ['bd trang bom', 'bd tbom', 'bdien tbom', 'bu dien trang bom', 'buu dien trang bom', 'bd trang b', 'bd t bom', 'tbom'] },
  { stt: '59', name: 'Bờ hồ Trảng Bom', aliases: ['bo ho trang bom', 'bo ho tbom', 'ho trang bom', 'ho tbom'] },
  { stt: '60', name: 'Cây xăng Thành Thái', aliases: ['cay xang thanh thai', 'cx thanh thai', 'thanh thai', 'cx tthai'] },
  { stt: '61', name: 'Trạm cân', aliases: ['tram can', 'tramcan', 't can'] },
  { stt: '62', name: 'KCN Bầu Xéo', aliases: ['kcn bau xeo', 'khu cong nghiep bau xeo', 'bau xeo', 'kcn bxeo'] },
  { stt: '63', name: 'Song Thạch', aliases: ['song thach', 'songthach', 'sthach'] },
  { stt: '64', name: 'Chợ Lộc Hoà', aliases: ['cho loc hoa', 'loc hoa', 'cho lhoa'] },
  { stt: '65', name: 'Thu phí Bầu Cá', aliases: ['thu phi bau ca', 'tp bau ca', 'bau ca', 'bc', 'tram thu phi bau ca'] },
  { stt: '66', name: 'Nhà thờ Tâm An', aliases: ['tam an', 'nt tam an', 'nha tho tam an'] },
  { stt: '67', name: 'Chợ Bầu Cá', aliases: ['cho bau ca', 'bca'] },
  { stt: '68', name: 'Cây xăng Minh Trí', aliases: ['cay xang minh tri', 'cx minh tri', 'minh tri', 'cx mtri'] },
  { stt: '69', name: 'Ba cây Xoài Bầu Cá', aliases: ['ba cay xoai bau ca', '3 cay xoai bau ca', 'ba cay xoai', '3 xoai bau ca'] },
  { stt: '70', name: 'Cổng vàng Hưng Long', aliases: ['cong vang hung long', 'hung long', 'cong vang hlong'] },
  { stt: '71', name: 'Cây xăng Hưng Thịnh', aliases: ['cay xang hung thinh', 'cx hung thinh', 'hung thinh', 'cx hthinh'] },
  { stt: '72', name: 'Sông Thao', aliases: ['song thao', 'songthao', 's thao'] },
  { stt: '73', name: 'Chùa Vạn Thọ', aliases: ['chua van tho', 'van tho', 'chua vtho'] },
  { stt: '74', name: 'Chợ Hưng Nghĩa', aliases: ['cho hung nghia', 'hung nghia', 'cho hnghia'] },
  { stt: '75', name: 'Trạm Giữa', aliases: ['tram giua', 't giua', 'giua'] },
  { stt: '76', name: 'Cây xăng Tam Hoàng', aliases: ['cay xang tam hoang', 'cx tam hoang', 'tam hoang', 'cx thoang'] },
  { stt: '77', name: 'Đại Phát Đạt', aliases: ['dai phat dat', 'phat dat', 'dpdat'] },
  { stt: '78', name: 'Chợ Hưng Lộc', aliases: ['cho hung loc', 'hung loc', 'hloc'] },
  { stt: '79', name: 'Nhà thờ Hưng Lộc', aliases: ['nt hung loc', 'nha tho hung loc', 'nt hloc'] },
  { stt: '80', name: 'Cây xăng Hưng Lộc', aliases: ['cx hung loc', 'cx hloc'] },
  { stt: '81', name: 'Mì Quảng Thủy Tiên', aliases: ['mi quang thuy tien', 'my quang thuy tien', 'mqttien', 'mi quang ttien'] },
  { stt: '82', name: 'Ngô Quyền Dầu Giây', aliases: ['ngo quyen dau giay', 'ngo quyen dgay', 'ngo quyen'] },
  { stt: '83', name: 'Cây xăng Đặng Văn Bích', aliases: ['cay xang dang van bich', 'cx dang van bich', 'cx dvbich', 'dang van bich'] },
  { stt: '84', name: 'Bưu điện Dầu Giây', aliases: ['bd dau giay', 'bd daugiay', 'bd dgay', 'bdien dau giay', 'bu dien dau giay', 'buu dien dau giay'] },
  { stt: '85', name: 'xã Xuân Thạnh Dầu Giây', aliases: ['xa xuan thanh dau giay', 'xuan thanh dau giay', 'xuan thanh dgay', 'xthanh dgay'] },
  { stt: '86', name: 'Trung tâm Hành chính Dầu Giây', aliases: ['trung tam hanh chinh dau giay', 'tt hanh chinh dgay', 'tthc dgay', 'hanh chinh dgay'] },
  { stt: '87', name: 'Bến xe Dầu Giây', aliases: ['ben xe dau giay', 'bx dau giay', 'bx dgay', 'ben xe dgay'] },
  { stt: '88', name: 'Trạm 97', aliases: ['tram 97', 't97', '97'] },
  { stt: '89', name: 'Cáp Rang', aliases: ['cap rang', 'caprang', 'c rang'] },
  { stt: '90', name: 'Bệnh viện Long Khánh', aliases: ['bv long khanh', 'benh vien long khanh', 'bv lk'] },
  { stt: '91', name: 'Cây Xăng Suối Tre', aliases: ['cay xang suoi tre', 'cx suoi tre', 'suoi tre', 'cx stre'] },
  { stt: '92', name: 'Dốc Lê Lợi', aliases: ['doc le loi', 'le loi', 'doc lloi'] },
  { stt: '93', name: 'Cây xăng 222', aliases: ['cay xang 222', 'cx 222', '222'] },
  { stt: '94', name: 'Bến xe Long Khánh', aliases: ['ben xe long khanh', 'bx long khanh', 'bx lk', 'ben xe lk'] },
];

// ========================================
// Matching functions
// ========================================

/**
 * Bỏ dấu tiếng Việt, lowercase, bỏ khoảng trắng thừa
 */
function normalizeVietnamese(str) {
  if (!str) return '';
  str = str.normalize('NFD').replace(/[\u0300-\u036f]/g, '');
  str = str.toLowerCase();
  str = str.replace(/\s+/g, ' ').trim();
  return str;
}

/**
 * Tìm địa chỉ trả từ tên người nhận
 * Ví dụ: "minh tco" → { stt: '54', stationName: 'Trà Cổ', matchedText: 'tco' }
 */
function extractAddressFromName(receiverName) {
  if (!receiverName || typeof receiverName !== 'string') {
    return null;
  }

  const normalized = normalizeVietnamese(receiverName);

  // Sort by name length (longest first) để match chính xác hơn
  const sortedStations = [...stations].sort((a, b) => b.name.length - a.name.length);

  // STEP 1: Match full station name
  for (const station of sortedStations) {
    const stationNormalized = normalizeVietnamese(station.name);
    if (normalized.includes(stationNormalized)) {
      console.log(`[AddressMatcher] Full name match: "${station.name}" in "${receiverName}"`);
      return {
        stt: station.stt,
        stationName: station.name,
        matchedText: station.name
      };
    }
  }

  // STEP 2: Match aliases (sort longest first)
  for (const station of sortedStations) {
    if (!station.aliases || station.aliases.length === 0) continue;

    const sortedAliases = [...station.aliases].sort((a, b) => b.length - a.length);

    for (const alias of sortedAliases) {
      const aliasNormalized = normalizeVietnamese(alias);
      if (normalized.includes(aliasNormalized)) {
        console.log(`[AddressMatcher] Alias match: "${alias}" → "${station.name}" in "${receiverName}"`);
        return {
          stt: station.stt,
          stationName: station.name,
          matchedText: alias
        };
      }
    }
  }

  console.log(`[AddressMatcher] No match found for: "${receiverName}"`);
  return null;
}

/**
 * Lấy tên người nhận (bỏ phần địa chỉ đã match)
 * Ví dụ: "minh tco", matchedText "tco" → "minh"
 */
function extractNameOnly(receiverName, matchedText) {
  if (!receiverName || !matchedText) return receiverName;

  const normalized = normalizeVietnamese(receiverName);
  const matchedNormalized = normalizeVietnamese(matchedText);

  const index = normalized.indexOf(matchedNormalized);
  if (index !== -1) {
    const before = receiverName.substring(0, index).trim();
    const after = receiverName.substring(index + matchedText.length).trim();
    return (before + ' ' + after).trim();
  }

  return receiverName.trim();
}

export { stations, normalizeVietnamese, extractAddressFromName, extractNameOnly };
