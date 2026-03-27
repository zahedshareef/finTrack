import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/account.dart';
import '../../providers/data_provider.dart';
import '../../widgets/transaction_tile.dart';
import 'add_account_screen.dart';
import '../transactions/add_transaction_screen.dart';

class AccountDetailScreen extends StatelessWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '${account.currency} ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddAccountScreen(account: account)),
            ),
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          final txs = provider.getTransactionsForAccount(account.id);
          final currentAccount = provider.getAccount(account.id) ?? account;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: currentAccount.color.withOpacity(0.2),
                  border: Border(bottom: BorderSide(color: currentAccount.color.withOpacity(0.3))),
                ),
                child: Column(
                  children: [
                    Text('Current Balance', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(currentAccount.balance),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text('${currentAccount.type} • ${currentAccount.currency}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: txs.isEmpty
                    ? const Center(child: Text('No transactions yet', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: txs.length,
                        itemBuilder: (ctx, i) {
                          final tx = txs[i];
                          final category = provider.categories
                              .cast<dynamic>()
                              .firstWhere((c) => c.id == tx.categoryId, orElse: () => null);
                          return TransactionTile(
                            transaction: tx,
                            category: category,
                            account: currentAccount,
                            onDelete: () => provider.deleteTransaction(tx),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddTransactionScreen(defaultAccountId: account.id)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
