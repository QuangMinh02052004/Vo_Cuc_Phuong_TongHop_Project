import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Conditional imports
import 'webview_mobile.dart' if (dart.library.html) 'webview_web.dart' as webview;

// Cấu hình URL - Thay đổi IP_ADDRESS thành IP máy tính của bạn
const String IP_ADDRESS = '10.150.150.1';
const String URL_DAT_VE = 'http://$IP_ADDRESS:3000';
const String URL_NHAP_HANG = 'http://$IP_ADDRESS:5001';
const String URL_QUAN_LY_XE = 'http://$IP_ADDRESS:3001';

// Brand Colors
class AppColors {
  static const Color primary = Color(0xFF0EA5E9); // Sky blue
  static const Color secondary = Color(0xFFE11D48); // Red
  static const Color accent = Color(0xFF22C55E); // Green
  static const Color orange = Color(0xFFF59E0B); // Orange
  static const Color dark = Color(0xFF1E293B); // Dark blue gray
  static const Color light = Color(0xFFF8FAFC); // Light gray
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Cho phép xoay ngang và dọc
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const VoCucPhuongApp());
}

class VoCucPhuongApp extends StatelessWidget {
  const VoCucPhuongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Võ Cúc Phương',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF0284C7)],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_bus_rounded,
                          size: 70,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'VÕ CÚC PHƯƠNG',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Dịch vụ vận tải hành khách',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 50),
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<NavItem> _navItems = [
    NavItem(
      title: 'Đặt Vé',
      icon: Icons.confirmation_number_outlined,
      activeIcon: Icons.confirmation_number,
      color: AppColors.primary,
      lightColor: const Color(0xFFE0F2FE),
      url: URL_DAT_VE,
      appBarTitle: 'Đặt Vé Xe Khách',
    ),
    NavItem(
      title: 'Nhập Hàng',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      color: AppColors.accent,
      lightColor: const Color(0xFFDCFCE7),
      url: URL_NHAP_HANG,
      appBarTitle: 'Quản Lý Hàng Hóa',
    ),
    NavItem(
      title: 'Tổng Hợp',
      icon: Icons.directions_bus_outlined,
      activeIcon: Icons.directions_bus,
      color: AppColors.orange,
      lightColor: const Color(0xFFFEF3C7),
      url: URL_QUAN_LY_XE,
      appBarTitle: 'Quản Lý Xe Khách',
    ),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navItems
            .map((item) => WebViewScreen(
                  title: item.appBarTitle,
                  url: item.url,
                  color: item.color,
                  showAppBar: !isLandscape, // Ẩn app bar khi landscape
                ))
            .toList(),
      ),
      bottomNavigationBar: _buildBottomNav(isLandscape, bottomPadding),
    );
  }

  Widget _buildBottomNav(bool isLandscape, double bottomPadding) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          // Nhỏ gọn hơn khi landscape
          height: isLandscape ? 50 : 65,
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 16 : 8,
            vertical: isLandscape ? 4 : 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _onNavTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? (isLandscape ? 12 : 16) : 8,
                      vertical: isLandscape ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? item.lightColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(isLandscape ? 10 : 15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? item.color : Colors.grey,
                          size: isLandscape ? 20 : 24,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: isLandscape ? 4 : 8),
                          Flexible(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: item.color,
                                fontWeight: FontWeight.w600,
                                fontSize: isLandscape ? 11 : 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Navigation Item Model
class NavItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final Color color;
  final Color lightColor;
  final String url;
  final String appBarTitle;

  NavItem({
    required this.title,
    required this.icon,
    required this.activeIcon,
    required this.color,
    required this.lightColor,
    required this.url,
    required this.appBarTitle,
  });
}

// WebView Screen
class WebViewScreen extends StatelessWidget {
  final String title;
  final String url;
  final Color color;
  final bool showAppBar;

  const WebViewScreen({
    super.key,
    required this.title,
    required this.url,
    required this.color,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAppBar) {
      // Landscape mode - fullscreen WebView
      return SafeArea(
        child: webview.WebViewWidget(url: url, color: color, title: title),
      );
    }

    // Portrait mode - with app bar
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        backgroundColor: color,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withAlpha(204)],
            ),
          ),
        ),
      ),
      body: webview.WebViewWidget(url: url, color: color, title: title),
    );
  }
}
