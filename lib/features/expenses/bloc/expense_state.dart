import 'package:expense_tracker/features/expenses/models/expense_model.dart';

enum ReportFilter { daily, weekly, monthly }

class SpendingTrendPoint {
  const SpendingTrendPoint({required this.label, required this.amount});

  final String label;
  final double amount;
}

class ExpenseState {
  const ExpenseState({
    this.expenses = const <ExpenseModel>[],
    this.recentExpenses = const <ExpenseModel>[],
    this.filteredRecentExpenses = const <ExpenseModel>[],
    this.categorySpending = const <String, double>{},
    this.trendSpending = const <SpendingTrendPoint>[],
    this.reportFilter = ReportFilter.monthly,
    this.selectedCategoryFilter,
    this.selectedTrendLabel,
    this.totalSpending = 0,
    this.monthlySpending = 0,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<ExpenseModel> expenses;
  final List<ExpenseModel> recentExpenses;
  final List<ExpenseModel> filteredRecentExpenses;
  final Map<String, double> categorySpending;
  final List<SpendingTrendPoint> trendSpending;
  final ReportFilter reportFilter;
  final String? selectedCategoryFilter;
  final String? selectedTrendLabel;
  final double totalSpending;
  final double monthlySpending;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ExpenseState copyWith({
    List<ExpenseModel>? expenses,
    List<ExpenseModel>? recentExpenses,
    List<ExpenseModel>? filteredRecentExpenses,
    Map<String, double>? categorySpending,
    List<SpendingTrendPoint>? trendSpending,
    ReportFilter? reportFilter,
    String? selectedCategoryFilter,
    String? selectedTrendLabel,
    double? totalSpending,
    double? monthlySpending,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearCategoryFilter = false,
    bool clearTrendFilter = false,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      recentExpenses: recentExpenses ?? this.recentExpenses,
      filteredRecentExpenses:
          filteredRecentExpenses ?? this.filteredRecentExpenses,
      categorySpending: categorySpending ?? this.categorySpending,
      trendSpending: trendSpending ?? this.trendSpending,
      reportFilter: reportFilter ?? this.reportFilter,
      selectedCategoryFilter: clearCategoryFilter
          ? null
          : (selectedCategoryFilter ?? this.selectedCategoryFilter),
      selectedTrendLabel: clearTrendFilter
          ? null
          : (selectedTrendLabel ?? this.selectedTrendLabel),
      totalSpending: totalSpending ?? this.totalSpending,
      monthlySpending: monthlySpending ?? this.monthlySpending,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
