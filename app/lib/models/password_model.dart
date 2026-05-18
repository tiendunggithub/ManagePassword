import 'dart:convert';

class PasswordEntry {
  final String id;
  final String serviceName;
  final String username;
  final String encryptedPassword; // Chuỗi Base64 từ AES-GCM
  final String website;

  PasswordEntry({
    required this.id,
    required this.serviceName,
    required this.username,
    required this.encryptedPassword,
    this.website = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceName': serviceName,
    'username': username,
    'encryptedPassword': encryptedPassword,
    'website': website,
  };

  factory PasswordEntry.fromJson(Map<String, dynamic> json) => PasswordEntry(
    id: json['id'],
    serviceName: json['serviceName'],
    username: json['username'],
    encryptedPassword: json['encryptedPassword'],
    website: json['website'] ?? '',
  );
}