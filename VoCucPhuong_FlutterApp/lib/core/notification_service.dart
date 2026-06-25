import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// NotificationService — local notification cho các sự kiện thành công
/// (đặt vé / tạo đơn). Không gửi qua server, không cần Firebase.
///
/// Gọi [init] 1 lần ở `main()` trước [runApp].
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'vcp_booking';
  static const String _channelName = 'Thông báo đặt vé / tạo đơn';
  static const String _channelDesc =
      'Báo khi đặt vé hoặc tạo đơn hàng thành công';

  bool _ready = false;
  void Function(String payload)? onTap;

  Future<void> init() async {
    if (_ready) return;

    // Android dùng @mipmap/ic_launcher làm icon (tránh phải tạo
    // monochrome drawable). Nếu sau này có ic_notification riêng, đổi
    // chuỗi dưới thành '@drawable/ic_notification'.
    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        final p = resp.payload;
        if (p != null && p.isNotEmpty) onTap?.call(p);
      },
    );

    // Tạo channel sẵn cho Android 8+.
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
      ),
    );

    // Yêu cầu quyền notification (Android 13+ / iOS).
    await androidImpl?.requestNotificationsPermission();

    _ready = true;
  }

  /// Hiện 1 notification ngay lập tức.
  Future<void> showBookingSuccess({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_ready) {
      try {
        await init();
      } catch (_) {
        return;
      }
    }
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        ticker: 'Võ Cúc Phương',
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    try {
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (_) {
      // Không chặn flow nghiệp vụ vì notification.
    }
  }
}
