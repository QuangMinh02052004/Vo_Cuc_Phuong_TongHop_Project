import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';

class DatVeHomeScreen extends StatelessWidget {
  const DatVeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Đổi module',
          onPressed: () => context.go('/home'),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('assets/logo.png',
                  width: 28, height: 28, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            const Text('Đặt Vé Xe Khách'),
          ],
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_number_outlined,
                  size: 72, color: AppColors.primary),
              SizedBox(height: 16),
              Text('Đặt vé online',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                'Màn hình native sẽ có trong Phase 2',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
