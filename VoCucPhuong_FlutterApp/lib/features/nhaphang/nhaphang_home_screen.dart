import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_client.dart';
import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/error_view.dart';
import '../../core/widgets/skeleton_list.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../session.dart';
import 'widgets/product_card.dart';
import 'widgets/product_form.dart';
import 'widgets/qr_scanner_screen.dart';

class NhapHangHomeScreen extends StatefulWidget {
  const NhapHangHomeScreen({super.key});

  @override
  State<NhapHangHomeScreen> createState() => _NhapHangHomeScreenState();
}

class _NhapHangHomeScreenState extends State<NhapHangHomeScreen>
    with SingleTickerProviderStateMixin {
  final _session = ModuleSession('nhaphang');
  final _service = ProductService();
  late final TabController _tab;

  DateTime _date = DateTime.now();
  List<Product> _products = const [];
  List<Station> _stations = const [];
  bool _loadingProducts = false;
  bool _loadingStations = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _boot();
  }

  Future<void> _boot() async {
    await _session.load();
    if (!mounted) return;
    await Future.wait([_loadProducts(), _loadStations()]);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String get _dateApi => formatDateApi(_date);

  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final p = await _service.listProducts(date: _dateApi);
      if (!mounted) return;
      setState(() {
        _products = p;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  Future<void> _loadStations() async {
    setState(() => _loadingStations = true);
    try {
      final s = await _service.listStations();
      if (!mounted) return;
      setState(() => _stations = s);
    } on ApiException catch (_) {
      // Không chặn flow — chỉ thiếu dropdown trạm.
    } finally {
      if (mounted) setState(() => _loadingStations = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('vi'),
    );
    if (picked == null) return;
    setState(() => _date = picked);
    await _loadProducts();
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Đăng xuất Nhập Hàng?'),
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

  Future<void> _callPhone(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _share(Product p) async {
    final text =
        'Đơn VCP ${p.id} - ${p.productName} - ${p.fromStation} → ${p.toStation} - ${p.receiverName} ${p.receiverPhone} - ${formatVND(p.totalAmount)}';
    await Share.share(text);
  }

  Future<void> _cancel(Product p) async {
    final note = await showDialog<String>(
      context: context,
      builder: (c) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Hủy đơn?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hủy đơn ${p.id}?'),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Lý do'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Không')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary),
              onPressed: () => Navigator.pop(c, ctrl.text.trim()),
              child: const Text('Hủy đơn'),
            ),
          ],
        );
      },
    );
    if (note == null) return;
    try {
      await _service.cancelProduct(p.id, cancelNote: note);
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đã hủy đơn'), duration: Duration(seconds: 2)));
      await _loadProducts();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.message}')));
    }
  }

  /// Preview mã đơn YYMMDD.SSNN cho 1 station code.
  Future<String?> _previewId(String stationCode) async {
    try {
      final next = await _service.peekCounter(stationCode);
      final d = DateTime.now();
      final yy = (d.year % 100).toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final dd = d.day.toString().padLeft(2, '0');
      final seq = next.toString().padLeft(2, '0');
      return '$yy$mm$dd.$stationCode$seq';
    } catch (_) {
      return null;
    }
  }

  Future<void> _onSubmit(Map<String, dynamic> body) async {
    try {
      await _service.createProduct(body);
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Tạo đơn thành công'),
          duration: Duration(seconds: 2)));
      await _loadProducts();
      _tab.animateTo(0);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.message}')));
      rethrow;
    }
  }

  Future<void> _openScanner() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code == null || !mounted) return;
    HapticFeedback.lightImpact();
    final trimmed = code.trim();
    try {
      final list = await _service.listProducts(search: trimmed);
      if (!mounted) return;
      Product? match;
      if (list.isNotEmpty) match = list.first;
      if (match == null) {
        try {
          match = await _service.getProduct(trimmed);
        } catch (_) {}
      }
      if (!mounted) return;
      if (match == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không tìm thấy đơn: $trimmed')));
        return;
      }
      _showProductDetail(match);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.message}')));
    }
  }

  void _showProductDetail(Product p) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(p.id,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  if (p.isCancelled)
                    const Chip(
                        label: Text('Đã hủy'),
                        backgroundColor: AppColors.cancelled),
                ]),
                const SizedBox(height: 12),
                _row('Loại hàng', p.productName),
                _row('Trạm', '${p.fromStation} → ${p.toStation}'),
                _row('Người gửi', '${p.senderName} • ${p.senderPhone}'),
                _row('Người nhận',
                    '${p.receiverName} • ${p.receiverPhone}'),
                _row('Cước phí', formatVND(p.totalAmount)),
                _row('Đã giao',
                    formatVND(p.deliveredAmount)),
                if (p.note != null && p.note!.isNotEmpty)
                  _row('Ghi chú', p.note!),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.phone),
                      label: const Text('Gọi nhận'),
                      onPressed: () {
                        Navigator.pop(context);
                        _callPhone(p.receiverPhone);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share),
                      label: const Text('Chia sẻ'),
                      onPressed: () {
                        Navigator.pop(context);
                        _share(p);
                      },
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.dark,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accent,
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
            const Text('Quản Lý Hàng Hóa'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Chọn ngày',
            onPressed: _pickDate,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Đơn hôm nay'),
            Tab(icon: Icon(Icons.add_box_outlined), text: 'Tạo đơn'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Quét QR'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildListTab(),
          _buildFormTab(),
          _buildScanTab(),
        ],
      ),
    );
  }

  Widget _buildListTab() {
    if (_loadingProducts && _products.isEmpty) {
      return const SkeletonList();
    }
    if (_error != null && _products.isEmpty) {
      return ErrorView(message: _error!, onRetry: _loadProducts);
    }
    if (_products.isEmpty) {
      return EmptyState(
        message: 'Chưa có đơn ngày ${formatDate(_date)}',
        onRetry: _loadProducts,
      );
    }
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final p = _products[i];
          return Dismissible(
            key: ValueKey('p-${p.id}-$i'),
            direction: p.isCancelled
                ? DismissDirection.none
                : DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.cancel, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Hủy đơn',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            confirmDismiss: (_) async {
              await _cancel(p);
              return false;
            },
            child: ProductCard(
              product: p,
              onTap: () => _showProductDetail(p),
              onCallReceiver: () => _callPhone(p.receiverPhone),
              onShare: () => _share(p),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormTab() {
    if (_loadingStations && _stations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_stations.isEmpty) {
      return EmptyState(
        message: 'Không tải được danh sách trạm',
        onRetry: _loadStations,
      );
    }
    return ProductForm(
      stations: _stations,
      onStationChanged: _previewId,
      onSubmit: _onSubmit,
    );
  }

  Widget _buildScanTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner,
                size: 96, color: AppColors.accent),
            const SizedBox(height: 16),
            const Text(
              'Quét mã QR trên phiếu đơn để tra cứu nhanh',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.dark, fontSize: 14),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openScanner,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Mở camera'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
