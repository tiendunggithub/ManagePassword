// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/password_provider.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/register_screen.dart'; // Import màn hình mới
import 'security/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
  // Kiểm tra xem đã có Salt (tức là đã đăng ký) trong Secure Storage chưa
  final bool registered = await authService.isUserRegistered();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
      ],
      child: MyApp(isRegistered: registered),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isRegistered;
  const MyApp({super.key, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Pass',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // TỰ ĐỘNG CHỌN MÀN HÌNH ĐẦU TIÊN
      home: isRegistered ? LoginScreen() : const RegisterScreen(), 
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}