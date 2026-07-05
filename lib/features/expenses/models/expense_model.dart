import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.categoryName,
    required this.categoryIconCodePoint,
    required this.categoryColorValue,
    required this.date,
    required this.notes,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final double amount;
  final String categoryName;
  final int categoryIconCodePoint;
  final int categoryColorValue;
  final DateTime date;
  final String notes;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? categoryName,
    int? categoryIconCodePoint,
    int? categoryColorValue,
    DateTime? date,
    String? notes,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryName: categoryName ?? this.categoryName,
      categoryIconCodePoint:
          categoryIconCodePoint ?? this.categoryIconCodePoint,
      categoryColorValue: categoryColorValue ?? this.categoryColorValue,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ExpenseFirestoreAdapter {
  static Map<String, dynamic> toMap(ExpenseModel expense) {
    return <String, dynamic>{
      'amount': expense.amount,
      'categoryName': expense.categoryName,
      'categoryIconCodePoint': expense.categoryIconCodePoint,
      'categoryColorValue': expense.categoryColorValue,
      'date': Timestamp.fromDate(expense.date),
      'notes': expense.notes,
      'paymentMethod': expense.paymentMethod,
      'createdAt': Timestamp.fromDate(expense.createdAt),
      'updatedAt': Timestamp.fromDate(expense.updatedAt),
    };
  }

  static ExpenseModel fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic> data = document.data() ?? <String, dynamic>{};
    final String categoryName =
        data['categoryName'] as String? ??
        data['category'] as String? ??
        'Other';
    return ExpenseModel(
      id: document.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      categoryName: categoryName,
      categoryIconCodePoint:
          data['categoryIconCodePoint'] as int? ?? Icons.category.codePoint,
      categoryColorValue: data['categoryColorValue'] as int? ?? 0xFF546E7A,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? 'Cash',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
