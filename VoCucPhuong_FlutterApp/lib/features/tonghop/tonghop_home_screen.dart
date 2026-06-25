import 'dart:async';

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
import '../../models/booking.dart';
import '../../models/route.dart';
import '../../models/time_slot.dart';
import '../../services/booking_service.dart';
import '../../session.dart';
import 'widgets/booking_form_sheet.dart';
import 'widgets/booking_list_item.dart';
import 'widgets/seat_map.dart';
import 'widgets/timeslot_card.dart';

class TongHopHomeScreen extends StatefulWidget {
  const TongHopHomeScreen({super.key});

  @override
  State<TongHopHomeScreen> createState() => _TongHopHomeScreenState();
}

class _TongHopHomeScreenState extends State<TongHopHomeScreen>
    with SingleTickerProviderStateMixin {
  final _session = ModuleSession('tonghop');
  final _service = BookingService();
  late final TabController _tab;

  DateTime _date = DateTime.now();
  String _selectedRoute = '';
  List<BusRoute> _routes = const [];
  List<TimeSlot> _slots = const [];
  List<Booking> _bookings = const [];
  bool _loadingRoutes = false;
  bool _loadingSlots = false;
  bool _loadingBookings = false;
  String? _error;

  // Tab 2: timeslot đang xem sơ đồ ghế
  TimeSlot? _activeSlot;

  // Tab 3: search + polling delta
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  bool _pollingOn = true;
  DateTime _lastSync = DateTime.now().toUtc();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _boot();
  }

  Future<void> _boot() async {
    await _session.load();
    if (!mounted) return;
    await _loadRoutes();
    await _refreshAll();
    _startPolling();
  }

  @override
  void dispose() {
    _tab.dispose();
    _pollTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  String get _dateApi => formatDateApi(_date);

  Future<void> _loadRoutes() async {
    setState(() => _loadingRoutes = true);
    try {
      final r = await _service.listRoutes();
      if (!mounted) return;
      setState(() {
        _routes = r;
        if (_selectedRoute.isEmpty && r.isNotEmpty) {
          _selectedRoute = r.first.name;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loadingRoutes = false);
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadSlots(), _loadBookings()]);
  }

  Future<void> _loadSlots() async {
    if (_selectedRoute.isEmpty) {
      setState(() => _slots = const []);
      return;
    }
    setState(() => _loadingSlots = true);
    try {
      final s = await _service.listTimeSlots(
          date: _dateApi, route: _selectedRoute);
      if (!mounted) return;
      setState(() {
        _slots = s;
        if (_activeSlot != null) {
          _activeSlot = s.firstWhere(
            (e) => e.id == _activeSlot!.id,
            orElse: () => _activeSlot!,
          );
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  Future<void> _loadBookings() async {
    setState(() => _loadingBookings = true);
    try {
      final b = await _service.listBookings(
          date: _dateApi,
          route: _selectedRoute.isEmpty ? null : _selectedRoute);
      if (!mounted) return;
      setState(() {
        _bookings = b;
        _lastSync = DateTime.now().toUtc();
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loadingBookings = false);
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (!_pollingOn) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || !_pollingOn) return;
      try {
        final since = _lastSync.toIso8601String();
        final delta = await _service.listBookings(
          date: _dateApi,
          route: _selectedRoute.isEmpty ? null : _selectedRoute,
          since: since,
        );
        if (!mounted) return;
        if (delta.isEmpty) {
          _lastSync = DateTime.now().toUtc();
          return;
        }
        final byId = <int?, Booking>{for (final b in _bookings) b.id: b};
        for (final d in delta) {
          byId[d.id] = d;
        }
        setState(() {
          _bookings = byId.values.toList();
          _lastSync = DateTime.now().toUtc();
        });
      } catch (_) {
        // Bỏ qua lỗi polling — UI vẫn dùng dữ liệu cũ.
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('vi'),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _activeSlot = null;
    });
    await _refreshAll();
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
    _stopPolling();
    await _session.logout();
    if (!mounted) return;
    context.go('/home');
  }

  List<int> _usedSeatsFor(TimeSlot s) {
    return _bookings
        .where((b) =>
            !b.isCancelled &&
            (b.timeSlotId == s.id ||
                (b.timeSlot == s.time && b.route == s.route && b.date == s.date)))
        .map((b) => b.seatNumber)
        .where((n) => n > 0)
        .toList();
  }

  int _bookedCountFor(TimeSlot s) => _usedSeatsFor(s).length;

  Future<void> _callPhone(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _shareBooking(Booking b) async {
    final text =
        'Vé xe VCP - ${b.name} - ghế ${b.seatNumber.toString().padLeft(2, '0')} - ${b.timeSlot} ${b.date} - ${b.route}';
    await Share.share(text);
  }

  Future<void> _cancelBooking(Booking b) async {
    if (b.id == null) return;
    final reason = await showDialog<String>(
      context: context,
      builder: (c) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Hủy vé?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hủy vé ghế ${b.seatNumber} của ${b.name}?'),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Lý do (tùy chọn)',
                ),
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
              child: const Text('Hủy vé'),
            ),
          ],
        );
      },
    );
    if (reason == null) return;
    try {
      await _service.cancelBooking(b.id!, reason: reason);
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy vé'), duration: Duration(seconds: 2)));
      await _loadBookings();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.message}')));
    }
  }

  Future<void> _createBookingFor(TimeSlot s, int seat) async {
    final route = _routes.firstWhere((r) => r.name == s.route,
        orElse: () => BusRoute(id: 0, name: s.route));
    final draft = await showModalBottomSheet<Booking>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookingFormSheet(
        slot: s,
        seatNumber: seat,
        suggestedPrice: route.price,
      ),
    );
    if (draft == null) return;
    try {
      await _service.createBooking(draft);
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đặt vé thành công'),
          duration: Duration(seconds: 2)));
      await _loadBookings();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.message}')));
    }
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
            Tab(icon: Icon(Icons.directions_bus), text: 'Chuyến'),
            Tab(icon: Icon(Icons.event_seat), text: 'Sơ đồ ghế'),
            Tab(icon: Icon(Icons.list_alt), text: 'Booking'),
          ],
        ),
      ),
      body: Column(
        children: [
          _RouteFilterBar(
            routes: _routes,
            selected: _selectedRoute,
            date: _date,
            loading: _loadingRoutes,
            onRouteChanged: (v) {
              setState(() {
                _selectedRoute = v;
                _activeSlot = null;
              });
              _refreshAll();
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildTripsTab(),
                _buildSeatTab(),
                _buildBookingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsTab() {
    if (_loadingSlots && _slots.isEmpty) {
      return const SkeletonList();
    }
    if (_error != null && _slots.isEmpty) {
      return ErrorView(message: _error!, onRetry: _loadSlots);
    }
    if (_slots.isEmpty) {
      return EmptyState(
        message: 'Chưa có chuyến cho ngày ${formatDate(_date)}',
        onRetry: _loadSlots,
      );
    }
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _slots.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final s = _slots[i];
          return TimeSlotCard(
            slot: s,
            bookedCount: _bookedCountFor(s),
            onTap: () {
              setState(() => _activeSlot = s);
              _tab.animateTo(1);
            },
          );
        },
      ),
    );
  }

  Widget _buildSeatTab() {
    final slot = _activeSlot;
    if (slot == null) {
      return EmptyState(
        message: 'Chọn 1 chuyến ở tab "Chuyến" để xem sơ đồ ghế',
        icon: Icons.touch_app_outlined,
        onRetry: () => _tab.animateTo(0),
      );
    }
    final used = _usedSeatsFor(slot);
    return RefreshIndicator(
      onRefresh: _refreshAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${slot.time}  •  ${slot.route}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.dark)),
                  const SizedBox(height: 4),
                  Text(
                      'Ngày ${formatDate(_date)}  •  Đã đặt ${used.length}/${SeatMap.kTotal}',
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SeatMap(
                usedSeats: used,
                onTap: (n) => _createBookingFor(slot, n),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    final filtered = _bookings.where((b) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return b.name.toLowerCase().contains(q) ||
          b.phone.contains(q);
    }).toList()
      ..sort((a, b) =>
          (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tìm SĐT hoặc tên...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: _pollingOn ? 'Tắt tự cập nhật' : 'Bật tự cập nhật',
                child: IconButton(
                  icon: Icon(
                      _pollingOn ? Icons.sync : Icons.sync_disabled,
                      color: _pollingOn
                          ? AppColors.accent
                          : Colors.grey),
                  onPressed: () {
                    setState(() => _pollingOn = !_pollingOn);
                    if (_pollingOn) {
                      _startPolling();
                    } else {
                      _stopPolling();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingBookings && _bookings.isEmpty
              ? const SkeletonList()
              : (filtered.isEmpty
                  ? EmptyState(
                      message: 'Chưa có booking',
                      onRetry: _loadBookings,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBookings,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final b = filtered[i];
                          return Dismissible(
                            key: ValueKey('b-${b.id}-$i'),
                            direction: b.isCancelled
                                ? DismissDirection.none
                                : DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(
                                    AppSizes.cardRadius),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.cancel,
                                      color: Colors.white),
                                  SizedBox(width: 6),
                                  Text('Hủy vé',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            confirmDismiss: (_) async {
                              await _cancelBooking(b);
                              return false;
                            },
                            child: BookingListItem(
                              booking: b,
                              onCallPhone: () => _callPhone(b.phone),
                              onShare: () => _shareBooking(b),
                            ),
                          );
                        },
                      ),
                    )),
        ),
      ],
    );
  }
}

class _RouteFilterBar extends StatelessWidget {
  final List<BusRoute> routes;
  final String selected;
  final DateTime date;
  final bool loading;
  final ValueChanged<String> onRouteChanged;

  const _RouteFilterBar({
    required this.routes,
    required this.selected,
    required this.date,
    required this.loading,
    required this.onRouteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orange.withAlpha(40),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.event, size: 16, color: AppColors.orange),
                const SizedBox(width: 4),
                Text(formatDate(date),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.dark,
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: loading
                ? const LinearProgressIndicator()
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selected.isEmpty ? null : selected,
                      isExpanded: true,
                      hint: const Text('Chọn tuyến...'),
                      items: routes
                          .map((r) => DropdownMenuItem(
                                value: r.name,
                                child: Text(r.name,
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) => v == null ? null : onRouteChanged(v),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
