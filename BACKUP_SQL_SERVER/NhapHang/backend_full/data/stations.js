/**
 * Danh sách 94 địa chỉ trả
 * Copied from TongHop system
 *
 * ==========================================
 * HƯỚNG DẪN THÊM ALIASES (TỪ VIẾT TẮT)
 * ==========================================
 *
 * Mỗi trạm có thể có thêm field 'aliases' - một array các cách viết khác nhau.
 *
 * Cách sử dụng:
 * 1. Thêm aliases vào từng station object
 * 2. Mỗi alias là một string (không phân biệt dấu, hoa/thường)
 * 3. Aliases có thể là:
 *    - Viết tắt (ví dụ: "bd tbom" cho "Bưu điện Trảng Bom")
 *    - Biến thể chính tả (ví dụ: "metro", "meto")
 *    - Cách gọi tắt phổ biến (ví dụ: "bc" cho "Bầu Cá")
 *
 * Lưu ý:
 * - Hệ thống sẽ tự động bỏ dấu khi so sánh
 * - Không cần viết hoa/thường chính xác
 * - Aliases càng nhiều càng dễ match
 *
 * Ví dụ đầy đủ:
 * {
 *   stt: '58',
 *   name: 'Bưu điện Trảng Bom',
 *   aliases: ['bd tbom', 'bd trang bom', 'bdien tbom', 'bu dien trang bom']
 * }
 *
 * Khi user nhập: "Minh bd tbom" → Tự động match với "Bưu điện Trảng Bom"
 *
 * ==========================================
 * 15 VÍ DỤ MẪU - BẠN HÃY LÀM TƯƠNG TỰ CHO 79 TRẠM CÒN LẠI
 * ==========================================
 */

