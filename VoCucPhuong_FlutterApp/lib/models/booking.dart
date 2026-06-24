class Booking {
  final int? id;
  final String name;
  final String phone;
  final int seatNumber;
  final int? timeSlotId;
  final String timeSlot;
  final String date;
  final String route;
  final String pickupMethod;
  final String pickupAddress;
  final String dropoffMethod;
  final String dropoffAddress;
  final String note;
  final num amount;
  final num paid;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    this.id,
    required this.name,
    required this.phone,
    required this.seatNumber,
    this.timeSlotId,
    required this.timeSlot,
    required this.date,
    required this.route,
    this.pickupMethod = '',
    this.pickupAddress = '',
    this.dropoffMethod = '',
    this.dropoffAddress = '',
    this.note = '',
    this.amount = 0,
    this.paid = 0,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    num _n(v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;
    return Booking(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      seatNumber: _n(json['seatNumber']).toInt(),
      timeSlotId: json['timeSlotId'] is int
          ? json['timeSlotId'] as int
          : int.tryParse(json['timeSlotId']?.toString() ?? ''),
      timeSlot: (json['timeSlot'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      route: (json['route'] ?? '').toString(),
      pickupMethod: (json['pickupMethod'] ?? '').toString(),
      pickupAddress: (json['pickupAddress'] ?? '').toString(),
      dropoffMethod: (json['dropoffMethod'] ?? '').toString(),
      dropoffAddress: (json['dropoffAddress'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
      amount: _n(json['amount']),
      paid: _n(json['paid']),
      status: json['status']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'name': name,
        'phone': phone,
        'seatNumber': seatNumber,
        'timeSlotId': timeSlotId,
        'timeSlot': timeSlot,
        'date': date,
        'route': route,
        'pickupMethod': pickupMethod,
        'pickupAddress': pickupAddress,
        'dropoffMethod': dropoffMethod,
        'dropoffAddress': dropoffAddress,
        'note': note,
        'amount': amount,
        'paid': paid,
      };

  bool get isCancelled => status == 'cancelled';
}
