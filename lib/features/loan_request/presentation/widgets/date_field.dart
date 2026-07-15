import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

/// A tappable field that opens a date picker and displays the chosen date.
///
/// Pure UI: it renders the given [value] and reports picks via [onPicked]; all
/// validation lives in the domain layer, not here.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onPicked,
    this.firstDate,
    this.lastDate,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? firstDate ?? now,
          firstDate: firstDate ?? DateTime(now.year - 1),
          lastDate: lastDate ?? DateTime(now.year + 2),
        );
        if (picked != null) onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(value == null ? 'Select date' : Formatters.date(value)),
      ),
    );
  }
}
