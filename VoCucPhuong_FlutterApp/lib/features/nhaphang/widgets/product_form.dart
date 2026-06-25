import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants.dart';
import '../../../core/formatters.dart';
import '../../../core/station_aliases.dart';
import '../../../services/product_service.dart';
import 'station_dropdown.dart';

class ProductFormResult {
  final Map<String, dynamic> body;
  ProductFormResult(this.body);
}

class ProductForm extends StatefulWidget {
  final List<Station> stations;
  final Future<String?> Function(String stationCode) onStationChanged;
  final Future<void> Function(Map<String, dynamic> body) onSubmit;

  const ProductForm({
    super.key,
    required this.stations,
    required this.onStationChanged,
    required this.onSubmit,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _form = GlobalKey<FormState>();
  final _senderName = TextEditingController();
  final _senderPhone = TextEditingController();
  final _receiverName = TextEditingController();
  final _receiverPhone = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  final _amount = TextEditingController();
  final _note = TextEditingController();

  String? _senderStation;
  String? _toStation;
  String _productType = 'Kiện';
  String? _idPreview;
  bool _submitting = false;

  static const _types = ['Kiện', 'Thùng', 'Gói', 'Bao', 'Thùng xốp'];

  @override
  void dispose() {
    _senderName.dispose();
    _senderPhone.dispose();
    _receiverName.dispose();
    _receiverPhone.dispose();
    _quantity.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _codeFor(String? stationName) {
    if (stationName == null) return null;
    final s = widget.stations.firstWhere(
      (e) => e.name == stationName,
      orElse: () => Station(id: 0, code: '', name: '', fullName: ''),
    );
    return s.code.isEmpty ? null : s.code;
  }

  Future<void> _updateIdPreview() async {
    final code = _codeFor(_toStation);
    if (code == null) {
      setState(() => _idPreview = null);
      return;
    }
    final preview = await widget.onStationChanged(code);
    if (!mounted) return;
    setState(() => _idPreview = preview);
  }

  void _onNoteChange() {
    final detected = detectStationFromNote(_note.text);
    if (detected == null) return;
    final hit = widget.stations.firstWhere(
      (s) => s.name == detected,
      orElse: () => Station(id: 0, code: '', name: '', fullName: ''),
    );
    if (hit.code.isEmpty) return;
    if (_toStation != hit.name) {
      setState(() => _toStation = hit.name);
      _updateIdPreview();
    }
  }

  Future<void> _doSubmit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _submitting = true);
    final body = <String, dynamic>{
      'senderName': _senderName.text.trim(),
      'senderPhone': _senderPhone.text.trim(),
      'fromStation': _senderStation ?? '',
      'receiverName': _receiverName.text.trim(),
      'receiverPhone': _receiverPhone.text.trim(),
      'toStation': _toStation ?? '',
      'station': _codeFor(_toStation) ?? '',
      'productName': _productType,
      'productType': _productType,
      'quantity': int.tryParse(_quantity.text.trim()) ?? 1,
      'totalAmount': parseVND(_amount.text),
      'note': _note.text.trim(),
    };
    try {
      await widget.onSubmit(body);
      if (!mounted) return;
      _form.currentState!.reset();
      _senderName.clear();
      _senderPhone.clear();
      _receiverName.clear();
      _receiverPhone.clear();
      _amount.clear();
      _note.clear();
      _quantity.text = '1';
      setState(() {
        _senderStation = null;
        _toStation = null;
        _idPreview = null;
        _productType = 'Kiện';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_idPreview != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accent.withAlpha(120)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Text('Mã đơn dự kiến: ',
                      style: TextStyle(color: Colors.grey.shade700)),
                  Text(_idPreview!,
                      style: const TextStyle(
                          color: AppColors.dark,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),
          const _Section('Người gửi'),
          TextFormField(
            controller: _senderName,
            decoration: const InputDecoration(
              labelText: 'Tên người gửi',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nhập tên người gửi' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _senderPhone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
            ],
            decoration: const InputDecoration(
              labelText: 'SĐT người gửi',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Nhập SĐT';
              if (t.length < 9) return 'SĐT không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 10),
          StationDropdown(
            stations: widget.stations,
            value: _senderStation,
            label: 'Trạm gửi',
            icon: Icons.upload_outlined,
            onChanged: (v) => setState(() => _senderStation = v),
          ),
          const SizedBox(height: 18),
          const _Section('Người nhận'),
          TextFormField(
            controller: _receiverName,
            decoration: const InputDecoration(
              labelText: 'Tên người nhận',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Nhập tên người nhận' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _receiverPhone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
            ],
            decoration: const InputDecoration(
              labelText: 'SĐT người nhận',
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (v) {
              final t = (v ?? '').trim();
              if (t.isEmpty) return 'Nhập SĐT';
              if (t.length < 9) return 'SĐT không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 10),
          StationDropdown(
            stations: widget.stations,
            value: _toStation,
            label: 'Trạm nhận',
            icon: Icons.download_outlined,
            onChanged: (v) {
              setState(() => _toStation = v);
              _updateIdPreview();
            },
          ),
          const SizedBox(height: 18),
          const _Section('Hàng hóa'),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _productType,
                  decoration: const InputDecoration(
                    labelText: 'Loại',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      v == null ? null : setState(() => _productType = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _quantity,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'SL',
                  ),
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return '> 0';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _amount,
            keyboardType: TextInputType.number,
            inputFormatters: [VNDInputFormatter()],
            decoration: const InputDecoration(
              labelText: 'Cước phí',
              suffixText: 'đ',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            validator: (v) =>
                parseVND(v ?? '') <= 0 ? 'Nhập cước phí' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ghi chú (auto-detect trạm: vd "tco", "mc")',
              prefixIcon: Icon(Icons.notes_outlined),
            ),
            onChanged: (_) => _onNoteChange(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _doSubmit,
              icon: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save_outlined),
              label: Text(_submitting ? 'Đang lưu...' : 'Tạo đơn'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
              letterSpacing: 0.4)),
    );
  }
}
