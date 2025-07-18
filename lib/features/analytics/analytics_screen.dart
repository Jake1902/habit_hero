import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../core/analytics/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsService>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final service = context.watch<AnalyticsService>();
    final overall = service.overall;
    final totals = service.last7Totals;

    List<FlSpot> spots = [];
    for (var i = 0; i < totals.length; i++) {
      spots.add(FlSpot(i.toDouble(), totals[i].toDouble()));
    }

    return Scaffold(
      backgroundColor: scheme.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: scheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          StatCard(
            icon: Icons.check,
            value: '${overall.totalCompletions}',
            caption: 'Total Completions',
          ),
          StatCard(
            icon: Icons.percent,
            value: '${overall.sevenDaySuccessRate.toStringAsFixed(0)} %',
            caption: '7-Day Success Rate',
          ),
          StatCard(
            icon: Icons.local_fire_department,
            value: '${overall.longestStreak} days',
            caption: 'Longest Streak',
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: scheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String caption;

  const StatCard({super.key, required this.icon, required this.value, required this.caption});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  color: scheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                caption,
                style:
                    TextStyle(color: scheme.onBackground.withOpacity(0.7), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
