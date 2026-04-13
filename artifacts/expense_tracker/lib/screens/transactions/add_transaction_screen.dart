import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../providers/data_provider.dart';
import '../../widgets/category_picker.dart';
import '../../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? defaultAccountId;
  final AppTransaction? existingTransaction;
  const AddTransactionScreen({super.key, this.defaultAccountId, this.existingTransaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isIncome = false;
  String? _accountId;
  Category? _category;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _accountId = widget.defaultAccountId ?? widget.existingTransaction?.accountId;
    if (widget.existingTransaction != null) {
      final tx = widget.existingTransaction!;
      _amountController.text = tx.amount.toString();
      _noteController.text = tx.note;
      _isIncome = tx.isIncome;
      _date = tx.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();

    if (_accountId == null && provider.accounts.isNotEmpty) {
      _accountId = provider.accounts.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.existingTransaction != null ? 'Edit Transaction' : 'Add Transaction')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Type toggle
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _TypeButton(
                      label: 'Expense',
                      selected: !_isIncome,
                      color: AppTheme.expense,
                      onTap: () => setState(() {
                        _isIncome = false;
                        _category = null;
                      }),
                    ),
                    _TypeButton(
                      label: 'Income',
                      selected: _isIncome,
                      color: AppTheme.income,
                      onTap: () => setState(() {
                        _isIncome = true;
                        _category = null;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (double.tryParse(v) == null || double.parse(v) <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category picker
              InkWell(
                onTap: _pickCategory,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (_category != null) ...[
                        Text(_category!.icon, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Text(_category!.name, style: const TextStyle(color: Colors.white)),
                      ] else
                        const Text('Select Category', style: TextStyle(color: Colors.white60)),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _accountId,
                decoration: const InputDecoration(labelText: 'Account'),
                items: provider.accounts
                    .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                    .toList(),
                onChanged: (v) => setState(() => _accountId = v),
                validator: (v) => v == null ? 'Required' : null,
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 16),
              // Date picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('MMMM dd, yyyy').format(_date),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isIncome ? AppTheme.income : AppTheme.expense,
                  ),
                  child: Text(widget.existingTransaction != null ? 'Save Changes' : 'Add Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickCategory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: CategoryPickerSheet(
          incomeOnly: _isIncome,
          onSelected: (cat) => setState(() => _category = cat),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<DataProvider>();

    if (widget.existingTransaction != null) {
      final old = widget.existingTransaction!;
      if (_category == null) {
        final existingCat = provider.getCategoryById(old.categoryId);
        if (existingCat == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a category')),
          );
          return;
        }
      }
      await provider.updateTransaction(
        old,
        AppTransaction(
          id: old.id,
          accountId: _accountId!,
          categoryId: _category?.id ?? old.categoryId,
          amount: double.parse(_amountController.text),
          isIncome: _isIncome,
          note: _noteController.text,
          date: _date,
          createdAt: old.createdAt,
        ),
      );
    } else {
      if (_category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }
      await provider.addTransaction(AppTransaction(
        id: provider.generateId(),
        accountId: _accountId!,
        categoryId: _category!.id,
        amount: double.parse(_amountController.text),
        isIncome: _isIncome,
        note: _noteController.text,
        date: _date,
        createdAt: DateTime.now(),
      ));
    }
    if (context.mounted) Navigator.pop(context);
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: selected ? Border.all(color: color.withOpacity(0.6)) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? color : Colors.white54,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
