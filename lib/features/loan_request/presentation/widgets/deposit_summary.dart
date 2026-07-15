import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

/// Teal "Request summary" card on the loan form: loan period and refundable
/// deposit. Both values are passed in already computed (period from the chosen
/// dates, deposit from the shared deposit rule) so this widget stays pure.
class RequestSummary extends StatelessWidget {
  const RequestSummary({
    super.key,
    required this.loanDays,
    required this.deposit,
  });

  /// Number of days between borrow and return, or `null` if not both chosen.
  final int? loanDays;
  final double deposit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request summary', style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Loan period',
              value: loanDays == null ? '—' : '$loanDays days',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Refundable deposit',
              value: Formatters.money(deposit),
              emphasise: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  final String label;
  final String value;
  final bool emphasise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: emphasise ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }
}
