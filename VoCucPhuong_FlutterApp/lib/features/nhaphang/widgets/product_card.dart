import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/formatters.dart';
import '../../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onCallReceiver;
  final VoidCallback? onShare;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onCallReceiver,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final cancelled = product.isCancelled;
    final color = cancelled ? AppColors.cancelled : AppColors.accent;
    final style = TextStyle(
      decoration:
          cancelled ? TextDecoration.lineThrough : TextDecoration.none,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(product.id,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  const Spacer(),
                  Text(formatVND(product.totalAmount),
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Text(product.productName.isEmpty ? '(Không tên)' : product.productName,
                  style: style),
              const SizedBox(height: 2),
              Text(
                '${product.fromStation} → ${product.toStation}',
                style: TextStyle(
                    color: cancelled ? AppColors.cancelled : Colors.grey,
                    fontSize: 12),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${product.receiverName} • ${product.receiverPhone}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.dark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone,
                        color: AppColors.accent, size: 20),
                    tooltip: 'Gọi người nhận',
                    onPressed: cancelled ? null : onCallReceiver,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
