import 'package:expense_tracker/core/widgets/app_section_header.dart';
import 'package:flutter/material.dart';

class ExpenseProfileView extends StatelessWidget {
  const ExpenseProfileView({
    required this.email,
    required this.onLogout,
    super.key,
  });

  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        const AppSectionHeader(
          title: 'Profile',
          subtitle: 'Account and settings',
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(email),
            subtitle: const Text('Signed in account'),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}
