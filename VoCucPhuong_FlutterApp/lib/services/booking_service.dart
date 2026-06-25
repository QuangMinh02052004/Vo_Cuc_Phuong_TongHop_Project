import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/notification_service.dart';
import '../models/booking.dart';
import '../models/route.dart';
import '../models/time_slot.dart';
import '../session.dart';

class BookingService {
  final ApiClient _api = ApiClient.instance;
  final ModuleSession _session;

  /// TongHop module session — chứa JWT đăng nhập của nhân viên quầy.
  BookingService([ModuleSession? session])
      : _session = session ?? ModuleSession('tonghop');

  String? get _tok => _session.token;

  Future<List<Booking>> listBookings({
    String? date,
    String? route,
    String? search,
    String? since,
  }) async {
    final q = <String, dynamic>{};
    if (date != null) q['date'] = date;
    if (route != null) q['route'] = route;
    if (search != null && search.isNotEmpty) q['search'] = search;
    if (since != null && since.isNotEmpty) q['since'] = since;

    final res = await _api.get('${ApiUrls.tongHopApi}/bookings',
        query: q, token: _tok);
    final list = res is List ? res : (res is Map ? (res['bookings'] ?? []) : []);
    return (list as List)
        .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Booking> createBooking(Booking b) async {
    final res = await _api.post('${ApiUrls.tongHopApi}/bookings',
        body: b.toCreateJson(), token: _tok);
    final created = Booking.fromJson(Map<String, dynamic>.from(res));
    // Thông báo local — fire-and-forget.
    NotificationService.instance.showBookingSuccess(
      title: 'Đặt vé thành công',
      body: 'Mã vé: ${created.id} — ${created.name}'.trim(),
      payload: 'booking:${created.id}',
    );
    return created;
  }

  Future<Booking> updateBooking(int id, Map<String, dynamic> patch) async {
    final res = await _api.patch('${ApiUrls.tongHopApi}/bookings/$id',
        body: patch, token: _tok);
    return Booking.fromJson(Map<String, dynamic>.from(res));
  }

  Future<void> cancelBooking(int id, {String? reason}) async {
    await _api.delete('${ApiUrls.tongHopApi}/bookings/$id',
        body: {'cancelNote': reason ?? ''}, token: _tok);
  }

  Future<List<BusRoute>> listRoutes() async {
    final res = await _api.get('${ApiUrls.tongHopApi}/routes', token: _tok);
    if (res is! List) return [];
    return res
        .map((e) => BusRoute.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<TimeSlot>> listTimeSlots({
    required String date,
    required String route,
  }) async {
    final res = await _api.get('${ApiUrls.tongHopApi}/timeslots',
        query: {'date': date, 'route': route}, token: _tok);
    final list = res is List
        ? res
        : (res is Map ? (res['timeSlots'] ?? res['data'] ?? []) : []);
    return (list as List)
        .map((e) => TimeSlot.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
