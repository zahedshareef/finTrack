import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'budgets_screen.dart';
import 'goals_screen.dart';
import 'planned_payments_screen.dart';
import 'reports_screen.dart';
import 'gold_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MoreItem(
            icon: Icons.account_balance_wallet,
            color: AppTheme.primary,
            label: 'Budgets',
            subtitle: 'Set spending limits by category',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetsScreen())),
          ),
          _MoreItem(
            icon: Icons.flag,
            color: const Color(0xFF4CAF50),
            label: 'Goals',
            subtitle: 'Track your savings goals',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
          ),
          _MoreItem(
            icon: Icons.schedule,
            color: AppTheme.warning,
            label: 'Planned Payments',
            subtitle: 'Upcoming and recurring payments',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlannedPaymentsScreen())),
          ),
          _MoreItem(
            icon: Icons.assessment,
            color: AppTheme.secondary,
            label: 'Reports & Export',
            subtitle: 'View reports and export data',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
          ),
          _MoreItem(
            icon: Icons.auto_awesome,
            color: const Color(0xFFFFD700),
            label: 'Gold Tracker',
            subtitle: 'Track your gold investments',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoldScreen())),
          ),
          const Divider(height: 32),
          _MoreItem(
            icon: Icons.settings,
            color: Colors.white60,
            label: 'Settings',
            subtitle: 'Currency, preferences',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
