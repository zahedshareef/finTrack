import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/planned_payment.dart';
import '../../widgets/currency_picker.dart';
import '../../widgets/category_picker.dart';
import '../../models/category.dart';
import '../../theme/app_theme.dart';

class PlannedPaymentsScreen extends StatelessWidget {
  const PlannedPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planned Payments')),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          final payments = provider.plannedPayments
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          if (payments.isEmpty) {
            return const Center(child: Text('No planned payments', style: TextStyle(color: Colors.white54)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: payments.length,
            itemBuilder: (ctx, i) => _PaymentCard(payment: payments[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _AddPaymentSheet(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PlannedPayment payment;
  const _PaymentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DataProvider>();
    final fmt = NumberFormat.currency(symbol: '${payment.currency} ', decimalDigits: 2);
    final statusColor = payment.isPaid
        ? AppTheme.income
        : payment.isOverdue
            ? AppTheme.expense
            : payment.isDueSoon
                ? AppTheme.warning
                : Colors.white60;

    final cat = provider.categories.cast<Category?>().firstWhere(
      (c) => c?.id == payment.categoryId,
      orElse: () => null,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: payment.isOverdue && !payment.isPaid ? Border.all(color: AppTheme.expense.withOpacity(0.5)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(cat?.icon ?? '💳', style: const TextStyle(fontSize: 20))),
        ),
        title: Row(
          children: [
            Expanded(child: Text(payment.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            if (payment.isRecurring)
              const Icon(Icons.repeat, size: 14, color: Colors.white54),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Due: ${DateFormat('MMM dd, yyyy').format(payment.dueDate)}',
              style: TextStyle(
                color: payment.isOverdue && !payment.isPaid ? AppTheme.expense : Colors.white54,
                fontSize: 12,
              ),
            ),
            if (payment.note.isNotEmpty)
              Text(payment.note, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(fmt.format(payment.amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                payment.isPaid ? 'Paid' : payment.isOverdue ? 'Overdue' : payment.isDueSoon ? 'Due Soon' : 'Upcoming',
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        onTap: () {
          if (!payment.isPaid) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Mark as Paid?'),
                content: Text('Mark "${payment.name}" as paid?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      provider.markPaymentAsPaid(payment.id);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Mark Paid'),
                  ),
                ],
              ),
            );
          }
        },
        onLongPress: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Payment'),
              content: const Text('Are you sure?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
              ],
            ),
          );
          if (confirm == true) provider.deletePlannedPayment(payment.id);
        },
      ),
    );
  }
}

class _AddPaymentSheet extends StatefulWidget {
  const _AddPaymentSheet();

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _currency = 'USD';
  String? _accountId;
  Category? _category;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  bool _isRecurring = false;
  String _recurrencePeriod = 'monthly';

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DataProvider>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Planned Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Payment Name')),
            const SizedBox(height: 12),
            TextField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 12),
            CurrencyPickerDropdown(value: _currency, onChanged: (v) => setState(() => _currency = v!)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _accountId,
              decoration: const InputDecoration(labelText: 'Account'),
              items: provider.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
              onChanged: (v) => setState(() => _accountId = v),
              dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: CategoryPickerSheet(onSelected: (c) => setState(() => _category = c)),
                ),
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Text(_category?.icon ?? '💳', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Text(_category?.name ?? 'Select Category', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (d != null) setState(() => _dueDate = d);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                    const SizedBox(width: 10),
                    Text('Due: ${DateFormat('MMM dd, yyyy').format(_dueDate)}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
              title: const Text('Recurring'),
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.primary,
            ),
            if (_isRecurring)
              DropdownButtonFormField<String>(
                value: _recurrencePeriod,
                decoration: const InputDecoration(labelText: 'Period'),
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (v) => setState(() => _recurrencePeriod = v!),
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            const SizedBox(height: 12),
            TextField(controller: _noteCtrl, decoration: const InputDecoration(labelText: 'Note (optional)')),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty || _amountCtrl.text.isEmpty) return;
    final provider = context.read<DataProvider>();
    await provider.addPlannedPayment(PlannedPayment(
      id: provider.generateId(),
      name: _nameCtrl.text,
      amount: double.tryParse(_amountCtrl.text) ?? 0,
      currency: _currency,
      accountId: _accountId ?? (provider.accounts.isNotEmpty ? provider.accounts.first.id : ''),
      categoryId: _category?.id ?? 'other',
      dueDate: _dueDate,
      isRecurring: _isRecurring,
      recurrencePeriod: _recurrencePeriod,
      isPaid: false,
      note: _noteCtrl.text,
      createdAt: DateTime.now(),
    ));
    if (context.mounted) Navigator.pop(context);
  }
}
