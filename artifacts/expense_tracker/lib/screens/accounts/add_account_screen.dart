import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/account.dart';
import '../../providers/data_provider.dart';
import '../../widgets/currency_picker.dart';
import '../../theme/app_theme.dart';

class AddAccountScreen extends StatefulWidget {
  final Account? account;
  const AddAccountScreen({super.key, this.account});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  String _currency = 'USD';
  String _type = accountTypes.first;
  int _colorValue = accountColors.first;
  bool _includeInTotal = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController(
        text: widget.account != null ? widget.account!.balance.toString() : '0');
    if (widget.account != null) {
      _currency = widget.account!.currency;
      _type = widget.account!.type;
      _colorValue = widget.account!.colorValue;
      _includeInTotal = widget.account!.includeInTotal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;
    final provider = context.read<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Account' : 'Add Account'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text('This will delete all associated transactions. Continue?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) {
                  await provider.deleteAccount(widget.account!.id);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildColorPreview(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(labelText: 'Current Balance'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                validator: (v) {
                  if (v!.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CurrencyPickerDropdown(
                value: _currency,
                onChanged: (v) => setState(() => _currency = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Account Type'),
                items: accountTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _type = v!),
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 16),
              _buildColorPicker(),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _includeInTotal,
                onChanged: (v) => setState(() => _includeInTotal = v),
                title: const Text('Include in total balance'),
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primary,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(isEditing ? 'Save Changes' : 'Add Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: Color(_colorValue),
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Color(_colorValue), Color(_colorValue).withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _nameController.text.isEmpty ? 'Account Preview' : _nameController.text,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: accountColors.map((c) {
            return GestureDetector(
              onTap: () => setState(() => _colorValue = c),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(c),
                  shape: BoxShape.circle,
                  border: _colorValue == c
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: _colorValue == c
                      ? [BoxShadow(color: Color(c).withOpacity(0.6), blurRadius: 8)]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<DataProvider>();
    final balance = double.parse(_balanceController.text);
    if (widget.account != null) {
      await provider.updateAccount(widget.account!.copyWith(
        name: _nameController.text,
        balance: balance,
        currency: _currency,
        type: _type,
        colorValue: _colorValue,
        includeInTotal: _includeInTotal,
      ));
    } else {
      await provider.addAccount(Account(
        id: provider.generateId(),
        name: _nameController.text,
        balance: balance,
        currency: _currency,
        colorValue: _colorValue,
        type: _type,
        includeInTotal: _includeInTotal,
        createdAt: DateTime.now(),
      ));
    }
    if (context.mounted) Navigator.pop(context);
  }
}
