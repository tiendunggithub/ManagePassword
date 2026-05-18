import 'package:app/core/theme/app_colors.dart';
import 'package:app/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';
import 'package:app/security/secure_vault.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isLoadingBiometric = false;
  final LocalAuthentication auth = LocalAuthentication();

  // Cấu hình nâng cao cho Android và iOS
  final _storage = const FlutterSecureStorage(
    // AndroidOptions.biometric()
    aOptions: AndroidOptions(
      // Ép lưu vào Android Keystore và yêu cầu xác thực sinh trắc học mỗi lần truy cập
      enforceBiometrics: true,
      
      // 2. Tùy biến thông báo pop-up hiện lên cho người dùng trên Android
      biometricPromptTitle: 'Xác thực bảo mật',
      biometricPromptSubtitle: 'Vui lòng quét vân tay để mở khóa ứng dụng',
      
      // 3. Giữ các thuật toán mã hóa mặc định an toàn cao nhất
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,

      // Tự động reset bộ nhớ nếu xảy ra lỗi mã hóa (tránh crash app diện rộng)
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      // Ép buộc lưu khóa vào chip bảo mật phần cứng Secure Enclave
      useSecureEnclave: true,

      // 2. Định nghĩa điều kiện để mở khóa: Bắt buộc phải có Sinh trắc học (BiometryAny)
      // kết hợp với điều kiện máy phải đang được unlock (UserPresence)
      accessControlFlags: [
        AccessControlFlag.biometryAny,
        AccessControlFlag.userPresence,
      ],

      // 3. Trạng thái khả dụng của Keychain
      accessibility: KeychainAccessibility.unlocked,

      // 4. Sử dụng thuật toán mã hóa mạnh nhất có sẵn (AES-256-GCM)
      accountName: "SecureVaultKey", // Tên tài khoản trong Keychain
      synchronizable: false, // Không đồng bộ khóa qua iCloud (bảo mật tối đa)
    ),
  );

  // 1. Hàm LƯU mật khẩu/dữ liệu nhạy cảm
  Future<void> savePassword(String password) async {
    try {
      // Khi lưu, hệ thống có thể sẽ yêu cầu người dùng xác thực vân tay 
      // để sinh cặp khóa (Key Pair) bảo mật trong phần cứng chip.
      await _storage.write(key: 'user_secure_password', value: password);
      print("Đã khóa và lưu mật khẩu thành công!");
    } catch (e) {
      print("Lỗi lưu dữ liệu: $e");
    }
  }

  void _handleLogin() async {
    final pass = _passController.text;
    if (pass.isEmpty) return;

    setState(() => _isLoading = true);

    // Kiểm tra mật khẩu chủ
    final isCorrect = await _authService.authenticate(pass);

    if (isCorrect) {
      final key = await _authService.getValidSecretKey(pass);
      if (key != null) {
        await SecureVault().write('master_password', pass);
        await savePassword(pass);
        Provider.of<PasswordProvider>(context, listen: false).setMasterKey(key);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      _showSnackBar("Mật khẩu chủ không chính xác!");
    }
    setState(() => _isLoading = false);
  }

  Future<void> _biometricAuthenticate() async {
    setState(() => _isLoadingBiometric = true);
    try {
      // 1. Kiểm tra thiết bị có phần cứng sinh trắc học không và có đang bật không
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        _showSnackBar('Thiết bị không hỗ trợ hoặc chưa cài đặt sinh trắc học.');
        setState(() => _isLoadingBiometric = false);
        return;
      }

      // 2. Kích hoạt màn hình quét vân tay / Face ID
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Vui lòng quét vân tay hoặc Face ID để đăng nhập',
        biometricOnly: true,
      );

      if (didAuthenticate) {
        // Đăng nhập thành công!
        // Lấy master password đã lưu để tạo key
        String? pass = await _storage.read(key: 'user_secure_password');
        if (pass != null) {
          final key = await _authService.getValidSecretKey(pass);
          if (key != null) {
            Provider.of<PasswordProvider>(context, listen: false).setMasterKey(key);
          }
          Navigator.pushReplacementNamed(context, '/home');
          _showSnackBar("Đăng nhập sinh trắc học thành công!");
        } else {
          // Chưa có master password lưu trong máy
          _showSnackBar("Vui lòng đăng nhập bằng mật khẩu lần đầu để sử dụng sinh trắc học!", isLongDuration: true);
        }
      } else {
        // Người dùng hủy hoặc quét sai nhiều lần
        print('Xác thực thất bại hoặc bị hủy.');
      }
      setState(() => _isLoadingBiometric = false);
    } catch (e) {
      setState(() => _isLoadingBiometric = false);
      final errorString = e.toString();
      // KIỂM TRA CẢ 2 TRƯỜNG HỢP: Chưa cài mật khẩu máy HOẶC Chưa quét vân tay vào máy
      if (errorString.contains('noCredentialsSet') || errorString.contains('noBiometricsEnrolled')) {
      _showSnackBar(
        'Bạn chưa đăng ký dấu vân tay hoặc Face ID trên điện thoại.',
        isLongDuration: true,
      );
    } else if (errorString.contains('notAvailable') || errorString.contains('uiUnavailable')) {
      _showSnackBar('Tính năng sinh trắc học hiện không khả dụng trên thiết bị.');
    } else if (errorString.contains('LockedOut')) {
      _showSnackBar('Sinh trắc học bị khóa do thử sai quá nhiều lần. Vui lòng nhập mật khẩu hoặc thử lại sau.');
    } else {
      // Nếu là lỗi khác, in ra màn hình để lập trình viên dễ đọc
      _showSnackBar('Lỗi: $errorString');
      print('Lỗi: $errorString');
    }
    }
  }

  void _showSnackBar(String message, {bool isLongDuration = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: isLongDuration ? 6 : 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xác thực")),
      body: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      minimumSize: Size.fromHeight(50)
                    ),
                    child: Text('Đăng nhập', style: TextStyle(fontSize: 16)),
                  ),
              SizedBox(height: 20),
              _isLoadingBiometric 
              ? const CircularProgressIndicator()
              : ElevatedButton(
                onPressed: () async {
                  _biometricAuthenticate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  minimumSize: Size.fromHeight(50)
                ),
                child: Icon(Icons.fingerprint),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/forgot-password');
                },
                child: Text("Quên mật khẩu?", textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
      )
    );
  }
}