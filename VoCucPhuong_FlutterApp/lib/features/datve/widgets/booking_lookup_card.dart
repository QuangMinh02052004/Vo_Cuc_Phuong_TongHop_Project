import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/formatters.dart';

class BookingLookupCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onCall;
  final VoidCallback? onShare;

  const BookingLookupCard({
    super.key,
    required this.data,
    this.onCall,
    this.onShare,
  });

  String _s(String key) => (data[key] ?? '').toString();

  @override
  Widget build(BuildContext context) {
    final status = _s('status');
    final cancelled = status == 'cancelled' || status == 'canceled';
    final amount = num.tryParse(_s('totalPrice')) ??
        num.tryParse(_s('amount')) ??
        num.tryParse(_s('totalAmount')) ??
        0;
    final code = _s('bookingCode').isNotEmpty
        ? _s('bookingCode')
        : (_s('code').isNotEmpty ? _s('code') : _s('id'));
    final route = _s('routeName').isNotEmpty
        ? _s('routeName')
        : '${_s('from')} → ${_s('to')}';
    final seats = data['seats'] ?? data['selectedSeats'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(code,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6)),
                ),
                const Spacer(),
                Chip(
                  label: Text(status.isEmpty ? 'pending' : status),
                  backgroundColor: cancelled
                      ? AppColors.cancelled
                      : AppColors.accent.withAlpha(60),
                  labelStyle: TextStyle(
                      color: cancelled ? Colors.white : AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _row(Icons.directions_bus_outlined, 'Tuyến', route),
            _row(Icons.event_outlined, 'Ngày',
                '${_s('date')} • ${_s('departureTime')}'),
            _row(Icons.event_seat_outlined, 'Ghế',
                seats == null ? '-' : seats.toString()),
            _row(Icons.person_outline, 'Khách',
                '${_s('customerName')} • ${_s('customerPhone')}'),
            if (_s('pickupAddress').isNotEmpty)
              _row(Icons.location_on_outlined, 'Đón',
                  _s('pickupAddress')),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.payments_outlined,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                const Text('Tổng tiền',
                    style:
                        TextStyle(color: Colors.grey, fontSize: 13)),
                const Spacer(),
                Text(formatVND(amount),
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone),
                  label: const Text('Gọi khách'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('Chia sẻ vé'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.dark,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
