import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'secure_vault.dart';
import 'encryption.dart';
import 'hashing.dart';

class AuthService {
  final _vault = SecureVault();
  final _crypto = EncryptionService();
  final _hash = HashingService();

  static const _kSalt = 'storage_salt';
  static const _kPassHash = 'master_password_hash';

  // Kiểm tra xem user đã tạo mật khẩu chủ chưa
  Future<bool> isUserRegistered() async {
    final salt = await _vault.read(_kSalt);
    return salt != null;
  }

  // Đăng ký lần đầu: Tạo Salt ngẫu nhiên và lưu hash mật khẩu
  Future<void> register(String password) async {
    final random = Random.secure();
    final salt = Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
    
    await _vault.write(_kSalt, base64.encode(salt));
    await _vault.write(_kPassHash, _hash.hashSHA256(password));
  }

  // Xác thực mật khẩu nhập vào có khớp với mã băm đã lưu không
Future<bool> authenticate(String password) async {
  final storedHash = await _vault.read(_kPassHash);
  if (storedHash == null) return false; // Trả về false thay vì để mặc định
  return _hash.hashSHA256(password) == storedHash;
}

  // Quan trọng: Lấy SecretKey thực tế để dùng cho việc mã hóa mật khẩu các dịch vụ
  Future<SecretKey?> getValidSecretKey(String password) async {
    final saltBase64 = await _vault.read(_kSalt);
    if (saltBase64 == null) return null;

    final salt = base64.decode(saltBase64);
    return await _crypto.deriveKey(password, salt);
  }
}