const stations = [
  // ✅ Ví dụ 1: Tên ngắn - viết tắt đơn giản
  {
    stt: '1',
    name: 'An Đông',
    aliases: ['an dong', 'a dong', 'adong']
  },

  {
    stt: '2',
    name: 'Ngã 4 Trần Phú-Lê Hồng Phong',
    aliases: ['n4 tran phu le hong phong', 'nga 4 tran phu', 'tran phu le hong phong', 'n4 tphu lhp']
  },
  {
    stt: '3',
    name: 'Ngã 4 Trần Phú-Trần Bình Trọng',
    aliases: ['n4 tran phu tran binh trong', 'nga 4 tran phu', 'tran phu tran binh trong', 'n4 tphu tbt']
  },
  {
    stt: '4',
    name: 'Nhà Sách Nguyễn Thị Minh Khai',
    aliases: ['nha sach ntmk', 'nha sach nguyen thi minh khai', 'ns ntmk', 'nha sach']
  },

  // ✅ Ví dụ 2: Bệnh viện - viết tắt BV
  {
    stt: '5',
    name: 'BV Từ Dũ - Nguyễn Thị Minh Khai',
    aliases: ['bv tu du', 'benh vien tu du', 'tu du']
  },

  {
    stt: '6',
    name: 'Sở Y Tế - Nguyễn Thị Minh Khai',
    aliases: ['so y te', 'so y te ntmk', 'syt ntmk', 'so y te nguyen thi minh khai']
  },

  // ✅ Ví dụ 3: Công viên - viết tắt CV
  {
    stt: '7',
    name: 'CV Tao Đàn - Nguyễn Thị Minh Khai',
    aliases: ['cv tao dan', 'cong vien tao dan', 'tao dan']
  },

  {
    stt: '7.1',
    name: 'Trương Định - Nguyễn Thị Minh Khai',
    aliases: ['truong dinh', 'truong dinh ntmk', 'td ntmk']
  },
  {
    stt: '8',
    name: 'Cung VH Lao Động - Nguyễn Thị Minh Khai',
    aliases: ['cung vh lao dong', 'cung van hoa lao dong', 'cvh lao dong', 'van hoa lao dong']
  },
  {
    stt: '9',
    name: 'N4 Nam Ki - Nguyễn Thị Minh Khai',
    aliases: ['n4 nam ki', 'nga 4 nam ki', 'nam ki']
  },
  {
    stt: '10',
    name: 'Ngã 4 Pastuer - Nguyễn Thị Minh Khai',
    aliases: ['n4 pasteur', 'nga 4 pasteur', 'pasteur', 'n4 pastuer']
  },
  {
    stt: '11',
    name: 'Nhà VH Thanh Niên  - Nguyễn Thị Minh Khai',
    aliases: ['nha vh thanh nien', 'nha van hoa thanh nien', 'nvh thanh nien', 'van hoa thanh nien']
  },
  {
    stt: '12',
    name: 'Ngã 3 PK.Khoan - Nguyễn Thị Minh Khai',
    aliases: ['n3 pk khoan', 'nga 3 pk khoan', 'pk khoan', 'phan khoan']
  },
  {
    stt: '13',
    name: 'Ngã 4 M.Đ.Chi - Nguyễn Thị Minh Khai',
    aliases: ['n4 md chi', 'nga 4 md chi', 'mai dong chi', 'md chi']
  },
  {
    stt: '14',
    name: 'Sân VD Hoa Lư - Nguyễn Thị Minh Khai',
    aliases: ['san vd hoa lu', 'san van dong hoa lu', 'svd hoa lu', 'hoa lu']
  },
  {
    stt: '14.1',
    name: 'Ngã 4.Đinh Tiên Hoàng - Nguyễn Thị Minh Khai',
    aliases: ['n4 dinh tien hoang', 'nga 4 dinh tien hoang', 'dinh tien hoang', 'n4 dth']
  },

  // ✅ Ví dụ 4: Tên đơn giản - variations
  {
    stt: '15',
    name: 'Cầu Đen',
    aliases: ['cau den', 'cauđen']
  },

  {
    stt: '16',
    name: 'Cầu Trắng',
    aliases: ['cau trang', 'cautrắng']
  },

  // ✅ Ví dụ 5: Tên nước ngoài - typos phổ biến
  {
    stt: '17',
    name: 'Metro',
    aliases: ['meto', 'met ro', 'me tro']
  },

  // ✅ Ví dụ 6: Tên riêng - variations
  {
    stt: '18',
    name: 'Cantavil',
    aliases: ['canta vil', 'can ta vil', 'kantavil']
  },

  {
    stt: '21',
    name: 'Ngã 4 MK',
    aliases: ['n4 mk', 'nga 4 mk', 'minh khai', 'nguyen thi minh khai']
  },
  {
    stt: '22',
    name: 'Ngã 4 Bình Thái',
    aliases: ['n4 binh thai', 'nga 4 binh thai', 'binh thai']
  },
  {
    stt: '23',
    name: 'Ngã 4 Thủ Đức',
    aliases: ['n4 thu duc', 'nga 4 thu duc', 'thu duc', 'n4 tduc']
  },

  // ✅ Ví dụ 7: Khu công nghiệp - viết tắt KCN
  {
    stt: '24',
    name: 'Khu Công Nghệ Cao',
    aliases: ['kcnc', 'khu cong nghe cao', 'cong nghe cao']
  },

  // ✅ Ví dụ 8: Địa danh du lịch
  {
    stt: '25',
    name: 'Suối Tiên',
    aliases: ['suoi tien', 'suoi tien', 'cvvh suoi tien']
  },
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  //=========================================================//
  {
    stt: '26',
    name: 'Ngã 4 621',
    aliases: ['n4 621', 'nga 4 621', '621']
  },
  {
    stt: '27',
    name: 'Tân Vạn',
    aliases: ['tan van', 'tanvan', 't van']
  },
  {
    stt: '28',
    name: 'Ngã 3 Vũng Tàu',
    aliases: ['n3 vung tau', 'nga 3 vung tau', 'vung tau', 'n3 vtau']
  },
  {
    stt: '29',
    name: 'Bồn Nước',
    aliases: ['bon nuoc', 'bonnuoc', 'b nuoc']
  },
  {
    stt: '30',
    name: 'Tam Hiệp',
    aliases: ['tam hiep', 'tamhiep', 't hiep']
  },
  {
    stt: '31',
    name: 'Amata',
    aliases: ['amata', 'amt', 'kcn amata']
  },

  // ✅ Ví dụ 9: Bệnh viện với địa danh
  {
    stt: '32',
    name: 'Amata',
    aliases: ['amt']
  },
  {
    stt: '32',
    name: 'BV Nhi Đồng Nai',
    aliases: ['bv nhi dong nai', 'benh vien nhi dong nai', 'nhi dong nai', 'bv nhi', 'bv nhi']
  },

  // TODO: Thêm aliases
  {
    stt: '33', name: 'Cầu Sập', aliases: ['csap', 'cau sap']
  },
  { stt: '34', name: 'Bến xe Hố Nai', aliases: ['bx hnai', 'hnai', 'bxe hnai'] },
  { stt: '35', name: 'Chợ Sặt', aliases: ['csat', 'cho sat'] },
  { stt: '36', name: 'Công Viên 30/4', aliases: ['30/4', 'cv 30/4', '30.4', 'cv30.4'] },
  { stt: '37', name: 'Bệnh Viện Thánh Tâm', aliases: ['ttam', 'bv thanh tam', 'bv ttam', 'bv thanhtam'] },

  // ✅ Ví dụ 10: Nhà thờ - pattern chung
  {
    stt: '38',
    name: 'Nhà thờ Thánh Tâm',
    aliases: ['nha tho thanh tam', 'nt thanh tam', 'thanh tam', 'nt ttam']
  },

  // ✅ Ví dụ 11: Cây xăng - pattern chung
  {
    stt: '39',
    name: 'Cây Xăng Lộ Đức',
    aliases: ['cay xang lo duc', 'cx lo duc', 'xang lo duc', 'cx lduc', 'lduc', 'lo duc']
  },

  {
    stt: '40',
    name: 'Nhà thờ Tiên Chu',
    aliases: ['nha tho tien chu', 'nt tien chu', 'tien chu', 'nt tchu']
  },
  {
    stt: '41',
    name: 'Chợ Thái Bình',
    aliases: ['cho thai binh', 'thai binh', 'cho tbinh']
  },
  {
    stt: '42',
    name: 'Nhà thờ Ngọc Đồng',
    aliases: ['nha tho ngoc dong', 'nt ngoc dong', 'ngoc dong', 'nt ndong']
  },
  {
    stt: '43',
    name: 'Nhà thờ Ngô Xá',
    aliases: ['nha tho ngo xa', 'nt ngo xa', 'ngo xa', 'nt nxa']
  },
  {
    stt: '44',
    name: 'Nhà thờ Sài Quất',
    aliases: ['nha tho sai quat', 'nt sai quat', 'sai quat', 'nt squat']
  },
  { stt: '44.1', name: 'Ngũ Phúc', aliases: ['ngu phuc', 'nguphuc', 'npghuc'] },
  {
    stt: '45',
    name: 'Nhà thờ Thái Hoà',
    aliases: ['nha tho thai hoa', 'nt thai hoa', 'thoa', 'thaihoa', 'thai hoa', 'nt thoa']
  },
  {
    stt: '45.1',
    name: 'Yên Thế',
    aliases: ['n3 yên thế', 'yen the', 'yenthe', 'ythe']
  },
  {
    stt: '46',
    name: 'Chợ chiều Thanh Hoá',
    aliases: ['cho chieu thanh hoa', 'cho thanh hoa', 'cho chieu thoa', 'thanh hoa']
  },
  {
    stt: '46.1',
    name: 'Nhà thờ Thanh Hoá',
    aliases: ['nha tho thanh hoa', 'nt thanh hoa', 'nt thoa', 'thanh hoa']
  },
  { stt: '47', name: 'Ngã 3 Trị An', aliases: ['tri an', 'n3 trị an', 'n3 tri an', 'ngã 3 trị an', 'ngã 3 tri an '] },
  {
    stt: '47.1',
    name: 'Nhà thờ Bùi Chu',
    aliases: ['nha tho bui chu', 'nt bui chu', 'bui chu', 'nt bchu']
  },
  {
    stt: '48',
    name: 'Bắc Sơn',
    aliases: ['bac son', 'bacson', 'bson']
  },
  { stt: '49', name: 'Phú Sơn', aliases: ['phu son', 'pson', 'n3 pson', 'ngã 3 phú sơn', 'n3 phú sơn', 'ngã 3 pson'] },
  {
    stt: '50',
    name: 'Nhà thờ Tân Thành',
    aliases: ['nha tho tan thanh', 'nt tan thanh', 'tan thanh', 'nt tthanh']
  },
  { stt: '51', name: 'Nhà thờ Tân Bắc', aliases: ['tbac', 'tanbac', 'nt tbac', 'nt tanbac', 'nt tan bac', 'nhà thờ tbac'] },
  {
    stt: '52',
    name: 'Suối Đĩa',
    aliases: ['suoi dia', 'suoidia', 'sdia']
  },
  { stt: '53', name: 'Nhà thờ Tân Bình', aliases: ['tbinh', 'tanbinh', 'nt tbinh', 'ntho tanbinh', 'nt tan binh', 'nhà thờ tbinh'] },
  { stt: '54', name: 'Trà Cổ', aliases: ['tra co', 'traco', 'tco', 'nt tco', 'nt tra co', 'nt traco'] },
  {
    stt: '54.1',
    name: 'Bar Romance',
    aliases: ['bar romance', 'romance', 'bar']
  },
  { stt: '55', name: 'Nhà thờ Quảng Biên', aliases: ['qbien', 'nt qbien', 'nt quang bien', 'nt quangbien'] },
  {
    stt: '56',
    name: 'Chợ Quảng Biên',
    aliases: ['cho quang bien', 'quang bien', 'cho qbien']
  },
  {
    stt: '57',
    name: 'Sân Golf Trảng Bom',
    aliases: ['san golf trang bom', 'golf trang bom', 'san golf tbom', 'golf tbom']
  },

  // ✅ Ví dụ 12: QUAN TRỌNG - Bưu điện Trảng Bom (user đã đề cập)
  {
    stt: '58',
    name: 'Bưu điện Trảng Bom',
    aliases: [
      'bd trang bom',      // Viết tắt phổ biến
      'bd tbom',           // Viết tắt ngắn gọn
      'bdien tbom',        // Viết tắt khác
      'bu dien trang bom', // Không dấu đầy đủ
      'buu dien trang bom',
      'bd trang b',        // Viết tắt cực ngắn
      'bd t bom',
      'tbom'
    ]
  },

  {
    stt: '59',
    name: 'Bờ hồ Trảng Bom',
    aliases: ['bo ho trang bom', 'bo ho tbom', 'ho trang bom', 'ho tbom']
  },
  {
    stt: '60',
    name: 'Cây xăng Thành Thái',
    aliases: ['cay xang thanh thai', 'cx thanh thai', 'thanh thai', 'cx tthai']
  },
  {
    stt: '61',
    name: 'Trạm cân',
    aliases: ['tram can', 'tramcan', 't can']
  },
  {
    stt: '62',
    name: 'KCN Bầu Xéo',
    aliases: ['kcn bau xeo', 'khu cong nghiep bau xeo', 'bau xeo', 'kcn bxeo']
  },
  {
    stt: '63',
    name: 'Song Thạch',
    aliases: ['song thach', 'songthach', 'sthach']
  },
  {
    stt: '64',
    name: 'Chợ Lộc Hoà',
    aliases: ['cho loc hoa', 'loc hoa', 'cho lhoa']
  },

  // ✅ Ví dụ 13: Thu phí - pattern quan trọng
  {
    stt: '65',
    name: 'Thu phí Bầu Cá',
    aliases: [
      'thu phi bau ca',
      'tp bau ca',
      'bau ca',
      'bc',              // Viết tắt cực ngắn
      'tram thu phi bau ca'
    ]
  },

  // TODO: Thêm aliases
  { stt: '66', name: 'Nhà thờ Tâm An', aliases: ['tâm an', ' nt tâm an', 'nt tam an', 'nha tho tam an'] },

  // ✅ Ví dụ 14: Chợ + địa danh
  {
    stt: '67',
    name: 'Chợ Bầu Cá',
    aliases: ['cho bau ca', 'bau ca', 'bc', 'bca']
  },

  {
    stt: '68',
    name: 'Cây xăng Minh Trí',
    aliases: ['cay xang minh tri', 'cx minh tri', 'minh tri', 'cx mtri']
  },
  {
    stt: '69',
    name: 'Ba cây Xoài Bầu Cá',
    aliases: ['ba cay xoai bau ca', '3 cay xoai bau ca', 'ba cay xoai', '3 xoai bau ca']
  },
  {
    stt: '70',
    name: 'Cổng vàng Hưng Long',
    aliases: ['cong vang hung long', 'hung long', 'cong vang hlong']
  },
  {
    stt: '71',
    name: 'Cây xăng Hưng Thịnh',
    aliases: ['cay xang hung thinh', 'cx hung thinh', 'hung thinh', 'cx hthinh']
  },
  {
    stt: '72',
    name: 'Sông Thao',
    aliases: ['song thao', 'songthao', 's thao']
  },
  {
    stt: '73',
    name: 'Chùa Vạn Thọ',
    aliases: ['chua van tho', 'van tho', 'chua vtho']
  },
  {
    stt: '74',
    name: 'Chợ Hưng Nghĩa',
    aliases: ['cho hung nghia', 'hung nghia', 'cho hnghia']
  },

  // ✅ Ví dụ 15: Trạm đơn giản
  {
    stt: '75',
    name: 'Trạm Giữa',
    aliases: ['tram giua', 't giua', 'giua']
  },

  { stt: '76', name: 'Cây xăng Tam Hoàng', aliases: ['cay xang tam hoang', 'cx tam hoang', 'tam hoang', 'cx thoang'] },
  {
    stt: '77',
    name: 'Đại Phát Đạt',
    aliases: ['dai phat dat', 'phat dat', 'dpdat']
  },
  { stt: '78', name: 'Chợ Hưng Lộc', aliases: ['cho hung loc', 'hung loc', 'hloc'] },
  { stt: '79', name: 'Nhà thờ Hưng Lộc', aliases: ['nt hung loc', 'nhà thờ hung loc', 'nt hloc', 'nhà thờ hưng lộc'] },
  { stt: '80', name: 'Cây xăng Hưng Lộc', aliases: ['cx hung loc', 'hung loc', 'cx hloc'] },
  { stt: '81', name: 'Mì Quảng Thủy Tiên', aliases: ['mi quang thuy tien', 'my quang thuy tien', 'mqttien', 'mi quang ttien'] },
  {
    stt: '82',
    name: 'Ngô Quyền Dầu Giây',
    aliases: ['ngo quyen dau giay', 'ngo quyen dgay', 'ngo quyen']
  },
  {
    stt: '83',
    name: 'Cây xăng Đặng Văn Bích',
    aliases: ['cay xang dang van bich', 'cx dang van bich', 'cx dvbich', 'dang van bich']
  },

  // ✅ Ví dụ 16: Bưu điện + địa danh (tương tự Trảng Bom)
  {
    stt: '84',
    name: 'Bưu điện Dầu Giây',
    aliases: [
      'bd dau giay',
      'bd daugiay',
      'bd dgay',
      'bdien dau giay',
      'bu dien dau giay',
      'buu dien dau giay'
    ]
  },

  {
    stt: '85',
    name: 'xã Xuân Thạnh Dầu Giây',
    aliases: ['xa xuan thanh dau giay', 'xuan thanh dau giay', 'xuan thanh dgay', 'xthanh dgay']
  },
  {
    stt: '86',
    name: 'Trung tâm Hành chính Dầu Giây',
    aliases: ['trung tam hanh chinh dau giay', 'tt hanh chinh dgay', 'tthc dgay', 'hanh chinh dgay']
  },
  {
    stt: '87',
    name: 'Bến xe Dầu Giây',
    aliases: ['ben xe dau giay', 'bx dau giay', 'bx dgay', 'ben xe dgay']
  },
  {
    stt: '88',
    name: 'Trạm 97',
    aliases: ['tram 97', 't97', '97']
  },
  {
    stt: '89',
    name: 'Cáp Rang',
    aliases: ['cap rang', 'caprang', 'c rang']
  },

  // ✅ Ví dụ 17: Bệnh viện + địa danh (tương tự BV Nhi ĐN)
  {
    stt: '90',
    name: 'Bệnh viện Long Khánh',
    aliases: ['bv long khanh', 'benh vien long khanh', 'bv lk']
  },

  {
    stt: '91',
    name: 'Cây Xăng Suối Tre',
    aliases: ['cay xang suoi tre', 'cx suoi tre', 'suoi tre', 'cx stre']
  },
  {
    stt: '92',
    name: 'Dốc Lê Lợi',
    aliases: ['doc le loi', 'le loi', 'doc lloi']
  },
  {
    stt: '93',
    name: 'Cây xăng 222',
    aliases: ['cay xang 222', 'cx 222', '222']
  },
  {
    stt: '94',
    name: 'Bến xe Long Khánh',
    aliases: ['ben xe long khanh', 'bx long khanh', 'bx lk', 'ben xe lk']
  },

  // ==========================================
  // KẾT THÚC DANH SÁCH 94 TRẠM
  // ==========================================
  // Bạn đã có 17 ví dụ mẫu cho các pattern khác nhau:
  // 1. An Đông - tên ngắn
  // 2. BV Từ Dũ - bệnh viện với viết tắt BV
  // 3. CV Tao Đàn - công viên với viết tắt CV
  // 4-5. Cầu Đen/Trắng - tên đơn giản
  // 6-7. Metro, Cantavil - tên nước ngoài, typos
  // 8. Khu Công Nghệ Cao - KCN
  // 9. Suối Tiên - địa danh du lịch
  // 10. BV Nhi Đồng Nai - BV + địa danh
  // 11. Nhà thờ Thánh Tâm - pattern nhà thờ
  // 12. Cây Xăng Lộ Đức - pattern cây xăng
  // 13. Bưu điện Trảng Bom - QUAN TRỌNG, nhiều aliases
  // 14. Thu phí Bầu Cá - thu phí/trạm
  // 15. Chợ Bầu Cá - chợ + địa danh
  // 16. Trạm Giữa - đơn giản
  // 17. Bưu điện Dầu Giây - bưu điện khác
  // 18. BV Long Khánh - bệnh viện khác
  //
  // Hãy áp dụng các pattern này cho 77 trạm còn lại!
  // ==========================================
];

module.exports = { stations };
