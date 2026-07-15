import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/device.dart';
import '../providers/device_detail_provider.dart';
import '../widgets/category_icon.dart';

/// Screen B — device detail.
///
/// Prefers the [initialDevice] passed as router `extra` (no refetch); otherwise
/// loads it by [deviceId]. Every optional field is rendered through a safe
/// fallback so missing/nested data never breaks the layout (Part 1).
class DeviceDetailPage extends ConsumerWidget {
  const DeviceDetailPage({
    super.key,
    required this.deviceId,
    this.initialDevice,
  });

  final String deviceId;
  final Device? initialDevice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (initialDevice != null) {
      return _DetailScaffold(device: initialDevice!);
    }

    final async = ref.watch(deviceDetailProvider(deviceId));
    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(
            error is Failure ? error.message : 'Could not load device.',
          ),
        ),
      ),
      data: (device) => _DetailScaffold(device: device),
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.device});

  final Device device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Icon(iconForCategory(device.category), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: theme.textTheme.titleLarge),
                    Text(device.category.label,
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoRow(label: 'Category', value: device.category.label),
          _InfoRow(
            label: 'Year',
            value: device.year?.toString() ?? '—',
          ),
          _InfoRow(label: 'Price', value: Formatters.price(device.price)),
          _InfoRow(
            label: 'Estimated deposit',
            value: Formatters.money(device.estimatedDeposit),
          ),
          const SizedBox(height: 24),
          Text('Specifications', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _Specifications(attributes: device.attributes),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () =>
                context.push(AppRoutes.loan(device.id), extra: device),
            icon: const Icon(Icons.assignment_add),
            label: const Text('Request Loan'),
          ),
        ],
      ),
    );
  }
}

/// Renders the free-form `data` attributes, or a fallback when there are none.
class _Specifications extends StatelessWidget {
  const _Specifications({required this.attributes});

  final Map<String, dynamic> attributes;

  @override
  Widget build(BuildContext context) {
    if (attributes.isEmpty) {
      return Text(
        'No additional details provided.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    return Column(
      children: [
        for (final entry in attributes.entries)
          _InfoRow(
            label: _humanise(entry.key),
            value: entry.value?.toString() ?? '—',
          ),
      ],
    );
  }

  /// Turns keys like `screenSize` / `screen_size` into "Screen Size".
  String _humanise(String key) {
    final spaced = key
        .replaceAllMapped(RegExp('([a-z])([A-Z])'),
            (m) => '${m[1]} ${m[2]}')
        .replaceAll('_', ' ')
        .trim();
    if (spaced.isEmpty) return key;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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
            width: 140,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
