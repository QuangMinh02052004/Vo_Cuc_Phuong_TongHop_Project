import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../models/route.dart';
import '../../services/datve_service.dart';
import 'widgets/booking_lookup_card.dart';
import 'widgets/route_card.dart';

class DatVeHomeScreen extends StatefulWidget {
  const DatVeHomeScreen({super.key});

  @override
  State<DatVeHomeScreen> createState() => _DatVeHomeScreenState();
}

class _DatVeHomeScreenState extends State<DatVeHomeScreen>
    with SingleTickerProviderStateMixin {
  final _service = DatVeService();
  late final TabController _tab;

  // Tab 1: tra cứu
  final _codeCtrl = TextEditingController();
  Map<String, dynamic>? _lookup;
  String? _lookupError;
  bool _looking = false;

  // Tab 2: routes
  List<BusRoute> _routes = const [];
  bool _loadingRoutes = false;
  String? _routesError;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadRoutes();
  }

  @override
  void dispose() {
    _tab.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookupBooking() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _looking = true;
      _lookupError = null;
      _lookup = null;
    });
    try {
      final res = await _service.getBooking(code);
      final body = res['data'] is Map
          ? Map<String, dynamic>.from(res['data'])
          : res;
      if (!mounted) return;
      setState(() => _lookup = Map<String, dynamic>.from(body));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _lookupError = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _lookupError = e.toString());
    } finally {
      if (mounted) setState(() => _looking = false);
    }
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _loadingRoutes = true;
      _routesError = null;
    });
    try {
      final r = await _service.listRoutes();
      if (!mounted) return;
      setState(() => _routes = r);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _routesError = e.message);
    } finally {
      if (mounted) setState(() => _loadingRoutes = false);
    }
  }

  Future<void> _callCustomer() async {
    final phone = (_lookup?['customerPhone'] ?? '').toString();
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _shareTicket() async {
    final d = _lookup;
    if (d == null) return;
    final code = (d['bookingCode'] ?? d['code'] ?? d['id'] ?? '').toString();
    final route = (d['routeName'] ?? '${d['from']} → ${d['to']}').toString();
    final amount = num.tryParse((d['totalPrice'] ?? d['amount'] ?? 0).toString()) ?? 0;
    final text =
        'Vé xe VCP - mã $code - $route - ${d['date']} ${d['departureTime']} - ${d['customerName']} - ${formatVND(amount)}';
    await Share.share(text);
  }

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
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.confirmation_number_outlined), text: 'Tra cứu vé'),
            Tab(icon: Icon(Icons.alt_route), text: 'Tuyến đường'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_buildLookupTab(), _buildRoutesTab()],
      ),
    );
  }

  Widget _buildLookupTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mã đặt vé',
                    style: TextStyle(
                        color: AppColors.dark,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          hintText: 'Nhập mã, ví dụ VCP123ABC',
                          prefixIcon: Icon(Icons.confirmation_number_outlined),
                        ),
                        onSubmitted: (_) => _lookupBooking(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _looking ? null : _lookupBooking,
                      child: _looking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Tra cứu'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_lookupError != null)
          ErrorView(message: _lookupError!, onRetry: _lookupBooking)
        else if (_lookup != null)
          BookingLookupCard(
            data: _lookup!,
            onCall: _callCustomer,
            onShare: _shareTicket,
          )
        else
          const EmptyState(
            message:
                'Nhập mã đặt vé và bấm "Tra cứu" để xem thông tin chi tiết',
            icon: Icons.search,
          ),
      ],
    );
  }

  Widget _buildRoutesTab() {
    if (_loadingRoutes && _routes.isEmpty) return const SkeletonList();
    if (_routesError != null && _routes.isEmpty) {
      return ErrorView(message: _routesError!, onRetry: _loadRoutes);
    }
    if (_routes.isEmpty) {
      return EmptyState(message: 'Chưa có tuyến', onRetry: _loadRoutes);
    }
    return RefreshIndicator(
      onRefresh: _loadRoutes,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _routes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => RouteCard(route: _routes[i]),
      ),
    );
  }
}
