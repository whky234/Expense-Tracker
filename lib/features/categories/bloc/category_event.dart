import 'package:expense_tracker/features/categories/models/category_model.dart';

abstract class CategoryEvent {
  const CategoryEvent();
}

class WatchCategoriesRequested extends CategoryEvent {
  const WatchCategoriesRequested();
}

class CustomCategoryAdded extends CategoryEvent {
  const CustomCategoryAdded({
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
  });

  final String name;
  final int iconCodePoint;
  final int colorValue;
}

class CategorySelected extends CategoryEvent {
  const CategorySelected(this.category);

  final CategoryModel category;
}

class CategoriesChanged extends CategoryEvent {
  const CategoriesChanged(this.categories);

  final List<CategoryModel> categories;
}

class CategoriesWatchFailed extends CategoryEvent {
  const CategoriesWatchFailed();
}
