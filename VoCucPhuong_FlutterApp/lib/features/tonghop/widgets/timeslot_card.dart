import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../models/time_slot.dart';

class TimeSlotCard extends StatelessWidget {
  final TimeSlot slot;
  final int bookedCount;
  final int totalSeats;
  final VoidCallback onTap;

  const TimeSlotCard({
    super.key,
    required this.slot,
    required this.bookedCount,
    this.totalSeats = 28,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = totalSeats == 0 ? 0.0 : bookedCount / totalSeats;
    final color = ratio >= 0.9
        ? AppColors.secondary
        : (ratio >= 0.6 ? AppColors.orange : AppColors.accent);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.orange.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  slot.time,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(slot.route,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark)),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (slot.type.isNotEmpty) slot.type,
                        if (slot.driver != null && slot.driver!.isNotEmpty)
                          'Tài xế: ${slot.driver}',
                      ].join(' • '),
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: ratio.clamp(0, 1).toDouble(),
                      backgroundColor: Colors.grey.shade200,
                      color: color,
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$bookedCount/$totalSeats',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: color)),
                  const Text('ghế',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
