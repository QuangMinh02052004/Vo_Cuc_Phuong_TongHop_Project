import 'package:flutter/material.dart';
import '../../../core/constants.dart';

/// SeatMap 28 ghế = 2 cột x 14 hàng + ô tài xế ở góc trên trái.
class SeatMap extends StatelessWidget {
  final List<int> usedSeats;
  final int? selectedSeat;
  final void Function(int seat) onTap;

  const SeatMap({
    super.key,
    required this.usedSeats,
    required this.onTap,
    this.selectedSeat,
  });

  static const int kTotal = 28;

  @override
  Widget build(BuildContext context) {
    final used = usedSeats.toSet();
    final rows = <Widget>[];
    rows.add(Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _DriverBox(),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Cửa lên',
                style: TextStyle(fontSize: 11, color: AppColors.dark)),
          ),
        ],
      ),
    ));

    for (int r = 0; r < 14; r++) {
      final left = r * 2 + 1;
      final right = left + 1;
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: _seat(left, used)),
            const SizedBox(width: 36),
            Expanded(child: _seat(right, used)),
          ],
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...rows,
        const SizedBox(height: 16),
        const _Legend(),
      ],
    );
  }

  Widget _seat(int n, Set<int> used) {
    final isUsed = used.contains(n);
    final isSelected = selectedSeat == n;
    final bg = isSelected
        ? AppColors.primary
        : (isUsed ? AppColors.orange : Colors.white);
    final fg = (isSelected || isUsed) ? Colors.white : AppColors.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: isUsed ? null : () => onTap(n),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isUsed
                  ? AppColors.orange
                  : (isSelected ? AppColors.primary : Colors.grey.shade300),
              width: 1.4),
        ),
        alignment: Alignment.center,
        child: Text(
          n.toString().padLeft(2, '0'),
          style: TextStyle(
              fontWeight: FontWeight.bold, color: fg, fontSize: 14),
        ),
      ),
    );
  }
}

class _DriverBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.airline_seat_recline_normal,
              size: 16, color: Colors.white),
          SizedBox(width: 6),
          Text('Tài xế',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();
  @override
  Widget build(BuildContext context) {
    Widget item(Color c, String label, {bool border = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: c,
                border: border
                    ? Border.all(color: Colors.grey.shade400)
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        item(Colors.white, 'Trống', border: true),
        item(AppColors.orange, 'Đã đặt'),
        item(AppColors.primary, 'Đang chọn'),
      ],
    );
  }
}
