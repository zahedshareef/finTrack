import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../theme/app_theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          final now = DateTime.now();
          final monthStart = DateTime(now.year, now.month, 1);
          final expByCat = provider.getExpensesByCategory(from: monthStart);
          final monthlyData = provider.getMonthlyOutflow(months: 6);
          final thisMonth = provider.getSpendingThisMonth();
          final lastMonth = provider.getSpendingLastMonth();
          final predicted = provider.predictNextMonth();
          final change = lastMonth > 0 ? ((thisMonth - lastMonth) / lastMonth * 100) : 0.0;
          final baseFmt = NumberFormat.currency(symbol: '${provider.baseCurrency} ', decimalDigits: 2);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(baseFmt, thisMonth, lastMonth, change, predicted),
                const SizedBox(height: 24),
                if (expByCat.isNotEmpty) ...[
                  Text('Expense Structure', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  _buildExpensePieChart(provider, expByCat, baseFmt),
                  const SizedBox(height: 24),
                ],
                Text('Monthly Outflow', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _buildBarChart(monthlyData, baseFmt),
                const SizedBox(height: 24),
                Text('Balance by Account', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                _buildAccountToggles(provider),
                const SizedBox(height: 24),
                _buildForecast(baseFmt, predicted),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(NumberFormat fmt, double thisMonth, double lastMonth, double change, double predicted) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'This Month',
            value: fmt.format(thisMonth),
            icon: Icons.trending_up,
            trailing: '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
            trailingColor: change > 0 ? AppTheme.expense : AppTheme.income,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Predicted',
            value: fmt.format(predicted),
            icon: Icons.psychology,
            trailing: 'Next month',
            trailingColor: Colors.white54,
          ),
        ),
      ],
    );
  }

  Widget _buildExpensePieChart(DataProvider provider, Map<String, double> expByCat, NumberFormat fmt) {
    final total = expByCat.values.fold(0.0, (a, b) => a + b);
    final sorted = expByCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final sections = <PieChartSectionData>[];
    final legend = <Widget>[];

    for (int i = 0; i < sorted.length && i < 8; i++) {
      final entry = sorted[i];
      final cat = provider.categories.cast<dynamic>().firstWhere(
        (c) => c.id == entry.key,
        orElse: () => null,
      );
      final color = cat?.color ?? Colors.grey;
      final pct = total > 0 ? entry.value / total * 100 : 0;
      final isTouched = i == _touchedPieIndex;

      sections.add(PieChartSectionData(
        value: entry.value,
        color: color,
        radius: isTouched ? 90 : 80,
        title: '',
        showTitle: false,
      ));

      legend.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              cat?.name ?? entry.key,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('THIS MONTH', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const Spacer(),
              Text(fmt.format(total), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 55,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                        _touchedPieIndex = -1;
                        return;
                      }
                      _touchedPieIndex = response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: legend,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<MapEntry<String, double>> monthlyData, NumberFormat fmt) {
    final maxY = monthlyData.isEmpty ? 100.0 : monthlyData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY.clamp(1, double.infinity),
          barGroups: monthlyData.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  color: AppTheme.primary,
                  width: 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= monthlyData.length) return const SizedBox();
                  final label = monthlyData[idx].key.split('/')[0];
                  return Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11));
                },
              ),
            ),
          ),
          gridData: FlGridData(
            drawHorizontalLine: true,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) => const FlLine(color: Colors.white10, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildAccountToggles(DataProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: provider.accounts.map((acc) {
          final fmtAcc = NumberFormat.currency(symbol: '${acc.currency} ', decimalDigits: 2);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: acc.color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(child: Text(acc.name)),
                Text(fmtAcc.format(acc.balance),
                    style: TextStyle(
                        color: acc.balance >= 0 ? AppTheme.income : AppTheme.expense,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Switch(
                  value: acc.includeInTotal,
                  onChanged: (v) => provider.updateAccount(acc.copyWith(includeInTotal: v)),
                  activeColor: AppTheme.primary,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildForecast(NumberFormat fmt, double predicted) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: AppTheme.secondary, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Spending Forecast', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(fmt.format(predicted),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('Predicted for next month (linear trend)',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String trailing;
  final Color trailingColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.trailing,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis),
          Text(trailing, style: TextStyle(color: trailingColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
