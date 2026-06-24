import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../session.dart';

class TongHopHomeScreen extends StatefulWidget {
  const TongHopHomeScreen({super.key});

  @override
  State<TongHopHomeScreen> createState() => _TongHopHomeScreenState();
}

class _TongHopHomeScreenState extends State<TongHopHomeScreen> {
  final _session = ModuleSession('tonghop');

  @override
  void initState() {
    super.initState();
    _session.load().then((_) => mounted ? setState(() {}) : null);
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Đăng xuất Tổng Hợp?'),
        content: Text(
            'Đăng xuất khỏi tài khoản ${_session.username ?? ""}? Bạn sẽ về màn chọn module.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Hủy')),
          ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (ok != true) return;
    await _session.logout();
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.orange,
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
            const Text('Quản Lý Xe Khách'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_bus_outlined,
                  size: 72, color: AppColors.orange),
              const SizedBox(height: 16),
              const Text('Tổng hợp',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  _session.fullName != null
                      ? 'Xin chào ${_session.fullName}'
                      : '',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              const Text(
                'Màn hình native sẽ có trong Phase 2 (sơ đồ ghế, đặt vé tại quầy)',
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
