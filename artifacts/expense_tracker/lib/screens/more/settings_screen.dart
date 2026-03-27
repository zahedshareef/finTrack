import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../widgets/currency_picker.dart';
import '../../services/currency_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(label: 'Currency'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Base Currency', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('All balances will be converted to this currency',
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: provider.baseCurrency,
                  decoration: const InputDecoration(labelText: 'Base Currency'),
                  items: CurrencyService.supportedCurrencies
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) provider.setBaseCurrency(v);
                  },
                  dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                if (provider.exchangeRates.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.income, size: 16),
                      const SizedBox(width: 6),
                      Text('Exchange rates loaded (${provider.exchangeRates.length} currencies)',
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(label: 'About'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expense Tracker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('Version 1.0.0', style: TextStyle(color: Colors.white54)),
                SizedBox(height: 8),
                Text(
                  'Features: Multi-account support, debts tracking, statistics & charts, budgets & goals, planned payments, CSV/PDF export, multi-currency with live rates, gold P/L tracker.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
    );
  }
}
