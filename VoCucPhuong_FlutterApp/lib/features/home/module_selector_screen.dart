import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../session.dart';

/// Màn home sau splash — chọn module để vào (mỗi module login riêng).
class ModuleSelectorScreen extends StatefulWidget {
  const ModuleSelectorScreen({super.key});

  @override
  State<ModuleSelectorScreen> createState() => _ModuleSelectorScreenState();
}

class _ModuleSelectorScreenState extends State<ModuleSelectorScreen> {
  final _sessions = {
    'datve': ModuleSession('datve'),
    'nhaphang': ModuleSession('nhaphang'),
    'tonghop': ModuleSession('tonghop'),
  };

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    for (final s in _sessions.values) {
      await s.load();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _openModule(String key) {
    final s = _sessions[key]!;
    // DatVe Phase 1.5 chưa có auth — vào thẳng.
    if (key == 'datve') {
      context.go('/datve');
      return;
    }
    if (s.isLoggedIn) {
      context.go('/$key');
    } else {
      context.push('/login/$key').then((_) => _reload());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/logo.png',
                        width: 44, height: 44, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VÕ CÚC PHƯƠNG',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AppColors.dark)),
                        SizedBox(height: 2),
                        Text('Nền tảng quản lý nhà xe',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              const Text('Chọn module để tiếp tục',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark)),
              const SizedBox(height: 14),
              _ModuleCard(
                title: 'Đặt Vé',
                subtitle: _subtitleFor('datve'),
                icon: Icons.confirmation_number_rounded,
                colors: const [AppColors.primary, AppColors.primaryDark],
                loading: _loading,
                onTap: () => _openModule('datve'),
              ),
              const SizedBox(height: 14),
              _ModuleCard(
                title: 'Nhập Hàng',
                subtitle: _subtitleFor('nhaphang'),
                icon: Icons.inventory_2_rounded,
                colors: const [Color(0xFF22C55E), Color(0xFF15803D)],
                loading: _loading,
                onTap: () => _openModule('nhaphang'),
              ),
              const SizedBox(height: 14),
              _ModuleCard(
                title: 'Tổng Hợp',
                subtitle: _subtitleFor('tonghop'),
                icon: Icons.directions_bus_rounded,
                colors: const [Color(0xFFF59E0B), Color(0xFFB45309)],
                loading: _loading,
                onTap: () => _openModule('tonghop'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitleFor(String key) {
    if (key == 'datve') return 'Vào thẳng — không cần đăng nhập';
    final s = _sessions[key]!;
    if (s.isLoggedIn) {
      final who = s.fullName ?? s.username ?? '';
      return who.isEmpty ? 'Đã đăng nhập' : 'Đã đăng nhập: $who';
    }
    return 'Đăng nhập để tiếp tục';
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final bool loading;
  final VoidCallback onTap;
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: loading ? null : onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors.first.withAlpha(60),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.white.withAlpha(220), fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
