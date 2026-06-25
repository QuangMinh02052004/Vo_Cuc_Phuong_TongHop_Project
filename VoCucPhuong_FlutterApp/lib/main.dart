import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme.dart';
import 'core/notification_service.dart';
import 'core/widgets/offline_banner.dart';
import 'session.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/module_selector_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/datve/datve_tab.dart';
import 'features/nhaphang/nhaphang_tab.dart';
import 'features/tonghop/tonghop_tab.dart';

/// Guard: nếu vào /tonghop hoặc /nhaphang mà module chưa login → đẩy về `/login/<module>`.
Future<String?> _moduleGuard(String moduleKey) async {
  final s = ModuleSession(moduleKey);
  await s.load();
  if (!s.isLoggedIn) return '/login/$moduleKey';
  return null;
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/home', builder: (_, __) => const ModuleSelectorScreen()),
    GoRoute(
      path: '/login/:module',
      builder: (_, state) => LoginScreen(
        moduleKey: state.pathParameters['module'] ?? 'tonghop',
      ),
    ),
    GoRoute(path: '/datve', builder: (_, __) => const DatVeHomeScreen()),
    GoRoute(
      path: '/nhaphang',
      redirect: (_, __) => _moduleGuard('nhaphang'),
      builder: (_, __) => const NhapHangHomeScreen(),
    ),
    GoRoute(
      path: '/tonghop',
      redirect: (_, __) => _moduleGuard('tonghop'),
      builder: (_, __) => const TongHopHomeScreen(),
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ModuleSession.initStorage();
  await NotificationService.instance.init();
  NotificationService.instance.onTap = (payload) {
    // booking:<id> hoặc product:<id> — đẩy về module liên quan.
    if (payload.startsWith('booking:')) {
      _router.go('/tonghop');
    } else if (payload.startsWith('product:')) {
      _router.go('/nhaphang');
    }
  };
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ProviderScope(child: VoCucPhuongApp()));
}

class VoCucPhuongApp extends StatelessWidget {
  const VoCucPhuongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Võ Cúc Phương',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
      builder: (context, child) =>
          OfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
