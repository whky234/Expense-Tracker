import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.isDefault,
  });

  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final bool isDefault;

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}

class CategoryFirestoreAdapter {
  static Map<String, dynamic> toMap(CategoryModel category) {
    return <String, dynamic>{
      'name': category.name,
      'iconCodePoint': category.iconCodePoint,
      'colorValue': category.colorValue,
      'isDefault': category.isDefault,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static CategoryModel fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic> data = document.data() ?? <String, dynamic>{};
    return CategoryModel(
      id: document.id,
      name: data['name'] as String? ?? 'Other',
      iconCodePoint: data['iconCodePoint'] as int? ?? Icons.category.codePoint,
      colorValue: data['colorValue'] as int? ?? Colors.grey.toARGB32(),
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }
}

final List<CategoryModel> kDefaultCategories = <CategoryModel>[
  const CategoryModel(
    id: 'default_food',
    name: 'Food',
    iconCodePoint: 0xe56c,
    colorValue: 0xFFE53935,
    isDefault: true,
  ),
  const CategoryModel(
    id: 'default_transport',
    name: 'Transport',
    iconCodePoint: 0xe531,
    colorValue: 0xFF1E88E5,
    isDefault: true,
  ),
  const CategoryModel(
    id: 'default_shopping',
    name: 'Shopping',
    iconCodePoint: 0xf1cc,
    colorValue: 0xFF8E24AA,
    isDefault: true,
  ),
  const CategoryModel(
    id: 'default_bills',
    name: 'Bills',
    iconCodePoint: 0xf01f,
    colorValue: 0xFFF4511E,
    isDefault: true,
  ),
  const CategoryModel(
    id: 'default_entertainment',
    name: 'Entertainment',
    iconCodePoint: 0xe40f,
    colorValue: 0xFF43A047,
    isDefault: true,
  ),
  const CategoryModel(
    id: 'default_health',
    name: 'Health',
    iconCodePoint: 0xe25b,
    colorValue: 0xFFD81B60,
    isDefault: true,
  ),
  const CategoryModel(
    id: 'default_other',
    name: 'Other',
    iconCodePoint: 0xe574,
    colorValue: 0xFF546E7A,
    isDefault: true,
  ),
];
