import 'package:flutter/material.dart';
import '../security/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  void _handleRegister() async {
    if (_passController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu phải từ 6 ký tự")));
      return;
    }
    if (_passController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu không khớp")));
      return;
    }

    await _authService.register(_passController.text);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thiết lập Master Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text("Đây là mật khẩu duy nhất dùng để mở app. Đừng quên nó!"),
            const SizedBox(height: 20),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu chủ")),
            TextField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(labelText: "Xác nhận mật khẩu")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _handleRegister, child: const Text("TẠO MẬT KHẨU"))
          ],
        ),
      ),
    );
  }
}