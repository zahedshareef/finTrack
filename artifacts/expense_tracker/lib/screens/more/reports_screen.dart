import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../services/export_service.dart';
import '../../theme/app_theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  String? _accountId;
  String? _categoryId;
  bool _exporting = false;
  final _exportService = ExportService();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final txs = provider.getFilteredTransactions(
      accountId: _accountId,
      from: _from,
      to: _to,
      categoryId: _categoryId,
    );
    final totalIncome = txs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final totalExpense = txs.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final baseFmt = NumberFormat.currency(symbol: '${provider.baseCurrency} ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Export'),
        actions: [
          if (_exporting)
            const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
          else
            PopupMenuButton<String>(
              onSelected: (v) => _export(v, provider, txs),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'csv', child: Row(children: [Icon(Icons.table_chart, size: 18), SizedBox(width: 8), Text('Export CSV')])),
                PopupMenuItem(value: 'pdf', child: Row(children: [Icon(Icons.picture_as_pdf, size: 18), SizedBox(width: 8), Text('Export PDF')])),
              ],
              icon: const Icon(Icons.file_download),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(provider),
            const SizedBox(height: 16),
            _buildSummaryCards(baseFmt, totalIncome, totalExpense),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('${txs.length} transactions', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('${DateFormat('MMM d').format(_from)} - ${DateFormat('MMM d, yyyy').format(_to)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            ...txs.take(50).map((tx) {
              final cat = provider.categories.cast<dynamic>().firstWhere((c) => c.id == tx.categoryId, orElse: () => null);
              final acc = provider.getAccount(tx.accountId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(cat?.icon ?? '📦', style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat?.name ?? 'Unknown', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('${acc?.name ?? ''} • ${DateFormat('MMM dd').format(tx.date)}',
                                style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(
                        '${tx.isIncome ? '+' : '-'}${NumberFormat.currency(symbol: '${acc?.currency ?? ''} ', decimalDigits: 2).format(tx.amount)}',
                        style: TextStyle(
                          color: tx.isIncome ? AppTheme.income : AppTheme.expense,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (txs.length > 50)
              Center(child: Text('... and ${txs.length - 50} more. Export for full report.', style: const TextStyle(color: Colors.white54, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(DataProvider provider) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _DateButton(
                label: DateFormat('MMM dd').format(_from),
                prefix: 'From',
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _from, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (d != null) setState(() => _from = d);
                },
              )),
              const SizedBox(width: 8),
              Expanded(child: _DateButton(
                label: DateFormat('MMM dd').format(_to),
                prefix: 'To',
                onTap: () async {
                  final d = await showDatePicker(context: context, initialDate: _to, firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (d != null) setState(() => _to = d);
                },
              )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _QuickPeriod(label: '7d', onTap: () => setState(() { _from = DateTime.now().subtract(const Duration(days: 7)); _to = DateTime.now(); })),
              const SizedBox(width: 8),
              _QuickPeriod(label: '30d', onTap: () => setState(() { _from = DateTime.now().subtract(const Duration(days: 30)); _to = DateTime.now(); })),
              const SizedBox(width: 8),
              _QuickPeriod(label: 'This month', onTap: () => setState(() { final now = DateTime.now(); _from = DateTime(now.year, now.month, 1); _to = now; })),
              const SizedBox(width: 8),
              _QuickPeriod(label: 'This year', onTap: () => setState(() { _from = DateTime(DateTime.now().year, 1, 1); _to = DateTime.now(); })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(NumberFormat fmt, double income, double expense) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.income.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.income.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Income', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text(fmt.format(income), style: const TextStyle(color: AppTheme.income, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.expense.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.expense.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Expenses', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text(fmt.format(expense), style: const TextStyle(color: AppTheme.expense, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _export(String format, provider, txs) async {
    setState(() => _exporting = true);
    try {
      if (format == 'csv') {
        await _exportService.exportTransactionsCSV(txs, provider.accounts, provider.categories);
      } else {
        await _exportService.exportTransactionsPDF(txs, provider.accounts, provider.categories);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final String prefix;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.prefix, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
            const SizedBox(width: 6),
            Text('$prefix: $label', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _QuickPeriod extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickPeriod({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ),
    );
  }
}
