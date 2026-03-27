import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class CurrencyPickerDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final String label;

  const CurrencyPickerDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Currency',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: CurrencyService.supportedCurrencies
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: onChanged,
      dropdownColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }
}
