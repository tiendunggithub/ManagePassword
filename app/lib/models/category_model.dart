import 'package:flutter/material.dart';

class CategoryEntry {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  CategoryEntry({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
  };

  factory CategoryEntry.fromJson(Map<String, dynamic> json) => CategoryEntry(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    color: json['color'],
  );
}