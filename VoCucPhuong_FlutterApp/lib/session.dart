import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String LOGIN_URL = 'https://vocucphuongmanage.vercel.app/api/nhap-hang/auth/login';

class Session {
  static const String _kRole = 'role';
  static const String _kUsername = 'username';
  static const String _kFullName = 'fullName';
  static const String _kToken = 'token';

  static String? role;
  static String? username;
  static String? fullName;
  static String? token;

  static bool get isLoggedIn => role != null && role != 'customer';
  static bool get isCustomer => role == null || role == 'customer';
  static bool get isAdmin => role == 'admin';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    role = prefs.getString(_kRole);
    username = prefs.getString(_kUsername);
    fullName = prefs.getString(_kFullName);
    token = prefs.getString(_kToken);
  }

  static Future<void> saveCustomerMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRole, 'customer');
    role = 'customer';
    username = null;
    fullName = null;
    token = null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRole);
    await prefs.remove(_kUsername);
    await prefs.remove(_kFullName);
    await prefs.remove(_kToken);
    role = null;
    username = null;
    fullName = null;
    token = null;
  }

  /// Returns null if login OK, or error message string.
  static Future<String?> login(String u, String p) async {
    try {
      final res = await http.post(
        Uri.parse(LOGIN_URL),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': u, 'password': p}),
      ).timeout(const Duration(seconds: 15));

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        final user = body['user'] ?? {};
        final prefs = await SharedPreferences.getInstance();
        role = (user['role'] ?? 'staff').toString();
        username = (user['username'] ?? u).toString();
        fullName = (user['fullName'] ?? user['username'] ?? u).toString();
        token = (body['token'] ?? '').toString();
        await prefs.setString(_kRole, role!);
        await prefs.setString(_kUsername, username!);
        await prefs.setString(_kFullName, fullName!);
        await prefs.setString(_kToken, token!);
        return null;
      } else {
        return (body['message'] ?? 'Đăng nhập thất bại').toString();
      }
    } catch (e) {
      return 'Lỗi kết nối: $e';
    }
  }
}
