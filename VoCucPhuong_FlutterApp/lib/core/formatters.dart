import 'package:intl/intl.dart';

final NumberFormat _vnd = NumberFormat.decimalPattern('vi_VN');
final DateFormat _dateVN = DateFormat('dd/MM/yyyy');
final DateFormat _dateTimeVN = DateFormat('dd/MM/yyyy HH:mm');

String formatVND(num? amount) {
  if (amount == null) return '0';
  return '${_vnd.format(amount)} đ';
}

String formatVNDPlain(num? amount) {
  if (amount == null) return '0';
  return _vnd.format(amount);
}

num parseVND(String text) {
  final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.isEmpty) return 0;
  return num.tryParse(cleaned) ?? 0;
}

String formatDate(DateTime? d) {
  if (d == null) return '';
  return _dateVN.format(d);
}

String formatDateTime(DateTime? d) {
  if (d == null) return '';
  return _dateTimeVN.format(d);
}

DateTime? tryParseDate(String? s) {
  if (s == null || s.isEmpty) return null;
  return DateTime.tryParse(s);
}
