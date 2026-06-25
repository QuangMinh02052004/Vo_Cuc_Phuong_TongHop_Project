import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../../core/formatters.dart';
import '../../../models/booking.dart';
import '../../../models/time_slot.dart';

/// BottomSheet tạo nhanh 1 booking cho 1 ghế / 1 timeslot.
/// Trả về Booking đã điền (chưa POST) hoặc null nếu hủy.
class BookingFormSheet extends StatefulWidget {
  final TimeSlot slot;
  final int seatNumber;
  final num suggestedPrice;

  const BookingFormSheet({
    super.key,
    required this.slot,
    required this.seatNumber,
    this.suggestedPrice = 0,
  });

  @override
  State<BookingFormSheet> createState() => _BookingFormSheetState();
}

class _BookingFormSheetState extends State<BookingFormSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _dropoff = TextEditingController();
  final _note = TextEditingController();
  late final TextEditingController _amount;
  late final TextEditingController _paid;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
        text: widget.suggestedPrice > 0 ? formatVNDPlain(widget.suggestedPrice) : '');
    _paid = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _dropoff.dispose();
    _note.dispose();
    _amount.dispose();
    _paid.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final b = Booking(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      seatNumber: widget.seatNumber,
      timeSlotId: widget.slot.id,
      timeSlot: widget.slot.time,
      date: widget.slot.date,
      route: widget.slot.route,
      dropoffMethod: _dropoff.text.trim().isEmpty ? '' : 'address',
      dropoffAddress: _dropoff.text.trim(),
      note: _note.text.trim(),
      amount: parseVND(_amount.text),
      paid: parseVND(_paid.text),
    );
    Navigator.of(context).pop(b);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Form(
              key: _form,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Ghế ${widget.seatNumber.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${widget.slot.time} • ${widget.slot.route}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: 'Họ tên khách',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nhập họ tên' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return 'Nhập số điện thoại';
                      if (t.length < 9) return 'SĐT không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dropoff,
                    decoration: const InputDecoration(
                      labelText: 'Điểm xuống / địa chỉ trả',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amount,
                          keyboardType: TextInputType.number,
                          inputFormatters: [VNDInputFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Tiền vé',
                            suffixText: 'đ',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _paid,
                          keyboardType: TextInputType.number,
                          inputFormatters: [VNDInputFormatter()],
                          decoration: const InputDecoration(
                            labelText: 'Đã trả',
                            suffixText: 'đ',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _note,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.check),
                          label: const Text('Lưu vé'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
