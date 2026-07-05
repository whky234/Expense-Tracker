import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/features/categories/models/category_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryRepository {
  CategoryRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _categoryCollection {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('User is not authenticated.');
    }
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  Stream<List<CategoryModel>> watchCategories() {
    return _categoryCollection.orderBy('name').snapshots().map((
      QuerySnapshot<Map<String, dynamic>> snapshot,
    ) {
      final List<CategoryModel> custom = snapshot.docs
          .map(CategoryFirestoreAdapter.fromDocument)
          .toList(growable: false);
      return <CategoryModel>[
        ...kDefaultCategories,
        ...custom.where(
          (CategoryModel category) => !kDefaultCategories.any(
            (CategoryModel defaultCategory) =>
                defaultCategory.name.toLowerCase() ==
                category.name.toLowerCase(),
          ),
        ),
      ];
    });
  }

  Future<void> addCustomCategory(CategoryModel category) async {
    await _categoryCollection.add(CategoryFirestoreAdapter.toMap(category));
  }
}
