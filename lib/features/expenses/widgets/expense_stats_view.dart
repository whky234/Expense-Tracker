import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/widgets/app_section_header.dart';
import 'package:expense_tracker/features/expenses/bloc/expense_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpenseStatsView extends StatelessWidget {
  const ExpenseStatsView({
    required this.state,
    required this.onFilterChanged,
    super.key,
  });

  final ExpenseState state;
  final ValueChanged<ReportFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final List<SpendingTrendPoint> points = state.trendSpending;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: <Widget>[
        const AppSectionHeader(
          title: 'Statistics',
          subtitle: 'Professional chart view',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: <Widget>[
            ChoiceChip(
              label: const Text('Day'),
              selected: state.reportFilter == ReportFilter.daily,
              onSelected: (_) => onFilterChanged(ReportFilter.daily),
            ),
            ChoiceChip(
              label: const Text('Week'),
              selected: state.reportFilter == ReportFilter.weekly,
              onSelected: (_) => onFilterChanged(ReportFilter.weekly),
            ),
            ChoiceChip(
              label: const Text('Month'),
              selected: state.reportFilter == ReportFilter.monthly,
              onSelected: (_) => onFilterChanged(ReportFilter.monthly),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: SizedBox(
            height: 240,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  lineBarsData: <LineChartBarData>[
                    LineChartBarData(
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.18),
                      ),
                      spots: List<FlSpot>.generate(
                        points.length,
                        (int i) => FlSpot(i.toDouble(), points[i].amount),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
