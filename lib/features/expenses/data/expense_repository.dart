import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/expenses/models/expense_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseRepository {
  ExpenseRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _expenseCollection {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User is not authenticated.');
    }
    return _firestore.collection('users').doc(uid).collection('expenses');
  }

  Stream<List<ExpenseModel>> watchExpenses() {
    return _expenseCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(ExpenseFirestoreAdapter.fromDocument)
              .toList(growable: false),
        );
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _expenseCollection.add(ExpenseFirestoreAdapter.toMap(expense));
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _expenseCollection
        .doc(expense.id)
        .update(ExpenseFirestoreAdapter.toMap(expense));
  }

  Future<void> deleteExpense(String id) async {
    await _expenseCollection.doc(id).delete();
  }
}
