import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/debt.dart';
import '../../theme/app_theme.dart';
import 'add_debt_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debts'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'I Owe'),
              Tab(text: 'Owed to Me'),
            ],
          ),
        ),
        body: Consumer<DataProvider>(
          builder: (context, provider, _) {
            final iOwe = provider.debts.where((d) => d.iOwe).toList();
            final owedToMe = provider.debts.where((d) => !d.iOwe).toList();
            return TabBarView(
              children: [
                _DebtList(debts: iOwe, iOwe: true),
                _DebtList(debts: owedToMe, iOwe: false),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDebtScreen()),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _DebtList extends StatelessWidget {
  final List<Debt> debts;
  final bool iOwe;

  const _DebtList({required this.debts, required this.iOwe});

  @override
  Widget build(BuildContext context) {
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iOwe ? Icons.arrow_upward : Icons.arrow_downward,
                size: 48, color: Colors.white24),
            const SizedBox(height: 12),
            Text(
              iOwe ? 'No debts to pay' : 'Nobody owes you',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: debts.length,
      itemBuilder: (ctx, i) => _DebtCard(debt: debts[i]),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final Debt debt;
  const _DebtCard({required this.debt});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DataProvider>();
    final formatter = NumberFormat.currency(symbol: '${debt.currency} ', decimalDigits: 2);
    final isOverdue = debt.dueDate.isBefore(DateTime.now()) && !debt.isSettled;
    final statusColor = debt.isSettled
        ? AppTheme.income
        : debt.status == 'partial'
            ? AppTheme.warning
            : (isOverdue ? AppTheme.expense : Colors.white70);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: isOverdue ? Border.all(color: AppTheme.expense.withOpacity(0.5)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: (debt.iOwe ? AppTheme.expense : AppTheme.income).withOpacity(0.2),
          child: Text(
            debt.contactName.isNotEmpty ? debt.contactName[0].toUpperCase() : '?',
            style: TextStyle(color: debt.iOwe ? AppTheme.expense : AppTheme.income, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(debt.contactName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Due: ${DateFormat('MMM dd, yyyy').format(debt.dueDate)}',
              style: TextStyle(
                color: isOverdue ? AppTheme.expense : Colors.white54,
                fontSize: 12,
              ),
            ),
            if (debt.note.isNotEmpty)
              Text(debt.note, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatter.format(debt.amount),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                debt.status,
                style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddDebtScreen(debt: debt)),
        ),
        onLongPress: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Debt'),
              content: const Text('Are you sure?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm == true) await provider.deleteDebt(debt.id);
        },
      ),
    );
  }
}
