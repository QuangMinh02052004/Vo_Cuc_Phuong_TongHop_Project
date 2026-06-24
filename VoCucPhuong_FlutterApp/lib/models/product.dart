class Product {
  final String id;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String fromStation;
  final String toStation;
  final String productName;
  final num totalAmount;
  final num deliveredAmount;
  final String? status;
  final String? note;
  final DateTime? sendDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.fromStation,
    required this.toStation,
    required this.productName,
    this.totalAmount = 0,
    this.deliveredAmount = 0,
    this.status,
    this.note,
    this.sendDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    num _n(v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;
    return Product(
      id: (json['id'] ?? '').toString(),
      senderName: (json['senderName'] ?? '').toString(),
      senderPhone: (json['senderPhone'] ?? '').toString(),
      receiverName: (json['receiverName'] ?? '').toString(),
      receiverPhone: (json['receiverPhone'] ?? '').toString(),
      fromStation: (json['fromStation'] ?? '').toString(),
      toStation: (json['toStation'] ?? '').toString(),
      productName: (json['productName'] ?? json['name'] ?? '').toString(),
      totalAmount: _n(json['totalAmount']),
      deliveredAmount: _n(json['deliveredAmount']),
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      sendDate: DateTime.tryParse(json['sendDate']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
    );
  }

  bool get isCancelled => status == 'cancelled';
}
