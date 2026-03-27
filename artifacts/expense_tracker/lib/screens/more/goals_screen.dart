import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/goal.dart';
import '../../widgets/currency_picker.dart';
import '../../theme/app_theme.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: Consumer<DataProvider>(
        builder: (context, provider, _) {
          final goals = provider.goals;
          if (goals.isEmpty) {
            return const Center(child: Text('No goals yet. Add your first goal!', style: TextStyle(color: Colors.white54)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (ctx, i) => _GoalCard(goal: goals[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddGoalSheet(),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '${goal.currency} ', decimalDigits: 2);
    final provider = context.read<DataProvider>();
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: goal.isComplete ? Border.all(color: AppTheme.income.withOpacity(0.5)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(goal.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      daysLeft > 0 ? '$daysLeft days left' : 'Overdue',
                      style: TextStyle(
                        color: daysLeft < 0 ? AppTheme.expense : Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (goal.isComplete)
                const Icon(Icons.check_circle, color: AppTheme.income),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') _editGoal(context, provider);
                  if (v == 'delete') provider.deleteGoal(goal.id);
                  if (v == 'add') _addSavings(context, provider);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'add', child: Text('Add savings')),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: Colors.white12,
              color: goal.isComplete ? AppTheme.income : AppTheme.primary,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(fmt.format(goal.savedAmount), style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const Spacer(),
              Text(fmt.format(goal.targetAmount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          Text('${(goal.progress * 100).toStringAsFixed(1)}% complete',
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  void _editGoal(BuildContext context, DataProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddGoalSheet(goal: goal),
    );
  }

  void _addSavings(BuildContext context, DataProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Savings'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Amount to add'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(ctrl.text) ?? 0;
              provider.updateGoal(Goal(
                id: goal.id,
                name: goal.name,
                targetAmount: goal.targetAmount,
                savedAmount: (goal.savedAmount + amt).clamp(0, goal.targetAmount),
                currency: goal.currency,
                targetDate: goal.targetDate,
                icon: goal.icon,
                createdAt: goal.createdAt,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _AddGoalSheet extends StatefulWidget {
  final Goal? goal;
  const _AddGoalSheet({this.goal});

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _savedCtrl = TextEditingController();
  String _currency = 'USD';
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  String _icon = '🎯';

  final _icons = ['🎯', '🏠', '🚗', '✈️', '💻', '💍', '🎓', '🏖️', '📱', '💪', '🌍', '🎁'];

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    if (g != null) {
      _nameCtrl.text = g.name;
      _targetCtrl.text = g.targetAmount.toString();
      _savedCtrl.text = g.savedAmount.toString();
      _currency = g.currency;
      _targetDate = g.targetDate;
      _icon = g.icon;
    }
  }

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
            Text(widget.goal != null ? 'Edit Goal' : 'New Goal',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _icons.map((ic) => GestureDetector(
                onTap: () => setState(() => _icon = ic),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _icon == ic ? AppTheme.primary.withOpacity(0.3) : Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                    border: _icon == ic ? Border.all(color: AppTheme.primary) : null,
                  ),
                  child: Text(ic, style: const TextStyle(fontSize: 20)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Goal Name')),
            const SizedBox(height: 12),
            TextField(
                controller: _targetCtrl,
                decoration: const InputDecoration(labelText: 'Target Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 12),
            TextField(
                controller: _savedCtrl,
                decoration: const InputDecoration(labelText: 'Amount Saved So Far'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            const SizedBox(height: 12),
            CurrencyPickerDropdown(value: _currency, onChanged: (v) => setState(() => _currency = v!)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _targetDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2040),
                );
                if (d != null) setState(() => _targetDate = d);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.white54, size: 18),
                    const SizedBox(width: 10),
                    Text('Target: ${DateFormat('MMM dd, yyyy').format(_targetDate)}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(widget.goal != null ? 'Save' : 'Create Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty) return;
    final provider = context.read<DataProvider>();
    final g = Goal(
      id: widget.goal?.id ?? provider.generateId(),
      name: _nameCtrl.text,
      targetAmount: double.tryParse(_targetCtrl.text) ?? 0,
      savedAmount: double.tryParse(_savedCtrl.text) ?? 0,
      currency: _currency,
      targetDate: _targetDate,
      icon: _icon,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
    );
    if (widget.goal != null) {
      await provider.updateGoal(g);
    } else {
      await provider.addGoal(g);
    }
    if (context.mounted) Navigator.pop(context);
  }
}
