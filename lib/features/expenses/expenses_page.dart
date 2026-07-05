import 'package:expense_tracker/core/widgets/app_snackbar.dart';
import 'package:expense_tracker/features/budgets/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/data/budget_repository.dart';
import 'package:expense_tracker/features/budgets/models/budget_model.dart';
import 'package:expense_tracker/features/categories/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/data/category_repository.dart';
import 'package:expense_tracker/features/categories/models/category_model.dart';
import 'package:expense_tracker/features/expenses/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expenses/bloc/expense_event.dart';
import 'package:expense_tracker/features/expenses/bloc/expense_state.dart';
import 'package:expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:expense_tracker/features/expenses/models/expense_model.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_add_view.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_dialogs.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_helpers.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_home_view.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_notifications_view.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_profile_view.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_stats_view.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_summary_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ExpenseBloc>(
          create: (_) =>
              ExpenseBloc(ExpenseRepository())
                ..add(const WatchExpensesRequested()),
        ),
        BlocProvider<CategoryBloc>(
          create: (_) =>
              CategoryBloc(CategoryRepository())
                ..add(const WatchCategoriesRequested()),
        ),
        BlocProvider<BudgetBloc>(
          create: (_) =>
              BudgetBloc(BudgetRepository())
                ..add(WatchBudgetsRequested(_currentMonthKey())),
        ),
      ],
      child: const _Shell(),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell();

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int tab = 0;
  final TextEditingController amount = TextEditingController();
  final TextEditingController notes = TextEditingController();
  String payment = 'Cash';
  DateTime date = DateTime.now();
  CategoryModel? category;
  String? _pendingCategoryName;
  final Set<String> _shownBudgetAlerts = <String>{};

  @override
  void dispose() {
    amount.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<ExpenseBloc, ExpenseState>(
          listenWhen: (ExpenseState a, ExpenseState b) =>
              a.errorMessage != b.errorMessage ||
              a.successMessage != b.successMessage,
          listener: (BuildContext context, ExpenseState s) {
            final String? m = s.errorMessage ?? s.successMessage;
            if (m == null) return;
            showAppSnackBar(
              context,
              m,
              isError: s.errorMessage != null,
            );
          },
        ),
        BlocListener<CategoryBloc, CategoryState>(
          listenWhen: (CategoryState a, CategoryState b) =>
              a.errorMessage != b.errorMessage ||
              a.successMessage != b.successMessage,
          listener: (BuildContext context, CategoryState s) {
            final String? m = s.errorMessage ?? s.successMessage;
            if (m == null) return;
            showAppSnackBar(
              context,
              m,
              isError: s.errorMessage != null,
            );
          },
        ),
        BlocListener<BudgetBloc, BudgetState>(
          listenWhen: (BudgetState a, BudgetState b) =>
              a.errorMessage != b.errorMessage ||
              a.successMessage != b.successMessage,
          listener: (BuildContext context, BudgetState s) {
            final String? m = s.errorMessage ?? s.successMessage;
            if (m == null) return;
            showAppSnackBar(
              context,
              m,
              isError: s.errorMessage != null,
            );
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(child: _content()),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (int i) => setState(() => tab = i),
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.summarize_outlined),
              label: 'Summary',
            ),
            NavigationDestination(
              icon: Icon(Icons.query_stats),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              label: 'Add',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (BuildContext context, ExpenseState state) {
        switch (tab) {
          case 1:
            return _summary(state);
          case 2:
            return _stats(state);
          case 3:
            return _addExpense();
          case 4:
            return _profile();
          case 5:
            return _notifications(state);
          default:
            return _home(state);
        }
      },
    );
  }

  Widget _notifications(ExpenseState state) {
    final List<String> reminders = _buildHomeReminders(state);
    return ExpenseNotificationsView(reminders: reminders);
  }

  Widget _home(ExpenseState state) {
    final List<CategoryModel> categories = context
        .read<CategoryBloc>()
        .state
        .categories;
    final List<String> reminders = _buildHomeReminders(state);
    return ExpenseHomeView(
      state: state,
      onRefresh: _refreshExpenses,
      onEditExpense: (ExpenseModel expense) =>
          _showEditExpenseDialog(expense, categories),
      onDeleteExpense: _deleteExpense,
      formatCurrency: formatCurrency,
      reminders: reminders,
      onNotificationTap: () => setState(() => tab = 5),
    );
  }

  Future<void> _refreshExpenses() async {
    context.read<ExpenseBloc>().add(const WatchExpensesRequested());
  }

  Future<void> _deleteExpense(ExpenseModel expense) async {
    final bool shouldDelete = await showDeleteExpenseConfirmation(
      context: context,
      expense: expense,
      formatCurrency: formatCurrency,
    );
    if (!shouldDelete || !mounted) return;
    context.read<ExpenseBloc>().add(ExpenseDeleted(expense.id));
  }

  Widget _summary(ExpenseState state) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (BuildContext context, BudgetState budgetState) {
        final List<String> budgetAlerts = _buildBudgetAlerts(state, budgetState);
        final List<String> aiAdvisorMessages = _buildAiAdvisorMessages(state);
        _notifyNewBudgetAlerts(budgetAlerts);
        return ExpenseSummaryView(
          state: state,
          budgets: budgetState.budgets,
          formatCurrency: formatCurrency,
          onSetBudgetTapped: _showSetBudgetDialog,
          aiAdvisorMessages: aiAdvisorMessages,
        );
      },
    );
  }

  Widget _stats(ExpenseState state) {
    return ExpenseStatsView(
      state: state,
      onFilterChanged: (ReportFilter filter) {
        context.read<ExpenseBloc>().add(ReportFilterChanged(filter));
      },
    );
  }

  Widget _addExpense() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (BuildContext context, CategoryState cState) {
        final List<CategoryModel> categories = cState.categories;
        if (_pendingCategoryName != null) {
          final String expected = _pendingCategoryName!.toLowerCase();
          final CategoryModel? createdCategory = categories
              .where(
                (CategoryModel c) => c.name.toLowerCase() == expected,
              )
              .firstOrNull;
          if (createdCategory != null) {
            category = createdCategory;
            _pendingCategoryName = null;
          }
        }
        category ??= categories.isNotEmpty ? categories.first : null;
        return ExpenseAddView(
          categories: categories,
          selectedCategory: category,
          onCategoryChanged: (CategoryModel? value) {
            setState(() => category = value);
          },
          onAddCustomCategory: _showAddCustomCategoryDialog,
          amountController: amount,
          selectedPayment: payment,
          paymentOptions: paymentOptions,
          onPaymentChanged: (String? value) {
            setState(() => payment = value ?? payment);
          },
          selectedDate: date,
          onPickDate: _pickDate,
          onDateChanged: (DateTime value) {
            setState(() => date = value);
          },
          notesController: notes,
          onSaveExpense: _saveExpense,
        );
      },
    );
  }

  void _saveExpense() {
    final double? value = double.tryParse(amount.text.trim());
    if (value == null || value <= 0 || category == null) return;
    context.read<ExpenseBloc>().add(
      ExpenseAdded(
        amount: value,
        categoryName: category!.name,
        categoryIconCodePoint: category!.iconCodePoint,
        categoryColorValue: category!.colorValue,
        date: date,
        notes: notes.text.trim(),
        paymentMethod: payment,
      ),
    );
    setState(_resetCreateForm);
  }

  Widget _profile() {
    final User? user = FirebaseAuth.instance.currentUser;
    return ExpenseProfileView(
      email: user?.email ?? 'Guest',
      onLogout: () => FirebaseAuth.instance.signOut(),
    );
  }

  Future<void> _showEditExpenseDialog(
    ExpenseModel expense,
    List<CategoryModel> categories,
  ) async {
    await showExpenseEditDialog(
      context: context,
      expense: expense,
      categories: categories,
      onPickDate: _pickDate,
      onSave: (ExpenseEditData data) {
        context.read<ExpenseBloc>().add(
          ExpenseUpdated(
            expense: expense,
            amount: data.amount,
            categoryName: data.category.name,
            categoryIconCodePoint: data.category.iconCodePoint,
            categoryColorValue: data.category.colorValue,
            date: data.date,
            notes: data.notes,
            paymentMethod: data.paymentMethod,
          ),
        );
      },
    );
  }

  Future<DateTime?> _pickDate(DateTime initialDate) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
  }

  void _resetCreateForm() {
    amount.clear();
    notes.clear();
    payment = paymentOptions.first;
    date = DateTime.now();
  }
  Future<void> _showAddCustomCategoryDialog() async {
    final TextEditingController nameController = TextEditingController();
    IconData selectedIcon = Icons.category;
    Color selectedColor = Colors.teal;
    const List<IconData> iconChoices = <IconData>[
      Icons.category,
      Icons.restaurant,
      Icons.directions_bus,
      Icons.shopping_bag,
      Icons.receipt_long,
      Icons.local_hospital,
      Icons.movie,
      Icons.school,
    ];
    const List<Color> colorChoices = <Color>[
      Colors.teal,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.pink,
      Colors.indigo,
    ];

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return AlertDialog(
              title: const Text('Add custom category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category name',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Pick icon'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: iconChoices.map((IconData icon) {
                        final bool selected = selectedIcon == icon;
                        return ChoiceChip(
                          label: Icon(icon, size: 18),
                          selected: selected,
                          onSelected: (_) {
                            setModalState(() => selectedIcon = icon);
                          },
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: 14),
                    const Text('Pick color'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: colorChoices.map((Color color) {
                        final bool selected = selectedColor == color;
                        return ChoiceChip(
                          label: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          ),
                          selected: selected,
                          onSelected: (_) {
                            setModalState(() => selectedColor = color);
                          },
                        );
                      }).toList(growable: false),
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
                    final String name = nameController.text.trim();
                    if (name.isEmpty) return;
                    _pendingCategoryName = name;
                    this.context.read<CategoryBloc>().add(
                      CustomCategoryAdded(
                        name: name,
                        iconCodePoint: selectedIcon.codePoint,
                        colorValue: selectedColor.toARGB32(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
  }

  String? _todayReminder(ExpenseState state) {
    final DateTime now = DateTime.now();
    final bool hasTodayExpense = state.expenses.any(
      (ExpenseModel e) =>
          e.date.year == now.year && e.date.month == now.month && e.date.day == now.day,
    );
    if (hasTodayExpense) return null;
    return 'Don\'t forget to log your expenses today';
  }

  List<String> _buildHomeReminders(ExpenseState state) {
    final List<String> reminders = <String>[];
    final String? today = _todayReminder(state);
    if (today != null) reminders.add(today);
    reminders.addAll(_buildBudgetAlerts(state, context.read<BudgetBloc>().state));
    return reminders;
  }

  List<String> _buildBudgetAlerts(ExpenseState expenseState, BudgetState budgetState) {
    final Map<String, double> monthlyByCategory = <String, double>{};
    final DateTime now = DateTime.now();
    for (final ExpenseModel e in expenseState.expenses) {
      if (e.date.year != now.year || e.date.month != now.month) continue;
      monthlyByCategory.update(
        e.categoryName,
        (double current) => current + e.amount,
        ifAbsent: () => e.amount,
      );
    }

    final List<String> alerts = <String>[];
    for (final BudgetModel budget in budgetState.budgets) {
      final double spent = monthlyByCategory[budget.categoryName] ?? 0;
      if (budget.limitAmount <= 0) continue;
      final double ratio = spent / budget.limitAmount;
      if (ratio >= 1) {
        alerts.add('You exceeded your ${budget.categoryName} budget');
      } else if (ratio >= 0.9) {
        alerts.add('You are close to your ${budget.categoryName} budget');
      }
    }
    return alerts;
  }

  List<String> _buildAiAdvisorMessages(ExpenseState state) {
    final DateTime now = DateTime.now();
    final DateTime startOfCurrentWeek = DateTime(
      now.year,
      now.month,
      now.day - now.weekday + 1,
    );
    final DateTime startOfPreviousWeek = startOfCurrentWeek.subtract(
      const Duration(days: 7),
    );

    final Iterable<ExpenseModel> monthlyExpenses = state.expenses.where(
      (ExpenseModel expense) =>
          expense.date.year == now.year && expense.date.month == now.month,
    );
    final double monthlyTotal = monthlyExpenses.fold<double>(
      0,
      (double total, ExpenseModel e) => total + e.amount,
    );

    final double monthlyFood = monthlyExpenses
        .where((ExpenseModel e) => e.categoryName.toLowerCase() == 'food')
        .fold<double>(0, (double total, ExpenseModel e) => total + e.amount);

    final List<String> messages = <String>[];

    if (monthlyTotal > 0) {
      final double foodRatio = monthlyFood / monthlyTotal;
      if (foodRatio > 0.4) {
        final int foodPercent = (foodRatio * 100).round();
        messages.add(
          'You spent $foodPercent% of this month on food. Try reducing restaurant visits to save Rs. 2000/month.',
        );
      }
    }

    final double thisWeekFood = state.expenses
        .where(
          (ExpenseModel e) =>
              e.categoryName.toLowerCase() == 'food' &&
              !e.date.isBefore(startOfCurrentWeek) &&
              !e.date.isAfter(now),
        )
        .fold<double>(0, (double total, ExpenseModel e) => total + e.amount);

    final double lastWeekFood = state.expenses
        .where(
          (ExpenseModel e) =>
              e.categoryName.toLowerCase() == 'food' &&
              !e.date.isBefore(startOfPreviousWeek) &&
              e.date.isBefore(startOfCurrentWeek),
        )
        .fold<double>(0, (double total, ExpenseModel e) => total + e.amount);

    if (lastWeekFood > 0 && thisWeekFood > lastWeekFood * 1.3) {
      final int increasePercent = (((thisWeekFood - lastWeekFood) / lastWeekFood) * 100)
          .round();
      messages.add(
        'You spent $increasePercent% more on food this week compared to last week.',
      );
    }

    final Map<String, double> monthlyByPayment = <String, double>{};
    for (final ExpenseModel expense in monthlyExpenses) {
      monthlyByPayment.update(
        expense.paymentMethod,
        (double current) => current + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    final double cardSpend = monthlyByPayment['Card'] ?? 0;
    if (monthlyTotal > 0 && cardSpend / monthlyTotal > 0.6) {
      messages.add(
        'Most spending is through card payments. Track impulse purchases and set stricter limits.',
      );
    }

    return messages;
  }

  void _notifyNewBudgetAlerts(List<String> alerts) {
    for (final String message in alerts) {
      if (_shownBudgetAlerts.contains(message)) continue;
      _shownBudgetAlerts.add(message);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showAppSnackBar(context, message, isError: true);
      });
    }
  }

  Future<void> _showSetBudgetDialog(String categoryName) async {
    final BudgetState budgetState = context.read<BudgetBloc>().state;
    final BudgetModel? existing = budgetState.budgets
        .where((BudgetModel b) => b.categoryName.toLowerCase() == categoryName.toLowerCase())
        .firstOrNull;
    String amountText = existing?.limitAmount.toStringAsFixed(0) ?? '';
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set $categoryName budget'),
          content: TextFormField(
            initialValue: amountText,
            onChanged: (String value) => amountText = value,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monthly budget (Rs)',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final double? amount = double.tryParse(amountText.trim());
                if (amount == null || amount <= 0) return;
                this.context.read<BudgetBloc>().add(
                  BudgetSaved(
                    categoryName: categoryName,
                    limitAmount: amount,
                    monthKey: _currentMonthKey(),
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
  }

}

String _currentMonthKey() {
  final DateTime now = DateTime.now();
  final String month = now.month.toString().padLeft(2, '0');
  return '${now.year}-$month';
}
