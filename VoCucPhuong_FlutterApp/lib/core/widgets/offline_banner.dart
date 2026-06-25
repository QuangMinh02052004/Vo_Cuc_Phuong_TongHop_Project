import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Wrap toàn app trong MaterialApp.builder để hiện 1 thanh đỏ khi mất mạng.
class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _offline = false;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final c = Connectivity();
    try {
      final r = await c.checkConnectivity();
      _apply(r);
    } catch (_) {}
    _sub = c.onConnectivityChanged.listen(_apply);
  }

  void _apply(List<ConnectivityResult> r) {
    final off = r.isEmpty || r.every((x) => x == ConnectivityResult.none);
    if (off != _offline && mounted) setState(() => _offline = off);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_offline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.red.shade700,
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off,
                            color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Mất kết nối Internet',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
