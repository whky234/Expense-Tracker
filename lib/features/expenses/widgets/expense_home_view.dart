import 'package:expense_tracker/core/widgets/app_metric_card.dart';
import 'package:expense_tracker/core/widgets/app_section_header.dart';
import 'package:expense_tracker/features/expenses/bloc/expense_state.dart';
import 'package:expense_tracker/features/expenses/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseHomeView extends StatelessWidget {
  const ExpenseHomeView({
    required this.state,
    required this.onRefresh,
    required this.onEditExpense,
    required this.onDeleteExpense,
    required this.formatCurrency,
    required this.reminders,
    required this.onNotificationTap,
    super.key,
  });

  final ExpenseState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function(ExpenseModel expense) onEditExpense;
  final Future<void> Function(ExpenseModel expense) onDeleteExpense;
  final String Function(double value) formatCurrency;
  final List<String> reminders;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final List<ExpenseModel> expenses = state.filteredRecentExpenses;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(14),
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Home',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              Badge(
                isLabelVisible: reminders.isNotEmpty,
                label: Text('${reminders.length}'),
                child: IconButton(
                  onPressed: onNotificationTap,
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: 'Reminders',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const AppSectionHeader(
            title: 'Homepage',
            subtitle: 'Neat and clean overview',
          ),
          if (reminders.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            ...reminders
                .take(2)
                .map((String message) => _ReminderCard(message: message)),
          ],
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: AppMetricCard(
                  title: 'Total',
                  value: formatCurrency(state.totalSpending),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppMetricCard(
                  title: 'Month',
                  value: formatCurrency(state.monthlySpending),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (expenses.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No data'),
              ),
            )
          else
            ...expenses.map(
              (ExpenseModel expense) => _ExpenseTile(
                expense: expense,
                formatCurrency: formatCurrency,
                onEdit: () => onEditExpense(expense),
                onDelete: () => onDeleteExpense(expense),
              ),
            ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF4E5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          '⚠️ $message',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.formatCurrency,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseModel expense;
  final String Function(double value) formatCurrency;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(expense.categoryColorValue).withValues(alpha: 0.2),
        child: Icon(
          IconData(expense.categoryIconCodePoint, fontFamily: 'MaterialIcons'),
          color: Color(expense.categoryColorValue),
        ),
      ),
      title: Text(expense.categoryName),
      subtitle: Text(
        '${DateFormat('dd MMM yyyy').format(expense.date)} • ${expense.paymentMethod}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (String value) async {
          if (value == 'edit') {
            await onEdit();
            return;
          }
          if (value == 'delete') {
            await onDelete();
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
          const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(formatCurrency(expense.amount)),
            const SizedBox(height: 4),
            const Icon(Icons.more_vert, size: 16),
          ],
        ),
      ),
    );
  }
}
