import 'package:flutter/material.dart';
import 'session.dart';

class LoginScreen extends StatefulWidget {
  /// Widget hiển thị sau khi đăng nhập thành công (thường là MainScreen)
  final Widget Function() onDoneBuilder;
  const LoginScreen({super.key, required this.onDoneBuilder});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _doLogin() async {
    if (_userCtrl.text.trim().isEmpty || _pwdCtrl.text.isEmpty) {
      setState(() => _error = 'Nhập đủ tên đăng nhập và mật khẩu');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final err = await Session.login(_userCtrl.text.trim(), _pwdCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err == null) {
      _goToMain();
    } else {
      setState(() => _error = err);
    }
  }

  void _goToMain() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => widget.onDoneBuilder()),
      (route) => false,
    );
  }

  Future<void> _continueAsCustomer() async {
    await Session.saveCustomerMode();
    _goToMain();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.directions_bus, size: 64, color: Color(0xFF0EA5E9)),
                      const SizedBox(height: 12),
                      const Text('Võ Cúc Phương',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Đăng nhập để quản lý',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _userCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tên đăng nhập',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        enabled: !_loading,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _pwdCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _doLogin(),
                        enabled: !_loading,
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
                            const Icon(Icons.error_outline, color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                  style: const TextStyle(color: Colors.red)),
                            ),
                          ]),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _doLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EA5E9),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('ĐĂNG NHẬP',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 4),
                      TextButton.icon(
                        onPressed: _loading ? null : _continueAsCustomer,
                        icon: const Icon(Icons.confirmation_number_outlined),
                        label: const Text('Tiếp tục với tư cách khách (chỉ đặt vé)'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
