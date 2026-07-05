import 'package:expense_tracker/features/categories/models/category_model.dart';
import 'package:expense_tracker/features/expenses/models/expense_model.dart';
import 'package:intl/intl.dart';

const List<String> paymentOptions = <String>[
  'Cash',
  'Card',
  'UPI',
  'Bank Transfer',
  'Other',
];

String formatCurrency(double value) {
  return NumberFormat.currency(symbol: 'Rs ').format(value);
}

Map<String, double> buildPaymentSummary(List<ExpenseModel> expenses) {
  final Map<String, double> summary = <String, double>{};
  for (final ExpenseModel expense in expenses) {
    summary.update(
      expense.paymentMethod,
      (double current) => current + expense.amount,
      ifAbsent: () => expense.amount,
    );
  }
  return summary;
}

CategoryModel? resolveCategoryForExpense(
  ExpenseModel expense,
  List<CategoryModel> categories,
) {
  for (final CategoryModel c in categories) {
    if (c.name == expense.categoryName &&
        c.iconCodePoint == expense.categoryIconCodePoint &&
        c.colorValue == expense.categoryColorValue) {
      return c;
    }
  }
  if (categories.isEmpty) return null;
  return categories.first;
}
