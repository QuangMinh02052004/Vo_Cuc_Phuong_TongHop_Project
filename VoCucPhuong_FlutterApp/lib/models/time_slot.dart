class TimeSlot {
  final int? id;
  final String time;
  final String date;
  final String route;
  final String type;
  final String? code;
  final String? driver;
  final String? phone;

  TimeSlot({
    this.id,
    required this.time,
    required this.date,
    required this.route,
    this.type = '',
    this.code,
    this.driver,
    this.phone,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id']?.toString() ?? ''),
        time: (json['time'] ?? '').toString(),
        date: (json['date'] ?? '').toString(),
        route: (json['route'] ?? '').toString(),
        type: (json['type'] ?? '').toString(),
        code: json['code']?.toString(),
        driver: json['driver']?.toString(),
        phone: json['phone']?.toString(),
      );
}
