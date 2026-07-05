import 'dart:async';

import 'package:expense_tracker/features/categories/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/data/category_repository.dart';
import 'package:expense_tracker/features/categories/models/category_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc(this._repository) : super(const CategoryState(isLoading: true)) {
    on<WatchCategoriesRequested>(_onWatchCategoriesRequested);
    on<CategoriesChanged>(_onCategoriesChanged);
    on<CategoriesWatchFailed>(_onCategoriesWatchFailed);
    on<CustomCategoryAdded>(_onCustomCategoryAdded);
    on<CategorySelected>(_onCategorySelected);
  }

  final CategoryRepository _repository;
  StreamSubscription<List<CategoryModel>>? _subscription;

  Future<void> _onWatchCategoriesRequested(
    WatchCategoriesRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      await _subscription?.cancel();
      _subscription = _repository.watchCategories().listen(
        (List<CategoryModel> categories) => add(CategoriesChanged(categories)),
        onError: (_) => add(const CategoriesWatchFailed()),
      );
    } on StateError {
      emit(
        state.copyWith(
          categories: kDefaultCategories,
          isLoading: false,
          errorMessage: 'Please login to sync custom categories.',
          clearSuccess: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load categories.',
          clearSuccess: true,
        ),
      );
    }
  }

  void _onCategoriesChanged(
    CategoriesChanged event,
    Emitter<CategoryState> emit,
  ) {
    final CategoryModel selected =
        state.selectedCategory ??
        event.categories.firstWhere(
          (CategoryModel element) => element.name == 'Other',
          orElse: () => event.categories.first,
        );
    emit(
      state.copyWith(
        categories: event.categories,
        selectedCategory: selected,
        isLoading: false,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  void _onCategoriesWatchFailed(
    CategoriesWatchFailed event,
    Emitter<CategoryState> emit,
  ) {
    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load categories.',
        clearSuccess: true,
      ),
    );
  }

  Future<void> _onCustomCategoryAdded(
    CustomCategoryAdded event,
    Emitter<CategoryState> emit,
  ) async {
    final String trimmedName = event.name.trim();
    if (trimmedName.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Category name is required.',
          clearSuccess: true,
        ),
      );
      return;
    }

    if (state.categories.any(
      (CategoryModel category) =>
          category.name.toLowerCase() == trimmedName.toLowerCase(),
    )) {
      emit(
        state.copyWith(
          errorMessage: 'Category already exists.',
          clearSuccess: true,
        ),
      );
      return;
    }

    try {
      final CategoryModel category = CategoryModel(
        id: '',
        name: trimmedName,
        iconCodePoint: event.iconCodePoint,
        colorValue: event.colorValue,
        isDefault: false,
      );
      await _repository.addCustomCategory(category);
      emit(state.copyWith(successMessage: 'Category added.', clearError: true));
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to add category.',
          clearSuccess: true,
        ),
      );
    }
  }

  void _onCategorySelected(
    CategorySelected event,
    Emitter<CategoryState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
