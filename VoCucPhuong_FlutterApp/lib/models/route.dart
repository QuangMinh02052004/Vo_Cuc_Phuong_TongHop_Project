class BusRoute {
  final dynamic id;
  final String name;
  final String routeType; // quoc_lo | cao_toc
  final String fromStation;
  final String toStation;
  final num price;
  final String duration;
  final String busType;
  final int seats;
  final String operatingStart;
  final String operatingEnd;
  final int intervalMinutes;
  final bool isActive;

  BusRoute({
    required this.id,
    required this.name,
    this.routeType = 'quoc_lo',
    this.fromStation = '',
    this.toStation = '',
    this.price = 0,
    this.duration = '',
    this.busType = 'Ghế ngồi',
    this.seats = 28,
    this.operatingStart = '05:30',
    this.operatingEnd = '20:00',
    this.intervalMinutes = 30,
    this.isActive = true,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    num _n(v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;
    return BusRoute(
      id: json['id'],
      name: (json['name'] ?? '').toString(),
      routeType: (json['routeType'] ?? 'quoc_lo').toString(),
      fromStation: (json['fromStation'] ?? json['from'] ?? '').toString(),
      toStation: (json['toStation'] ?? json['to'] ?? '').toString(),
      price: _n(json['price']),
      duration: (json['duration'] ?? '').toString(),
      busType: (json['busType'] ?? 'Ghế ngồi').toString(),
      seats: _n(json['seats']).toInt() == 0 ? 28 : _n(json['seats']).toInt(),
      operatingStart: (json['operatingStart'] ?? '05:30').toString(),
      operatingEnd: (json['operatingEnd'] ?? '20:00').toString(),
      intervalMinutes: _n(json['intervalMinutes']).toInt() == 0
          ? 30
          : _n(json['intervalMinutes']).toInt(),
      isActive: json['isActive'] != false,
    );
  }
}
