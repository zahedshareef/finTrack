import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../theme/app_theme.dart';

class TransactionTile extends StatelessWidget {
  final AppTransaction transaction;
  final Category? category;
  final Account? account;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final amountFormatter = NumberFormat.currency(
      symbol: account != null ? '${account!.currency} ' : '',
      decimalDigits: 2,
    );
    final dateFormatter = DateFormat('MMM dd');

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.expense.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (category?.color ?? Colors.grey).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category?.icon ?? '📦',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  if (transaction.note.isNotEmpty)
                    Text(
                      transaction.note,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isIncome ? '+' : '-'}${amountFormatter.format(transaction.amount)}',
                  style: TextStyle(
                    color: transaction.isIncome ? AppTheme.income : AppTheme.expense,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  dateFormatter.format(transaction.date),
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
