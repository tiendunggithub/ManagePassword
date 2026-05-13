import 'dart:convert';
import 'package:app/security/secure_vault.dart';
import 'package:flutter/material.dart';
import 'package:cryptography/cryptography.dart';
import '../models/password_model.dart';
import '../security/encryption.dart';

class PasswordProvider extends ChangeNotifier {
  final _vault = SecureVault();
  final _crypto = EncryptionService();
  
  SecretKey? _masterKey;
  List<PasswordEntry> _passwords = [];
  List<PasswordEntry> _passwordsNew = [];

  List<PasswordEntry> get passwords => _passwords;
  List<PasswordEntry> get passwordsNew => _passwordsNew;

  // Thiết lập Key sau khi login
  void setMasterKey(SecretKey key) {
    _masterKey = key;
    loadPasswords();
    loadPasswordsNew();
  }

  // Tải danh sách mật khẩu
  Future<void> loadPasswords() async {
    if (_masterKey == null) return;
    
    final allData = await _vault.readAll();
    List<PasswordEntry> loaded = [];

    allData.forEach((key, value) {
      // Chỉ xử lý các key có tiền tố 'pwd_'
      if (key.startsWith('pwd_')) {
        try {
          // CHỖ SỬA LỖI: value lúc này là chuỗi JSON String
          final Map<String, dynamic> jsonMap = jsonDecode(value);
          loaded.add(PasswordEntry.fromJson(jsonMap));
        } catch (e) {
          debugPrint("Lỗi giải mã JSON cho key $key: $e");
        }
      }
    });

    _passwords = loaded;
    notifyListeners();
  }

    // Tải danh sách 3 mật khẩu mới nhất
  Future<void> loadPasswordsNew() async {
    if (_masterKey == null) return;
    
    final allData = await _vault.readAll();
    List<PasswordEntry> loaded = [];

    int limit = 3;
    int index = 0;
    allData.forEach((key, value) {
      // Chỉ xử lý các key có tiền tố 'pwd_'
      if (index == limit) return;
      index++;
      if (key.startsWith('pwd_')) {
        try {
          // CHỖ SỬA LỖI: value lúc này là chuỗi JSON String
          final Map<String, dynamic> jsonMap = jsonDecode(value);
          loaded.add(PasswordEntry.fromJson(jsonMap));
        } catch (e) {
          debugPrint("Lỗi giải mã JSON cho key $key: $e");
        }
      }
    });

    _passwordsNew = loaded;
    notifyListeners();
  }

  // Thêm mật khẩu mới
  Future<void> addPassword(String service, String user, String plainPass) async {
    if (_masterKey == null) return;

    // 1. Mã hóa mật khẩu thô
    final encrypted = await _crypto.encrypt(plainPass, _masterKey!);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    // 2. Tạo đối tượng Model
    final entry = PasswordEntry(
      id: id,
      serviceName: service,
      username: user,
      encryptedPassword: encrypted,
    );

    // 3. Chuyển thành chuỗi JSON và lưu vào két sắt
    final String jsonString = jsonEncode(entry.toJson());
    await _vault.write('pwd_$id', jsonString);
    
    // 4. Cập nhật danh sách hiển thị
    _passwords.add(entry);
    if (_passwordsNew.length < 3 ) {
      _passwordsNew.add(entry);
    }
    notifyListeners();
  }

  // Giải mã mật khẩu để xem
  Future<String> decryptPassword(String encrypted) async {
    if (_masterKey == null) return "Chưa xác thực";
    try {
      return await _crypto.decrypt(encrypted, _masterKey!);
    } catch (e) {
      return "Lỗi giải mã";
    }
  }

  // Xóa mật khẩu theo ID
Future<void> deletePassword(String id) async {
  try {
    // 1. Xóa khỏi Secure Storage
    await _vault.delete('pwd_$id');

    // 2. Xóa khỏi danh sách trong RAM
    _passwords.removeWhere((entry) => entry.id == id);
    
    // 3. Thông báo cho UI cập nhật lại giao diện
    notifyListeners();
  } catch (e) {
    debugPrint("Lỗi khi xóa mật khẩu: $e");
    rethrow;
  }
}
}