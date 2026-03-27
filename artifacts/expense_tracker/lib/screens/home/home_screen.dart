import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../widgets/account_card.dart';
import '../../theme/app_theme.dart';
import '../accounts/account_detail_screen.dart';
import '../accounts/add_account_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../more/planned_payments_screen.dart';
import '../stats/stats_screen.dart';
import '../more/reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PlannedPaymentsScreen())),
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: provider.refreshRates,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalBalance(context, provider),
                  const SizedBox(height: 20),
                  _buildAccountsSection(context, provider),
                  const SizedBox(height: 20),
                  _buildQuickActions(context),
                  const SizedBox(height: 20),
                  _buildMonthSummary(context, provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTotalBalance(BuildContext context, DataProvider provider) {
    final formatter = NumberFormat.currency(
      symbol: '${provider.baseCurrency} ',
      decimalDigits: 2,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF9C27B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  provider.baseCurrency,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(provider.totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${provider.accounts.length} account${provider.accounts.length != 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          if (provider.exchangeRates.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('• Live exchange rates', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context, DataProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Accounts', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddAccountScreen()),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
          ),
          itemCount: provider.accounts.length,
          itemBuilder: (ctx, i) {
            final account = provider.accounts[i];
            return AccountCard(
              account: account,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AccountDetailScreen(account: account)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _QuickActionChip(
          icon: Icons.bar_chart,
          label: 'Statistics',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const StatsScreen())),
        ),
        const SizedBox(width: 8),
        _QuickActionChip(
          icon: Icons.schedule,
          label: 'Payments',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const PlannedPaymentsScreen())),
        ),
        const SizedBox(width: 8),
        _QuickActionChip(
          icon: Icons.file_download,
          label: 'Export',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
        ),
      ],
    );
  }

  Widget _buildMonthSummary(BuildContext context, DataProvider provider) {
    final thisMonth = provider.getSpendingThisMonth();
    final lastMonth = provider.getSpendingLastMonth();
    final change = lastMonth > 0 ? ((thisMonth - lastMonth) / lastMonth * 100) : 0.0;
    final formatter = NumberFormat.currency(symbol: '${provider.baseCurrency} ', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('This Month Spending', style: TextStyle(color: Colors.white60, fontSize: 13)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: change > 0 ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: change > 0 ? AppTheme.expense : AppTheme.income,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(thisMonth),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'vs last month ${formatter.format(lastMonth)}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
