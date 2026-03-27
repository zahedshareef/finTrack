import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/gold_holding.dart';
import '../../widgets/currency_picker.dart';
import '../../theme/app_theme.dart';

class GoldScreen extends StatefulWidget {
  const GoldScreen({super.key});

  @override
  State<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends State<GoldScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gold Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DataProvider>().refreshRates(),
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          final holdings = provider.goldHoldings;
          final currentGoldPrice = provider.goldPricePerGramBase;
          final baseFmt = NumberFormat.currency(symbol: '${provider.baseCurrency} ', decimalDigits: 2);

          double totalCost = 0;
          double totalCurrentValue = 0;

          for (final h in holdings) {
            final costInBase = provider.toBase(h.totalCost, h.currency);
            totalCost += costInBase;
            if (currentGoldPrice > 0) {
              totalCurrentValue += provider.toBase(h.currentValue(
                provider.goldPriceUSD != null
                    ? (provider.toBase(provider.goldPriceUSD!, 'USD') / (provider.exchangeRates[provider.baseCurrency] ?? 1) * (provider.exchangeRates['USD'] ?? 1))
                    : 0,
              ), h.currency);
            }
          }

          final totalPL = totalCurrentValue - totalCost;
          final totalPLPct = totalCost > 0 ? (totalPL / totalCost * 100) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoldPriceCard(context, provider, baseFmt, currentGoldPrice),
                const SizedBox(height: 16),
                if (holdings.isNotEmpty) ...[
                  _buildPortfolioSummary(baseFmt, totalCost, totalCurrentValue, totalPL, totalPLPct),
                  const SizedBox(height: 16),
                  Text('Holdings', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...holdings.map((h) => _GoldHoldingCard(
                    holding: h,
                    currentGoldPriceInBase: currentGoldPrice,
                    provider: provider,
                  )),
                ],
                if (holdings.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Text('🥇', style: TextStyle(fontSize: 48)),
                          SizedBox(height: 12),
                          Text('No gold holdings yet', style: TextStyle(color: Colors.white54)),
                          Text('Add your first gold purchase', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _AddGoldSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoldPriceCard(BuildContext context, DataProvider provider, NumberFormat fmt, double pricePerGram) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🥇 Live Gold Price', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            pricePerGram > 0 ? '${fmt.format(pricePerGram)} / gram' : 'Loading...',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text('Per troy ounce ≈ 31.1g', style: TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary(NumberFormat fmt, double totalCost, double totalValue, double pl, double plPct) {
    final isPositive = pl >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Portfolio Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryItem(label: 'Total Cost', value: fmt.format(totalCost), color: Colors.white70),
              const SizedBox(width: 20),
              _SummaryItem(label: 'Current Value', value: fmt.format(totalValue), color: Colors.white),
              const SizedBox(width: 20),
              _SummaryItem(
                label: 'P/L',
                value: '${isPositive ? '+' : ''}${fmt.format(pl)} (${plPct.toStringAsFixed(2)}%)',
                color: isPositive ? AppTheme.income : AppTheme.expense,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
          ],
        ),
      );
}

class _GoldHoldingCard extends StatelessWidget {
  final GoldHolding holding;
  final double currentGoldPriceInBase;
  final DataProvider provider;

  const _GoldHoldingCard({required this.holding, required this.currentGoldPriceInBase, required this.provider});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '${holding.currency} ', decimalDigits: 2);
    final currentPriceInHoldingCurrency = currentGoldPriceInBase > 0
        ? provider.toBase(currentGoldPriceInBase, provider.baseCurrency) /
            (provider.exchangeRates[holding.currency] ?? 1) *
            (provider.exchangeRates[provider.baseCurrency] ?? 1)
        : 0.0;

    final pl = holding.profitLoss(currentPriceInHoldingCurrency > 0 ? currentPriceInHoldingCurrency : holding.buyPricePerGram);
    final plPct = holding.profitLossPercent(currentPriceInHoldingCurrency > 0 ? currentPriceInHoldingCurrency : holding.buyPricePerGram);
    final isPositive = pl >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('🥇', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${holding.weightGrams}g Gold', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Bought: ${DateFormat('MMM dd, yyyy').format(holding.buyDate)}',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    if (holding.note.isNotEmpty)
                      Text(holding.note, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => provider.deleteGoldHolding(holding.id),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Buy Price', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(fmt.format(holding.buyPricePerGram) + '/g', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Cost', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(fmt.format(holding.totalCost), style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('P/L', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    Text(
                      '${isPositive ? '+' : ''}${fmt.format(pl)} (${plPct.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: currentGoldPriceInBase > 0
                            ? (isPositive ? AppTheme.income : AppTheme.expense)
                            : Colors.white38,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddGoldSheet extends StatefulWidget {
  const _AddGoldSheet();

  @override
  State<_AddGoldSheet> createState() => _AddGoldSheetState();
}

class _AddGoldSheetState extends State<_AddGoldSheet> {
  final _weightCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _currency = 'USD';
  DateTime _buyDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Gold Purchase', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
                controller: _weightCtrl,
                decoration: const InputDecoration(labelText: 'Weight (grams)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 12),
            TextField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Buy Price per Gram'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 12),
            CurrencyPickerDropdown(value: _currency, onChanged: (v) => setState(() => _currency = v!)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: _buyDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (d != null) setState(() => _buyDate = d);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                    const SizedBox(width: 10),
                    Text('Buy Date: ${DateFormat('MMM dd, yyyy').format(_buyDate)}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: _noteCtrl, decoration: const InputDecoration(labelText: 'Note (optional)')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Gold'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_weightCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;
    final provider = context.read<DataProvider>();
    await provider.addGoldHolding(GoldHolding(
      id: provider.generateId(),
      weightGrams: double.tryParse(_weightCtrl.text) ?? 0,
      buyPricePerGram: double.tryParse(_priceCtrl.text) ?? 0,
      currency: _currency,
      buyDate: _buyDate,
      note: _noteCtrl.text,
      createdAt: DateTime.now(),
    ));
    if (context.mounted) Navigator.pop(context);
  }
}
