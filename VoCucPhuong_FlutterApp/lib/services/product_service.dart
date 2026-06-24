import '../core/api_client.dart';
import '../core/constants.dart';
import '../core/notification_service.dart';
import '../models/product.dart';
import '../session.dart';

class Station {
  final int id;
  final String code;
  final String name;
  final String fullName;
  Station(
      {required this.id,
      required this.code,
      required this.name,
      required this.fullName});
  factory Station.fromJson(Map<String, dynamic> j) => Station(
        id: (j['id'] is int)
            ? j['id'] as int
            : int.tryParse(j['id']?.toString() ?? '') ?? 0,
        code: (j['code'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        fullName: (j['fullName'] ?? '').toString(),
      );
}

class ProductService {
  final ApiClient _api = ApiClient.instance;
  final ModuleSession _session;

  ProductService([ModuleSession? session])
      : _session = session ?? ModuleSession('nhaphang');

  String? get _tok => _session.token;

  Future<List<Product>> listProducts({String? date, String? status}) async {
    final q = <String, dynamic>{};
    if (date != null) q['date'] = date;
    if (status != null) q['status'] = status;
    final res = await _api.get('${ApiUrls.nhapHangApi}/products',
        query: q, token: _tok);
    final list = res is List
        ? res
        : (res is Map ? (res['data'] ?? res['products'] ?? []) : []);
    return (list as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Product> getProduct(String id) async {
    final res =
        await _api.get('${ApiUrls.nhapHangApi}/products/$id', token: _tok);
    final data = res is Map && res['data'] != null ? res['data'] : res;
    return Product.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Product> createProduct(Map<String, dynamic> body) async {
    final res = await _api.post('${ApiUrls.nhapHangApi}/products',
        body: body, token: _tok);
    final data = res is Map && res['data'] != null ? res['data'] : res;
    final p = Product.fromJson(Map<String, dynamic>.from(data));
    NotificationService.instance.showBookingSuccess(
      title: 'Tạo đơn hàng thành công',
      body: 'Mã đơn: ${p.id}',
      payload: 'product:${p.id}',
    );
    return p;
  }

  Future<void> cancelProduct(String id,
      {String? cancelNote, String? changedBy}) async {
    await _api.delete('${ApiUrls.nhapHangApi}/products/$id', body: {
      'cancelNote': cancelNote ?? '',
      if (changedBy != null) 'changedBy': changedBy,
    }, token: _tok);
  }

  Future<List<Station>> listStations() async {
    final res =
        await _api.get('${ApiUrls.nhapHangApi}/stations', token: _tok);
    final list = res is Map ? (res['data'] ?? []) : (res is List ? res : []);
    return (list as List)
        .map((e) => Station.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<int> peekCounter(String stationCode) async {
    final res = await _api.get('${ApiUrls.nhapHangApi}/counters',
        query: {'station': stationCode}, token: _tok);
    final v = res is Map ? res['value'] : null;
    return v is int ? v : int.tryParse(v?.toString() ?? '0') ?? 0;
  }
}
