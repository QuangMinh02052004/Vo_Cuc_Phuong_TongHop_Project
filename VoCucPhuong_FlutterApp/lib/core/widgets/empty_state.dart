import 'package:flutter/material.dart';
import '../constants.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const EmptyState({
    super.key,
    this.message = 'Chưa có dữ liệu',
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Opacity(
                opacity: 0.55,
                child: Image.asset('assets/logo.png',
                    width: 72, height: 72, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            if (icon != null) ...[
              Icon(icon, size: 32, color: Colors.grey),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
