import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/formatters.dart';
import '../../../models/route.dart';

class RouteCard extends StatelessWidget {
  final BusRoute route;
  const RouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
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
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    route.routeType == 'cao_toc' ? 'Cao tốc' : 'Quốc lộ',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                const Spacer(),
                Text(formatVND(route.price),
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Text(route.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.dark)),
            const SizedBox(height: 4),
            Text('${route.fromStation} → ${route.toStation}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${route.operatingStart} - ${route.operatingEnd}',
                  style: const TextStyle(
                      color: AppColors.dark, fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.airline_seat_recline_normal,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${route.seats} chỗ',
                    style: const TextStyle(
                        color: AppColors.dark, fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(route.duration.isEmpty ? '-' : route.duration,
                    style: const TextStyle(
                        color: AppColors.dark, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
