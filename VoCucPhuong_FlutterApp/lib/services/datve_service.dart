import '../core/api_client.dart';
import '../core/constants.dart';
import '../models/route.dart';

class DatVeService {
  final ApiClient _api = ApiClient.instance;

  Future<List<BusRoute>> listRoutes() async {
    final res = await _api.get('${ApiUrls.datVeApi}/routes');
    if (res is! List) return [];
    return res
        .map((e) => BusRoute.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> createBooking({
    required String routeId,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    required String date,
    required String departureTime,
    required int seats,
    List<int>? selectedSeats,
    String? pickupMethod,
    String? pickupAddress,
  }) async {
    final body = <String, dynamic>{
      'routeId': routeId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      if (customerEmail != null && customerEmail.isNotEmpty)
        'customerEmail': customerEmail,
      'date': date,
      'departureTime': departureTime,
      'seats': seats,
      if (selectedSeats != null) 'selectedSeats': selectedSeats,
      if (pickupMethod != null) 'pickupMethod': pickupMethod,
      if (pickupAddress != null) 'pickupAddress': pickupAddress,
    };
    final res = await _api.post('${ApiUrls.datVeApi}/bookings/create', body: body);
    return Map<String, dynamic>.from(res);
  }

  Future<Map<String, dynamic>> getBooking(String code) async {
    final res = await _api.get('${ApiUrls.datVeApi}/bookings/$code');
    return Map<String, dynamic>.from(res);
  }
}
