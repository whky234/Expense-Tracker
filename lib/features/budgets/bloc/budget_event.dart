import 'package:expense_tracker/features/budgets/models/budget_model.dart';

abstract class BudgetEvent {
  const BudgetEvent();
}

class WatchBudgetsRequested extends BudgetEvent {
  const WatchBudgetsRequested(this.monthKey);

  final String monthKey;
}

class BudgetsChanged extends BudgetEvent {
  const BudgetsChanged(this.budgets);

  final List<BudgetModel> budgets;
}

class BudgetsWatchFailed extends BudgetEvent {
  const BudgetsWatchFailed();
}

class BudgetSaved extends BudgetEvent {
  const BudgetSaved({
    required this.categoryName,
    required this.limitAmount,
    required this.monthKey,
  });

  final String categoryName;
  final double limitAmount;
  final String monthKey;
}
