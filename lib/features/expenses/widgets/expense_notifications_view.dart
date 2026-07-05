import 'package:expense_tracker/core/widgets/app_section_header.dart';
import 'package:flutter/material.dart';

class ExpenseNotificationsView extends StatelessWidget {
  const ExpenseNotificationsView({
    required this.reminders,
    super.key,
  });

  final List<String> reminders;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        const AppSectionHeader(
          title: 'Notifications',
          subtitle: 'Your reminders and alerts',
        ),
        const SizedBox(height: 12),
        if (reminders.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No reminders right now. Great job!'),
            ),
          )
        else
          ...reminders.map(
            (String reminder) => Card(
              color: const Color(0xFFFFF4E5),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('⚠️ $reminder'),
              ),
            ),
          ),
      ],
    );
  }
}
