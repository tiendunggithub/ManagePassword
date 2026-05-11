import 'dart:convert';

class PasswordEntry {
  final String id;
  final String serviceName;
  final String username;
  final String encryptedPassword; // Chuỗi Base64 từ AES-GCM

  PasswordEntry({
    required this.id,
    required this.serviceName,
    required this.username,
    required this.encryptedPassword,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceName': serviceName,
    'username': username,
    'encryptedPassword': encryptedPassword,
  };

  factory PasswordEntry.fromJson(Map<String, dynamic> json) => PasswordEntry(
    id: json['id'],
    serviceName: json['serviceName'],
    username: json['username'],
    encryptedPassword: json['encryptedPassword'],
  );
}