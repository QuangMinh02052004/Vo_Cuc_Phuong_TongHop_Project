import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'webview_mobile.dart' if (dart.library.html) 'webview_web.dart' as webview;

const String URL_DAT_VE = 'https://vocucphuong.vercel.app';

class AppColors {
  static const Color primary = Color(0xFF0EA5E9);
  static const Color dark = Color(0xFF0284C7);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const VCPDatVeApp());
}

class VCPDatVeApp extends StatelessWidget {
  const VCPDatVeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Võ Cúc Phương - Đặt Vé',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.6, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingScreen()));
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
            colors: [AppColors.primary, AppColors.dark],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(60),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset('assets/logo.png', width: 120, height: 120, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Võ Cúc Phương',
                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Đặt Vé Xe Khách',
                      style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      appBar: isLandscape
          ? null
          : AppBar(
              title: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.directions_bus, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Võ Cúc Phương',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              centerTitle: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.dark],
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: webview.WebViewWidget(
          url: URL_DAT_VE,
          color: AppColors.primary,
          title: 'Đặt Vé',
        ),
      ),
    );
  }
}
