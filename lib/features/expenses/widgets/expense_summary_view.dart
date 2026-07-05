import 'package:expense_tracker/core/widgets/app_metric_card.dart';
import 'package:expense_tracker/core/widgets/app_section_header.dart';
import 'package:expense_tracker/features/budgets/models/budget_model.dart';
import 'package:expense_tracker/features/expenses/bloc/expense_state.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_helpers.dart';
import 'package:flutter/material.dart';

class ExpenseSummaryView extends StatelessWidget {
  const ExpenseSummaryView({
    required this.state,
    required this.budgets,
    required this.formatCurrency,
    required this.onSetBudgetTapped,
    required this.aiAdvisorMessages,
    super.key,
  });

  final ExpenseState state;
  final List<BudgetModel> budgets;
  final String Function(double value) formatCurrency;
  final void Function(String categoryName) onSetBudgetTapped;
  final List<String> aiAdvisorMessages;

  @override
  Widget build(BuildContext context) {
    final Map<String, double> paymentSummary = buildPaymentSummary(
      state.expenses,
    );
    final List<MapEntry<String, double>> categories = state.categorySpending
        .entries
        .toList(growable: false)
      ..sort((MapEntry<String, double> a, MapEntry<String, double> b) {
        return b.value.compareTo(a.value);
      });

    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        const AppSectionHeader(
          title: 'Summary',
          subtitle: 'Quick financial insights',
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: AppMetricCard(
                title: 'Total Spending',
                value: formatCurrency(state.totalSpending),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppMetricCard(
                title: 'Monthly Spending',
                value: formatCurrency(state.monthlySpending),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'AI Spending Advisor',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (aiAdvisorMessages.isEmpty)
                  const Text('No insights yet. Add more expenses to get advice.')
                else
                  ...aiAdvisorMessages.map(
                    (String message) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('• $message'),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Monthly Budgets',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (state.categorySpending.isEmpty)
                  const Text('Add expenses to set budgets')
                else
                  ...state.categorySpending.entries
                      .toList(growable: false)
                      .take(6)
                      .map((MapEntry<String, double> categorySpend) {
                        final BudgetModel? budget = budgets
                            .where(
                              (BudgetModel b) =>
                                  b.categoryName.toLowerCase() ==
                                  categorySpend.key.toLowerCase(),
                            )
                            .firstOrNull;
                        final String budgetText = budget == null
                            ? 'Not set'
                            : formatCurrency(budget.limitAmount);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(categorySpend.key),
                          subtitle: Text(
                            'Spent ${formatCurrency(categorySpend.value)} / Budget $budgetText',
                          ),
                          trailing: TextButton(
                            onPressed: () => onSetBudgetTapped(categorySpend.key),
                            child: Text(budget == null ? 'Set' : 'Edit'),
                          ),
                        );
                      }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _SummaryCard(
          title: 'By Category',
          data: categories.take(5).toList(growable: false),
          emptyText: 'No category data yet',
          formatCurrency: formatCurrency,
        ),
        const SizedBox(height: 10),
        _SummaryCard(
          title: 'By Payment Method',
          data: paymentSummary.entries.toList(growable: false),
          emptyText: 'No payment data yet',
          formatCurrency: formatCurrency,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.data,
    required this.emptyText,
    required this.formatCurrency,
  });

  final String title;
  final List<MapEntry<String, double>> data;
  final String emptyText;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (data.isEmpty)
              Text(emptyText)
            else
              ListView.builder(
                itemCount: data.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final MapEntry<String, double> e = data[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(e.key)),
                        Text(formatCurrency(e.value)),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
