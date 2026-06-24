import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/api_client.dart';
import '../../services/auth_service.dart';

/// Login cho TỪNG module (TongHop / NhapHang). DatVe không qua màn này.
class LoginScreen extends ConsumerStatefulWidget {
  final String moduleKey; // 'tonghop' | 'nhaphang'

  const LoginScreen({super.key, required this.moduleKey});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  final _auth = AuthService();

  LoginRealm get _realm =>
      widget.moduleKey == 'tonghop' ? LoginRealm.tongHop : LoginRealm.nhapHang;

  String get _moduleName =>
      widget.moduleKey == 'tonghop' ? 'Tổng Hợp' : 'Nhập Hàng';

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _auth.login(
        username: _userCtrl.text.trim(),
        password: _pwdCtrl.text,
        realm: _realm,
      );
      if (!mounted) return;
      // Vào thẳng màn module sau khi login.
      context.go('/${widget.moduleKey}');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _pwdCtrl.dispose();
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
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 4,
                top: 4,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: 'Quay lại',
                  onPressed: _loading ? null : () => context.go('/home'),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset('assets/logo.png',
                                  width: 84, height: 84, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 12),
                            const Text('Võ Cúc Phương',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Đăng nhập module: $_moduleName',
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _userCtrl,
                              enabled: !_loading,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Tên đăng nhập',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Nhập tên đăng nhập'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pwdCtrl,
                              enabled: !_loading,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'Mật khẩu',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Nhập mật khẩu'
                                  : null,
                              onFieldSubmitted: (_) => _doLogin(),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(children: [
                                  const Icon(Icons.error_outline,
                                      color: Colors.red, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(_error!,
                                        style:
                                            const TextStyle(color: Colors.red)),
                                  ),
                                ]),
                              ),
                            ],
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _doLogin,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('ĐĂNG NHẬP'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
