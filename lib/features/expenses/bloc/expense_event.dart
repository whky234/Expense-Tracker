import 'package:expense_tracker/features/expenses/models/expense_model.dart';
import 'package:expense_tracker/features/expenses/bloc/expense_state.dart';

abstract class ExpenseEvent {
  const ExpenseEvent();
}

class WatchExpensesRequested extends ExpenseEvent {
  const WatchExpensesRequested();
}

class ExpenseAdded extends ExpenseEvent {
  const ExpenseAdded({
    required this.amount,
    required this.categoryName,
    required this.categoryIconCodePoint,
    required this.categoryColorValue,
    required this.date,
    required this.notes,
    required this.paymentMethod,
  });

  final double amount;
  final String categoryName;
  final int categoryIconCodePoint;
  final int categoryColorValue;
  final DateTime date;
  final String notes;
  final String paymentMethod;
}

class ExpenseUpdated extends ExpenseEvent {
  const ExpenseUpdated({
    required this.expense,
    required this.amount,
    required this.categoryName,
    required this.categoryIconCodePoint,
    required this.categoryColorValue,
    required this.date,
    required this.notes,
    required this.paymentMethod,
  });

  final ExpenseModel expense;
  final double amount;
  final String categoryName;
  final int categoryIconCodePoint;
  final int categoryColorValue;
  final DateTime date;
  final String notes;
  final String paymentMethod;
}

class ExpenseDeleted extends ExpenseEvent {
  const ExpenseDeleted(this.id);

  final String id;
}

class ExpensesChanged extends ExpenseEvent {
  const ExpensesChanged(this.expenses);

  final List<ExpenseModel> expenses;
}

class ExpensesWatchFailed extends ExpenseEvent {
  const ExpensesWatchFailed();
}

class ReportFilterChanged extends ExpenseEvent {
  const ReportFilterChanged(this.filter);

  final ReportFilter filter;
}

class CategorySegmentTapped extends ExpenseEvent {
  const CategorySegmentTapped(this.categoryName);

  final String categoryName;
}

class TrendBarTapped extends ExpenseEvent {
  const TrendBarTapped(this.trendLabel);

  final String trendLabel;
}

class ReportTransactionFiltersCleared extends ExpenseEvent {
  const ReportTransactionFiltersCleared();
}
