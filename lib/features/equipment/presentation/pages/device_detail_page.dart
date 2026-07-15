import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/widgets/app_bottom_nav.dart';
import '../../../../core/constants/app_constants.dart';
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
        appBar: AppBar(title: const Text('Device Detail')),
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
    final palette = colorsForCategory(device.category);
    final primarySpec = _primarySpec(device);

    return Scaffold(
      appBar: AppBar(title: const Text('Device Detail')),
      bottomNavigationBar: const AppBottomNav(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image placeholder (the API provides no images).
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconForCategory(device.category),
                    size: 52, color: palette.foreground),
                const SizedBox(height: 8),
                Text(
                  'DEVICE IMAGE',
                  style: TextStyle(
                    color: palette.foreground,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(device.name, style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            _subtitle,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 12),
          Text(
            'Estimated value: ${Formatters.price(device.price)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          // Two-cell hero card: a key spec + the deposit.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CardCell(
                      label: primarySpec.label,
                      value: primarySpec.value,
                    ),
                  ),
                  Expanded(
                    child: _CardCell(
                      label: 'Deposit',
                      value: Formatters.money(device.estimatedDeposit),
                      valueColor: theme.colorScheme.primary,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Loan policy', style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Maximum loan period is ${AppConstants.maxLoanDays} days. '
            'The request remains pending until staff approval.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 20),
          _Specifications(attributes: device.attributes),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () =>
                context.push(AppRoutes.loan(device.id), extra: device),
            icon: const Icon(Icons.assignment_add),
            label: const Text('REQUEST THIS DEVICE'),
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    final year = device.year;
    return year == null
        ? '${device.category.label} • Unknown year'
        : '${device.category.label} • Year $year';
  }

  /// Picks a representative non-price attribute for the hero card, falling back
  /// to the category when the device has no extra attributes.
  ({String label, String value}) _primarySpec(Device device) {
    for (final entry in device.attributes.entries) {
      if (!entry.key.toLowerCase().contains('price')) {
        return (label: _humanise(entry.key), value: '${entry.value ?? '—'}');
      }
    }
    return (label: 'Type', value: device.category.label);
  }
}

/// A labelled value cell used inside the hero card.
class _CardCell extends StatelessWidget {
  const _CardCell({
    required this.label,
    required this.value,
    this.valueColor,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

/// Renders the free-form `data` attributes, or a fallback when there are none.
class _Specifications extends StatelessWidget {
  const _Specifications({required this.attributes});

  final Map<String, dynamic> attributes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (attributes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Specifications', style: theme.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final entry in attributes.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            _humanise(entry.key),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(entry.value?.toString() ?? '—',
                              style: theme.textTheme.bodyLarge),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Turns keys like `screenSize` / `screen_size` into "Screen Size".
String _humanise(String key) {
  final spaced = key
      .replaceAllMapped(RegExp('([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAll('_', ' ')
      .trim();
  if (spaced.isEmpty) return key;
  return spaced[0].toUpperCase() + spaced.substring(1);
}
