import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/budgets/models/budget_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetRepository {
  BudgetRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _budgetCollection {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User is not authenticated.');
    }
    return _firestore.collection('users').doc(uid).collection('budgets');
  }

  Stream<List<BudgetModel>> watchBudgetsByMonth(String monthKey) {
    return _budgetCollection
        .where('monthKey', isEqualTo: monthKey)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(BudgetFirestoreAdapter.fromDocument)
              .toList(growable: false),
        );
  }

  Future<void> upsertBudget({
    required String categoryName,
    required double limitAmount,
    required String monthKey,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> existing = await _budgetCollection
        .where('monthKey', isEqualTo: monthKey)
        .where('categoryName', isEqualTo: categoryName)
        .limit(1)
        .get();

    final BudgetModel budget = BudgetModel(
      id: existing.docs.isNotEmpty ? existing.docs.first.id : '',
      categoryName: categoryName,
      limitAmount: limitAmount,
      monthKey: monthKey,
    );

    if (existing.docs.isNotEmpty) {
      await _budgetCollection
          .doc(existing.docs.first.id)
          .set(BudgetFirestoreAdapter.toMap(budget), SetOptions(merge: true));
      return;
    }

    await _budgetCollection.add(BudgetFirestoreAdapter.toMap(budget));
  }
}
