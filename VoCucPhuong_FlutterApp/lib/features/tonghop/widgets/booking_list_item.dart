import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/formatters.dart';
import '../../../models/booking.dart';

class BookingListItem extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCallPhone;
  final VoidCallback? onShare;
  final VoidCallback? onTap;

  const BookingListItem({
    super.key,
    required this.booking,
    this.onCallPhone,
    this.onShare,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cancelled = booking.isCancelled;
    final textStyle = TextStyle(
      decoration: cancelled ? TextDecoration.lineThrough : TextDecoration.none,
      color: cancelled ? AppColors.cancelled : AppColors.dark,
      fontWeight: FontWeight.w600,
    );
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        onTap: onTap,
        onLongPress: onShare,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cancelled
                      ? AppColors.cancelled.withAlpha(60)
                      : AppColors.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  booking.seatNumber.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cancelled ? AppColors.cancelled : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.name, style: textStyle),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.phone} • ${booking.timeSlot} • ${booking.route}',
                      style: TextStyle(
                          color: cancelled
                              ? AppColors.cancelled
                              : Colors.grey,
                          fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (booking.dropoffAddress.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Xuống: ${booking.dropoffAddress}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      formatVND(booking.amount),
                      style: TextStyle(
                          color: cancelled
                              ? AppColors.cancelled
                              : AppColors.accent,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, color: AppColors.accent),
                tooltip: 'Gọi khách',
                onPressed: cancelled ? null : onCallPhone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
