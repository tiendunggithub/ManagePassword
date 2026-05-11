import 'package:app/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    final pass = _passController.text;
    if (pass.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Kiểm tra mật khẩu chủ
    final isCorrect = await _authService.authenticate(pass);

    if (isCorrect) {
      final key = await _authService.getValidSecretKey(pass);
      if (key != null) {
        // SỬA LỖI TẠI ĐÂY: Sử dụng Provider.of nếu context.read bị lỗi
        Provider.of<PasswordProvider>(context, listen: false).setMasterKey(key);
        
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu chủ không chính xác!")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Nhập Master Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _handleLogin, 
                  child: const Text("ĐĂNG NHẬP"),
                ),
          ],
        ),
      ),
    );
  }
}