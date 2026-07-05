import 'package:expense_tracker/core/widgets/app_button.dart';
import 'package:expense_tracker/core/widgets/app_section_header.dart';
import 'package:expense_tracker/core/widgets/app_text_input.dart';
import 'package:expense_tracker/features/categories/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseAddView extends StatelessWidget {
  const ExpenseAddView({
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onAddCustomCategory,
    required this.amountController,
    required this.selectedPayment,
    required this.paymentOptions,
    required this.onPaymentChanged,
    required this.selectedDate,
    required this.onPickDate,
    required this.onDateChanged,
    required this.notesController,
    required this.onSaveExpense,
    super.key,
  });

  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel?> onCategoryChanged;
  final VoidCallback onAddCustomCategory;
  final TextEditingController amountController;
  final String selectedPayment;
  final List<String> paymentOptions;
  final ValueChanged<String?> onPaymentChanged;
  final DateTime selectedDate;
  final Future<DateTime?> Function(DateTime initialDate) onPickDate;
  final ValueChanged<DateTime> onDateChanged;
  final TextEditingController notesController;
  final VoidCallback onSaveExpense;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        const AppSectionHeader(
          title: 'Add Expense',
          subtitle: 'Simple and clean form',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
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
                  onChanged: onCategoryChanged,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onAddCustomCategory,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add custom category'),
                  ),
                ),
                const SizedBox(height: 10),
                AppTextInput(
                  controller: amountController,
                  labelText: 'Amount',
                  prefixText: 'Rs ',
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
                  onChanged: onPaymentChanged,
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final DateTime? picked = await onPickDate(selectedDate);
                    if (picked == null || !context.mounted) return;
                    onDateChanged(picked);
                  },
                ),
                const SizedBox(height: 10),
                AppTextInput(
                  controller: notesController,
                  labelText: 'Notes',
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                AppPrimaryButton(
                  label: 'Save Expense',
                  onPressed: onSaveExpense,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
