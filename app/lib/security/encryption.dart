import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class EncryptionService {
  final _algorithm = AesGcm.with256bits();

  // Tạo SecretKey từ mật khẩu và muối (Salt)
  Future<SecretKey> deriveKey(String password, List<int> salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    return await pbkdf2.deriveKeyFromPassword(
      password: password,
      nonce: salt,
    );
  }

  // Mã hóa chuỗi văn bản -> Base64 (bao gồm Nonce + Mac + Ciphertext)
  Future<String> encrypt(String plainText, SecretKey key) async {
    final secretBox = await _algorithm.encrypt(utf8.encode(plainText), secretKey: key);
    return base64.encode(secretBox.concatenation());
  }

  // Giải mã từ Base64 -> văn bản gốc
  Future<String> decrypt(String encodedData, SecretKey key) async {
    final secretBox = SecretBox.fromConcatenation(
      base64.decode(encodedData),
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    final clearText = await _algorithm.decrypt(secretBox, secretKey: key);
    return utf8.decode(clearText);
  }
}