import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router.dart';
import '../../../../app/widgets/app_bottom_nav.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/loan_result.dart';

/// Screen D — the request result.
///
/// Built entirely from the [LoanResult] returned by the submit flow (the POST
/// response is the success criterion). Renders two variants: a created request
/// (shows the server request id) or an offline pending request (queued for
/// retry). Either way the device, loan period, deposit and status show.
class RequestResultPage extends StatelessWidget {
  const RequestResultPage({super.key, required this.result});

  final LoanResult result;

  static final DateFormat _dayMonth = DateFormat('d MMM');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final request = result.request;
    final created = result.isCreated;
    final period =
        '${_dayMonth.format(request.borrowDate)} – '
        '${_dayMonth.format(request.returnDate)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Result'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const AppBottomNav(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor:
                  theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              child: Icon(
                created ? Icons.check : Icons.cloud_upload_outlined,
                size: 44,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              created ? 'Loan request created' : 'Saved offline — pending',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              created
                  ? 'Request ID #${result.id ?? '—'}'
                  : 'Will be sent automatically when you are back online',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ResultRow(label: 'Device', value: request.deviceName),
                  const SizedBox(height: 12),
                  _ResultRow(label: 'Loan period', value: period),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Deposit',
                    value: Formatters.money(request.deposit),
                  ),
                  const SizedBox(height: 12),
                  _ResultRow(
                    label: 'Status',
                    value:
                        created ? 'Pending approval' : 'Pending (offline)',
                    emphasise: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () => context.go(AppRoutes.catalogue),
            child: const Text('BACK TO DEVICES'),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: emphasise ? theme.colorScheme.primary : null,
            ),
          ),
        ),
      ],
    );
  }
}
