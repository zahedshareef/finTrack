import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTime? _from;
  DateTime? _to;
  bool? _isIncome;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showSearch = false;
  static const int _pageSize = 30;
  int _visibleCount = _pageSize;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      setState(() => _visibleCount += _pageSize);
    }
  }

  void _resetPagination() => setState(() => _visibleCount = _pageSize);

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              )
            : const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) {
                _searchQuery = '';
                _searchController.clear();
              }
            }),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          var txs = provider.getFilteredTransactions(
            accountId: _selectedAccountId,
            categoryId: _selectedCategoryId,
            from: _from,
            to: _to,
            isIncome: _isIncome,
          );

          if (_searchQuery.isNotEmpty) {
            txs = txs.where((tx) {
              final cat = provider.getCategoryById(tx.categoryId);
              final acc = provider.getAccount(tx.accountId);
              return (cat?.name ?? '').toLowerCase().contains(_searchQuery) ||
                  tx.note.toLowerCase().contains(_searchQuery) ||
                  (acc?.name ?? '').toLowerCase().contains(_searchQuery) ||
                  tx.amount.toString().contains(_searchQuery);
            }).toList();
          }

          return Column(
            children: [
              if (_hasFilters())
                Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt, size: 16, color: Colors.white60),
                      const SizedBox(width: 6),
                      const Text('Filters active', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      const Spacer(),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: txs.isEmpty
                    ? const Center(
                        child: Text('No transactions found', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: _visibleCount < txs.length ? _visibleCount + 1 : txs.length,
                        itemBuilder: (ctx, i) {
                          if (i >= _visibleCount) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final tx = txs[i];
                          final category = provider.getCategoryById(tx.categoryId);
                          final account = provider.getAccount(tx.accountId);
                          return TransactionTile(
                            transaction: tx,
                            category: category,
                            account: account,
                            onDelete: () => provider.deleteTransaction(tx),
                            onEdit: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(existingTransaction: tx),
                            )),
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
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _hasFilters() =>
      _selectedAccountId != null || _selectedCategoryId != null || _from != null || _to != null || _isIncome != null;

  void _clearFilters() => setState(() {
        _selectedAccountId = null;
        _selectedCategoryId = null;
        _from = null;
        _to = null;
        _isIncome = null;
        _visibleCount = _pageSize;
      });

  void _showFilterSheet() {
    final provider = context.read<DataProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _selectedAccountId,
                decoration: const InputDecoration(labelText: 'Account'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Accounts')),
                  ...provider.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                ],
                onChanged: (v) => setModalState(() => _selectedAccountId = v),
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Categories')),
                  ...provider.categories
                      .where((c) => !c.isIncome)
                      .map((c) => DropdownMenuItem(value: c.id, child: Text('${c.icon} ${c.name}'))),
                ],
                onChanged: (v) => setModalState(() => _selectedCategoryId = v),
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<bool?>(
                value: _isIncome,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: true, child: Text('Income')),
                  DropdownMenuItem(value: false, child: Text('Expense')),
                ],
                onChanged: (v) => setModalState(() => _isIncome = v),
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: _from != null ? DateFormat('MMM dd').format(_from!) : 'From Date',
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: _from ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setModalState(() => _from = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DateButton(
                      label: _to != null ? DateFormat('MMM dd').format(_to!) : 'To Date',
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: _to ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setModalState(() => _to = d);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() { _visibleCount = _pageSize; });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.white54),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
