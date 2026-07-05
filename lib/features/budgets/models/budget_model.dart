import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.categoryName,
    required this.limitAmount,
    required this.monthKey,
  });

  final String id;
  final String categoryName;
  final double limitAmount;
  final String monthKey;
}

class BudgetFirestoreAdapter {
  static Map<String, dynamic> toMap(BudgetModel budget) {
    return <String, dynamic>{
      'categoryName': budget.categoryName,
      'limitAmount': budget.limitAmount,
      'monthKey': budget.monthKey,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static BudgetModel fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    return BudgetModel(
      id: doc.id,
      categoryName: data['categoryName'] as String? ?? 'Other',
      limitAmount: (data['limitAmount'] as num?)?.toDouble() ?? 0,
      monthKey: data['monthKey'] as String? ?? '',
    );
  }
}
