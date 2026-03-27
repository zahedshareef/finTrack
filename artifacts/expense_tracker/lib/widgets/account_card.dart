import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: account.currency + ' ', decimalDigits: 2);
    final isNegative = account.balance < 0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: account.color,
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              account.color,
              account.color.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: account.color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    account.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    account.type,
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ),
              ],
            ),
            Text(
              formatter.format(account.balance),
              style: TextStyle(
                color: isNegative ? Colors.red[200] : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
