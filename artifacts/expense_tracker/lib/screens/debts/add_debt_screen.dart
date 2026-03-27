import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/debt.dart';
import '../../providers/data_provider.dart';
import '../../widgets/currency_picker.dart';

class AddDebtScreen extends StatefulWidget {
  final Debt? debt;
  const AddDebtScreen({super.key, this.debt});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _paidController;
  late TextEditingController _noteController;
  String _currency = 'USD';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  bool _iOwe = true;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    final d = widget.debt;
    _nameController = TextEditingController(text: d?.contactName ?? '');
    _amountController = TextEditingController(text: d?.amount.toString() ?? '');
    _paidController = TextEditingController(text: d?.paidAmount.toString() ?? '0');
    _noteController = TextEditingController(text: d?.note ?? '');
    if (d != null) {
      _currency = d.currency;
      _dueDate = d.dueDate;
      _iOwe = d.iOwe;
      _status = d.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _paidController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.debt != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Debt' : 'Add Debt')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _TypeBtn(label: 'I Owe', selected: _iOwe, color: Colors.red,
                        onTap: () => setState(() => _iOwe = true)),
                    _TypeBtn(label: 'Owed to Me', selected: !_iOwe, color: Colors.green,
                        onTap: () => setState(() => _iOwe = false)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Contact Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paidController,
                decoration: const InputDecoration(labelText: 'Amount Paid'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              CurrencyPickerDropdown(
                value: _currency,
                onChanged: (v) => setState(() => _currency = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'partial', child: Text('Partial')),
                  DropdownMenuItem(value: 'settled', child: Text('Settled')),
                ],
                onChanged: (v) => setState(() => _status = v!),
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 16),
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
                      Text('Due: ${DateFormat('MMM dd, yyyy').format(_dueDate)}',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Save Changes' : 'Add Debt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => _dueDate = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<DataProvider>();
    final debt = Debt(
      id: widget.debt?.id ?? provider.generateId(),
      contactName: _nameController.text,
      amount: double.parse(_amountController.text),
      paidAmount: double.tryParse(_paidController.text) ?? 0,
      currency: _currency,
      note: _noteController.text,
      dueDate: _dueDate,
      iOwe: _iOwe,
      status: _status,
      createdAt: widget.debt?.createdAt ?? DateTime.now(),
    );
    if (widget.debt != null) {
      await provider.updateDebt(debt);
    } else {
      await provider.addDebt(debt);
    }
    if (context.mounted) Navigator.pop(context);
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeBtn({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: selected ? color : Colors.white54,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
          ),
        ),
      );
}
