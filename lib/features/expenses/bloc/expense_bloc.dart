import 'dart:async';
import 'dart:collection';

import 'package:expense_tracker/features/expenses/bloc/expense_event.dart';
import 'package:expense_tracker/features/expenses/bloc/expense_state.dart';
import 'package:expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:expense_tracker/features/expenses/models/expense_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc(this._repository) : super(const ExpenseState(isLoading: true)) {
    on<WatchExpensesRequested>(_onWatchExpensesRequested);
    on<ExpensesChanged>(_onExpensesChanged);
    on<ExpensesWatchFailed>(_onExpensesWatchFailed);
    on<ReportFilterChanged>(_onReportFilterChanged);
    on<CategorySegmentTapped>(_onCategorySegmentTapped);
    on<TrendBarTapped>(_onTrendBarTapped);
    on<ReportTransactionFiltersCleared>(_onReportTransactionFiltersCleared);
    on<ExpenseAdded>(_onExpenseAdded);
    on<ExpenseUpdated>(_onExpenseUpdated);
    on<ExpenseDeleted>(_onExpenseDeleted);
  }

  final ExpenseRepository _repository;
  StreamSubscription<List<ExpenseModel>>? _expensesSubscription;

  Future<void> _onWatchExpensesRequested(
    WatchExpensesRequested event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearSuccess: true));
    try {
      await _expensesSubscription?.cancel();
      _expensesSubscription = _repository.watchExpenses().listen(
        (List<ExpenseModel> expenses) => add(ExpensesChanged(expenses)),
        onError: (_) => add(const ExpensesWatchFailed()),
      );
    } on StateError {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Please login to access your expenses.',
          clearSuccess: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load expenses.',
          clearSuccess: true,
        ),
      );
    }
  }

  void _onExpensesChanged(ExpensesChanged event, Emitter<ExpenseState> emit) {
    final List<ExpenseModel> expenses = event.expenses;
    emit(_buildStateFromExpenses(expenses, state.reportFilter, state));
  }

  void _onExpensesWatchFailed(
    ExpensesWatchFailed event,
    Emitter<ExpenseState> emit,
  ) {
    emit(
      state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load expenses.',
        clearSuccess: true,
      ),
    );
  }

  void _onReportFilterChanged(
    ReportFilterChanged event,
    Emitter<ExpenseState> emit,
  ) {
    emit(
      _buildStateFromExpenses(
        state.expenses,
        event.filter,
        state.copyWith(clearTrendFilter: true),
      ),
    );
  }

  void _onCategorySegmentTapped(
    CategorySegmentTapped event,
    Emitter<ExpenseState> emit,
  ) {
    final String? nextCategory =
        state.selectedCategoryFilter == event.categoryName
        ? null
        : event.categoryName;
    emit(
      _buildStateFromExpenses(
        state.expenses,
        state.reportFilter,
        state.copyWith(
          selectedCategoryFilter: nextCategory,
          clearCategoryFilter: nextCategory == null,
        ),
      ),
    );
  }

  void _onTrendBarTapped(TrendBarTapped event, Emitter<ExpenseState> emit) {
    final String? nextTrend = state.selectedTrendLabel == event.trendLabel
        ? null
        : event.trendLabel;
    emit(
      _buildStateFromExpenses(
        state.expenses,
        state.reportFilter,
        state.copyWith(
          selectedTrendLabel: nextTrend,
          clearTrendFilter: nextTrend == null,
        ),
      ),
    );
  }

  void _onReportTransactionFiltersCleared(
    ReportTransactionFiltersCleared event,
    Emitter<ExpenseState> emit,
  ) {
    emit(
      _buildStateFromExpenses(
        state.expenses,
        state.reportFilter,
        state.copyWith(clearCategoryFilter: true, clearTrendFilter: true),
      ),
    );
  }

  Future<void> _onExpenseAdded(
    ExpenseAdded event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final DateTime now = DateTime.now();
      final ExpenseModel expense = ExpenseModel(
        id: '',
        amount: event.amount,
        categoryName: event.categoryName,
        categoryIconCodePoint: event.categoryIconCodePoint,
        categoryColorValue: event.categoryColorValue,
        date: event.date,
        notes: event.notes,
        paymentMethod: event.paymentMethod,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.addExpense(expense);
      emit(state.copyWith(successMessage: 'Expense added.', clearError: true));
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to add expense.',
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _onExpenseUpdated(
    ExpenseUpdated event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      final ExpenseModel updatedExpense = event.expense.copyWith(
        amount: event.amount,
        categoryName: event.categoryName,
        categoryIconCodePoint: event.categoryIconCodePoint,
        categoryColorValue: event.categoryColorValue,
        date: event.date,
        notes: event.notes,
        paymentMethod: event.paymentMethod,
        updatedAt: DateTime.now(),
      );
      await _repository.updateExpense(updatedExpense);
      emit(
        state.copyWith(successMessage: 'Expense updated.', clearError: true),
      );
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to update expense.',
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _onExpenseDeleted(
    ExpenseDeleted event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      await _repository.deleteExpense(event.id);
      emit(
        state.copyWith(successMessage: 'Expense deleted.', clearError: true),
      );
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Failed to delete expense.',
          clearSuccess: true,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _expensesSubscription?.cancel();
    return super.close();
  }

  ExpenseState _buildStateFromExpenses(
    List<ExpenseModel> expenses,
    ReportFilter filter,
    ExpenseState currentState,
  ) {
    final DateTime now = DateTime.now();
    final double totalSpending = expenses.fold<double>(
      0,
      (double total, ExpenseModel expense) => total + expense.amount,
    );
    final double monthlySpending = expenses
        .where(
          (ExpenseModel expense) =>
              expense.date.year == now.year && expense.date.month == now.month,
        )
        .fold<double>(
          0,
          (double total, ExpenseModel expense) => total + expense.amount,
        );
    final List<ExpenseModel> recentExpenses = expenses.take(5).toList();
    final Map<String, double> categorySpending = _buildCategorySpending(
      expenses,
    );
    final List<SpendingTrendPoint> trendSpending = _buildTrendSpending(
      expenses,
      filter,
      now,
    );

    final List<ExpenseModel> filteredRecentExpenses =
        _buildFilteredRecentExpenses(
          expenses,
          filter,
          currentState.selectedCategoryFilter,
          currentState.selectedTrendLabel,
        );

    return currentState.copyWith(
      expenses: expenses,
      recentExpenses: recentExpenses,
      filteredRecentExpenses: filteredRecentExpenses,
      categorySpending: categorySpending,
      trendSpending: trendSpending,
      reportFilter: filter,
      totalSpending: totalSpending,
      monthlySpending: monthlySpending,
      isLoading: false,
      clearError: true,
      clearSuccess: true,
    );
  }

  List<ExpenseModel> _buildFilteredRecentExpenses(
    List<ExpenseModel> expenses,
    ReportFilter reportFilter,
    String? categoryFilter,
    String? trendLabel,
  ) {
    Iterable<ExpenseModel> filtered = expenses;

    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      filtered = filtered.where(
        (ExpenseModel expense) => expense.categoryName == categoryFilter,
      );
    }
    if (trendLabel != null && trendLabel.isNotEmpty) {
      filtered = filtered.where(
        (ExpenseModel expense) =>
            _matchesTrendLabel(expense.date, reportFilter, trendLabel),
      );
    }
    return filtered.take(5).toList(growable: false);
  }

  bool _matchesTrendLabel(DateTime date, ReportFilter filter, String label) {
    switch (filter) {
      case ReportFilter.daily:
        return DateFormat('dd MMM').format(date) == label;
      case ReportFilter.weekly:
        final DateTime weekStart = DateTime(
          date.year,
          date.month,
          date.day - date.weekday + 1,
        );
        return DateFormat('dd MMM').format(weekStart) == label;
      case ReportFilter.monthly:
        return DateFormat(
              'MMM yy',
            ).format(DateTime(date.year, date.month, 1)) ==
            label;
    }
  }

  Map<String, double> _buildCategorySpending(List<ExpenseModel> expenses) {
    final Map<String, double> categoryTotals = <String, double>{};
    for (final ExpenseModel expense in expenses) {
      categoryTotals.update(
        expense.categoryName,
        (double current) => current + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return Map<String, double>.unmodifiable(categoryTotals);
  }

  List<SpendingTrendPoint> _buildTrendSpending(
    List<ExpenseModel> expenses,
    ReportFilter filter,
    DateTime now,
  ) {
    switch (filter) {
      case ReportFilter.daily:
        return _dailyTrend(expenses, now);
      case ReportFilter.weekly:
        return _weeklyTrend(expenses, now);
      case ReportFilter.monthly:
        return _monthlyTrend(expenses, now);
    }
  }

  List<SpendingTrendPoint> _dailyTrend(
    List<ExpenseModel> expenses,
    DateTime now,
  ) {
    final List<DateTime> days = List<DateTime>.generate(7, (int index) {
      final DateTime day = now.subtract(Duration(days: 6 - index));
      return DateTime(day.year, day.month, day.day);
    });
    final Map<String, double> totals = <String, double>{
      for (final DateTime day in days) DateFormat('dd MMM').format(day): 0,
    };

    for (final ExpenseModel expense in expenses) {
      final DateTime day = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      final String key = DateFormat('dd MMM').format(day);
      if (totals.containsKey(key)) {
        totals[key] = totals[key]! + expense.amount;
      }
    }
    return totals.entries
        .map(
          (MapEntry<String, double> e) =>
              SpendingTrendPoint(label: e.key, amount: e.value),
        )
        .toList(growable: false);
  }

  List<SpendingTrendPoint> _weeklyTrend(
    List<ExpenseModel> expenses,
    DateTime now,
  ) {
    final LinkedHashMap<String, double> totals =
        LinkedHashMap<String, double>();
    for (int i = 7; i >= 0; i--) {
      final DateTime weekStart = DateTime(
        now.year,
        now.month,
        now.day - now.weekday + 1 - (i * 7),
      );
      final String key = DateFormat('dd MMM').format(weekStart);
      totals[key] = 0;
    }

    for (final ExpenseModel expense in expenses) {
      final DateTime weekStart = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day - expense.date.weekday + 1,
      );
      final String key = DateFormat('dd MMM').format(weekStart);
      if (totals.containsKey(key)) {
        totals[key] = totals[key]! + expense.amount;
      }
    }
    return totals.entries
        .map(
          (MapEntry<String, double> e) =>
              SpendingTrendPoint(label: e.key, amount: e.value),
        )
        .toList(growable: false);
  }

  List<SpendingTrendPoint> _monthlyTrend(
    List<ExpenseModel> expenses,
    DateTime now,
  ) {
    final LinkedHashMap<String, double> totals =
        LinkedHashMap<String, double>();
    for (int i = 5; i >= 0; i--) {
      final DateTime monthDate = DateTime(now.year, now.month - i, 1);
      final String key = DateFormat('MMM yy').format(monthDate);
      totals[key] = 0;
    }

    for (final ExpenseModel expense in expenses) {
      final String key = DateFormat(
        'MMM yy',
      ).format(DateTime(expense.date.year, expense.date.month, 1));
      if (totals.containsKey(key)) {
        totals[key] = totals[key]! + expense.amount;
      }
    }
    return totals.entries
        .map(
          (MapEntry<String, double> e) =>
              SpendingTrendPoint(label: e.key, amount: e.value),
        )
        .toList(growable: false);
  }
}
