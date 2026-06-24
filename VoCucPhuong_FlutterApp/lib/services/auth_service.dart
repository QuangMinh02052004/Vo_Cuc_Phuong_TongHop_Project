import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../session.dart';

/// Mỗi module 1 realm + 1 ModuleSession riêng.
enum LoginRealm { nhapHang, tongHop }

String moduleKeyOf(LoginRealm r) =>
    r == LoginRealm.tongHop ? 'tonghop' : 'nhaphang';

class AuthService {
  final ApiClient _api = ApiClient.instance;

  /// Đăng nhập module được chỉ định và lưu vào ModuleSession tương ứng.
  Future<AppUser> login({
    required String username,
    required String password,
    LoginRealm realm = LoginRealm.nhapHang,
  }) async {
    final url = realm == LoginRealm.tongHop
        ? '${ApiUrls.tongHopApi}/auth/login'
        : '${ApiUrls.nhapHangApi}/auth/login';

    final res = await _api.post(url, body: {
      'username': username,
      'password': password,
    });

    if (res is! Map || res['success'] != true) {
      throw ApiException(
          (res is Map ? (res['message'] ?? res['error']) : 'Đăng nhập thất bại')
              .toString());
    }

    final user = AppUser.fromJson(Map<String, dynamic>.from(res['user'] ?? {}));
    final token = (res['token'] ?? '').toString();

    final s = ModuleSession(moduleKeyOf(realm));
    await s.saveLogin(
      role: user.role,
      username: user.username,
      fullName: user.fullName,
      token: token,
    );
    return user;
  }

  Future<void> logoutModule(String moduleKey) =>
      ModuleSession(moduleKey).logout();
}
