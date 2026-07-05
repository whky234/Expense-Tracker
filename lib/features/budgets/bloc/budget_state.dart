import 'package:expense_tracker/features/budgets/models/budget_model.dart';

class BudgetState {
  const BudgetState({
    this.budgets = const <BudgetModel>[],
    this.monthKey = '',
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<BudgetModel> budgets;
  final String monthKey;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  BudgetState copyWith({
    List<BudgetModel>? budgets,
    String? monthKey,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      monthKey: monthKey ?? this.monthKey,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
