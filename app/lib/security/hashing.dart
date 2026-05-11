import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashingService {
  // Trả về chuỗi Hex của SHA-256
  String hashSHA256(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}