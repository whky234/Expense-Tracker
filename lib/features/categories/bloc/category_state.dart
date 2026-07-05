import 'package:expense_tracker/features/categories/models/category_model.dart';

class CategoryState {
  const CategoryState({
    this.categories = const <CategoryModel>[],
    this.selectedCategory,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  CategoryState copyWith({
    List<CategoryModel>? categories,
    CategoryModel? selectedCategory,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
