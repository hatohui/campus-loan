import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

/// Read-only summary card showing the device and its estimated deposit.
///
/// The [deposit] is passed in already computed (from the shared deposit rule)
/// so this widget never re-derives business values.
class DepositSummary extends StatelessWidget {
  const DepositSummary({
    super.key,
    required this.deviceName,
    required this.deposit,
  });

  final String deviceName;
  final double deposit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deviceName, style: theme.textTheme.titleSmall),
                  Text('Estimated deposit',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Text(
              Formatters.money(deposit),
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
