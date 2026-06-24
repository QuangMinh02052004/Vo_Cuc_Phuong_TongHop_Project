import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String LOGIN_URL =
    'https://vocucphuongmanage.vercel.app/api/nhap-hang/auth/login';

/// ModuleSession — phiên đăng nhập tách riêng cho từng module
/// (tonghop / nhaphang / datve). Mỗi module có Hive box riêng nên
/// đăng nhập / đăng xuất 1 module không ảnh hưởng module khác.
///
/// Cách dùng:
///   final s = ModuleSession('tonghop');
///   await s.load();
///   if (s.isLoggedIn) { ... }
class ModuleSession {
  /// 'tonghop' | 'nhaphang' | 'datve'
  final String moduleKey;

  ModuleSession(this.moduleKey);

  String get _boxName => 'session_$moduleKey';

  static const String _kRole = 'role';
  static const String _kUsername = 'username';
  static const String _kFullName = 'fullName';
  static const String _kToken = 'token';

  String? role;
  String? username;
  String? fullName;
  String? token;

  bool get isLoggedIn =>
      token != null && token!.isNotEmpty && role != null && role != 'customer';
  bool get isCustomer => role == 'customer';

  static bool _hiveInited = false;

  /// Khởi tạo Hive (gọi 1 lần ở main()).
  static Future<void> initStorage() async {
    if (_hiveInited) return;
    await Hive.initFlutter();
    _hiveInited = true;
  }

  Future<Box> _openBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  Future<void> load() async {
    final b = await _openBox();
    role = b.get(_kRole) as String?;
    username = b.get(_kUsername) as String?;
    fullName = b.get(_kFullName) as String?;
    token = b.get(_kToken) as String?;
  }

  Future<void> saveLogin({
    required String role,
    required String username,
    required String fullName,
    required String token,
  }) async {
    this.role = role;
    this.username = username;
    this.fullName = fullName;
    this.token = token;
    final b = await _openBox();
    await b.put(_kRole, role);
    await b.put(_kUsername, username);
    await b.put(_kFullName, fullName);
    await b.put(_kToken, token);
  }

  Future<void> logout() async {
    role = null;
    username = null;
    fullName = null;
    token = null;
    final b = await _openBox();
    await b.clear();
  }

  /// Legacy plain http login (giữ tương thích lệnh gọi cũ — code mới
  /// nên dùng AuthService). Áp dụng cho NhapHang endpoint.
  static Future<String?> legacyNhapHangLogin(String u, String p) async {
    try {
      final res = await http
          .post(
            Uri.parse(LOGIN_URL),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': u, 'password': p}),
          )
          .timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final user = body['user'] ?? {};
        final s = ModuleSession('nhaphang');
        await s.saveLogin(
          role: (user['role'] ?? 'staff').toString(),
          username: (user['username'] ?? u).toString(),
          fullName: (user['fullName'] ?? user['username'] ?? u).toString(),
          token: (body['token'] ?? '').toString(),
        );
        // Lưu cờ migrate SharedPreferences (giữ tương thích phiên bản cũ).
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('role', s.role ?? '');
          await prefs.setString('username', s.username ?? '');
          await prefs.setString('fullName', s.fullName ?? '');
          await prefs.setString('token', s.token ?? '');
        } catch (_) {}
        return null;
      }
      return (body['message'] ?? 'Đăng nhập thất bại').toString();
    } catch (e) {
      return 'Lỗi kết nối: $e';
    }
  }
}
