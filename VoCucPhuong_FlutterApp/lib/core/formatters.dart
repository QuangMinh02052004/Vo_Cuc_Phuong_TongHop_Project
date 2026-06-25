import 'package:flutter/services.dart';
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

String formatDateApi(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// TextInputFormatter cho ô tiền VND: gõ 1000000 -> hiển thị 1.000.000.
class VNDInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final n = int.tryParse(digits) ?? 0;
    final formatted = _vnd.format(n);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
