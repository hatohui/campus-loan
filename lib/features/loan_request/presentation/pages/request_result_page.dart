import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/loan_result.dart';

/// Screen D — the request result.
///
/// Built entirely from the [LoanResult] returned by the submit flow (the POST
/// response is the success criterion). Renders two variants: a created request
/// (shows server id + createdAt) or an offline pending request (queued for
/// retry). Either way the borrow/return dates, deposit and pending status show.
class RequestResultPage extends StatelessWidget {
  const RequestResultPage({super.key, required this.result});

  final LoanResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = result.request;
    final created = result.isCreated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Result'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Column(
              children: [
                Icon(
                  created ? Icons.check_circle : Icons.cloud_upload_outlined,
                  size: 72,
                  color: created
                      ? Colors.green
                      : theme.colorScheme.tertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  created
                      ? 'Loan request submitted'
                      : 'Saved offline — pending',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (!created) ...[
                  const SizedBox(height: 8),
                  Text(
                    'This request will be sent automatically when you are '
                    'back online.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (created) ...[
                    _ResultRow(label: 'Request ID', value: result.id ?? '—'),
                    _ResultRow(
                      label: 'Created at',
                      value: result.createdAt ?? '—',
                    ),
                    const Divider(height: 24),
                  ],
                  _ResultRow(
                    label: 'Borrow date',
                    value: Formatters.date(request.borrowDate),
                  ),
                  _ResultRow(
                    label: 'Return date',
                    value: Formatters.date(request.returnDate),
                  ),
                  _ResultRow(
                    label: 'Deposit',
                    value: Formatters.money(request.deposit),
                  ),
                  _ResultRow(
                    label: 'Status',
                    value: created ? 'pending' : 'pending (offline)',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => context.go(AppRoutes.catalogue),
            icon: const Icon(Icons.home),
            label: const Text('Back to catalogue'),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
