import 'package:expense_tracker/features/categories/models/category_model.dart';
import 'package:expense_tracker/features/expenses/models/expense_model.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_helpers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseEditData {
  const ExpenseEditData({
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.date,
    required this.notes,
  });

  final double amount;
  final CategoryModel category;
  final String paymentMethod;
  final DateTime date;
  final String notes;
}

Future<void> showExpenseEditDialog({
  required BuildContext context,
  required ExpenseModel expense,
  required List<CategoryModel> categories,
  required Future<DateTime?> Function(DateTime initialDate) onPickDate,
  required ValueChanged<ExpenseEditData> onSave,
}) async {
  String amountText = expense.amount.toStringAsFixed(2);
  String notesText = expense.notes;
  CategoryModel? selectedCategory = resolveCategoryForExpense(expense, categories);
  String selectedPayment = expense.paymentMethod;
  DateTime selectedDate = expense.date;

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return AlertDialog(
            title: const Text('Edit Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<CategoryModel>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories
                        .map(
                          (CategoryModel c) => DropdownMenuItem<CategoryModel>(
                            value: c,
                            child: Text(c.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (CategoryModel? c) {
                      setModalState(() => selectedCategory = c);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: amountText,
                    onChanged: (String value) => amountText = value,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'Rs ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPayment,
                    decoration: const InputDecoration(labelText: 'Payment'),
                    items: paymentOptions
                        .map(
                          (String p) => DropdownMenuItem<String>(
                            value: p,
                            child: Text(p),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (String? p) {
                      setModalState(() => selectedPayment = p ?? selectedPayment);
                    },
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final DateTime? picked = await onPickDate(selectedDate);
                      if (picked == null) return;
                      setModalState(() => selectedDate = picked);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: notesText,
                    onChanged: (String value) => notesText = value,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final double? parsedAmount = double.tryParse(
                    amountText.trim(),
                  );
                  if (parsedAmount == null ||
                      parsedAmount <= 0 ||
                      selectedCategory == null) {
                    return;
                  }
                  onSave(
                    ExpenseEditData(
                      amount: parsedAmount,
                      category: selectedCategory!,
                      paymentMethod: selectedPayment,
                      date: selectedDate,
                      notes: notesText.trim(),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<bool> showDeleteExpenseConfirmation({
  required BuildContext context,
  required ExpenseModel expense,
  required String Function(double value) formatCurrency,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete expense?'),
        content: Text(
          'Delete ${expense.categoryName} expense of ${formatCurrency(expense.amount)}?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
