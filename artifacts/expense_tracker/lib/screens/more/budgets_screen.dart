import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/budget.dart';
import '../../theme/app_theme.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          final expenseCategories = provider.categories.where((c) => !c.isIncome).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: expenseCategories.length,
            itemBuilder: (ctx, i) {
              final cat = expenseCategories[i];
              final budget = provider.budgets.cast<Budget?>().firstWhere(
                (b) => b?.categoryId == cat.id,
                orElse: () => null,
              );
              final spent = budget != null ? provider.getSpentForBudget(budget) : 0.0;
              final pct = budget != null && budget.limit > 0 ? (spent / budget.limit).clamp(0.0, 1.0) : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: pct >= 1.0 && budget != null
                      ? Border.all(color: AppTheme.expense.withOpacity(0.5))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        if (budget != null)
                          Text(
                            '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(spent)} / ${NumberFormat.currency(symbol: '', decimalDigits: 0).format(budget.limit)}',
                            style: TextStyle(
                              color: pct >= 1.0 ? AppTheme.expense : pct >= 0.8 ? AppTheme.warning : Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        IconButton(
                          icon: Icon(budget != null ? Icons.edit : Icons.add, size: 20),
                          onPressed: () => _showBudgetDialog(context, provider, cat.id, budget),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    if (budget != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.white12,
                          color: pct >= 1.0
                              ? AppTheme.expense
                              : pct >= 0.8
                                  ? AppTheme.warning
                                  : AppTheme.income,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (pct >= 1.0)
                        const Text('Over budget!', style: TextStyle(color: AppTheme.expense, fontSize: 11)),
                      if (pct >= 0.8 && pct < 1.0)
                        const Text('Approaching limit', style: TextStyle(color: AppTheme.warning, fontSize: 11)),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, DataProvider provider, String categoryId, Budget? existing) {
    final controller = TextEditingController(text: existing?.limit.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Monthly Limit'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          if (existing != null)
            TextButton(
              onPressed: () {
                provider.deleteBudget(existing.id);
                Navigator.pop(ctx);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final limit = double.tryParse(controller.text);
              if (limit != null && limit > 0) {
                provider.saveBudget(Budget(
                  id: existing?.id ?? provider.generateId(),
                  categoryId: categoryId,
                  limit: limit,
                  period: 'monthly',
                  createdAt: existing?.createdAt ?? DateTime.now(),
                ));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
