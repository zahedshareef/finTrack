import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/data_provider.dart';

class CategoryPickerSheet extends StatelessWidget {
  final bool incomeOnly;
  final ValueChanged<Category> onSelected;

  const CategoryPickerSheet({
    super.key,
    required this.onSelected,
    this.incomeOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DataProvider>();
    final cats = provider.categories
        .where((c) => incomeOnly ? c.isIncome : !c.isIncome)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              incomeOnly ? 'Select Income Category' : 'Select Expense Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: cats.length,
              itemBuilder: (ctx, i) {
                final cat = cats[i];
                return InkWell(
                  onTap: () {
                    onSelected(cat);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cat.color.withOpacity(0.4)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(
                          cat.name,
                          style: const TextStyle(fontSize: 10, color: Colors.white70),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
