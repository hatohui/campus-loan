import 'package:flutter/material.dart';

import '../../domain/entities/device.dart';

/// Maps a [DeviceCategory] to a Material icon. Kept in the presentation layer
/// so the domain enum stays free of Flutter dependencies.
IconData iconForCategory(DeviceCategory category) => switch (category) {
      DeviceCategory.phone => Icons.smartphone,
      DeviceCategory.laptop => Icons.laptop_mac,
      DeviceCategory.tablet => Icons.tablet_mac,
      DeviceCategory.watch => Icons.watch,
      DeviceCategory.audio => Icons.headphones,
      DeviceCategory.television => Icons.tv,
      DeviceCategory.monitor => Icons.desktop_windows,
      DeviceCategory.console => Icons.sports_esports,
      DeviceCategory.accessory => Icons.cable,
      DeviceCategory.other => Icons.devices_other,
    };

/// Background + foreground tints for a category's label box on the device card
/// (matching the pastel colour blocks in the reference design).
({Color background, Color foreground}) colorsForCategory(
  DeviceCategory category,
) =>
    switch (category) {
      DeviceCategory.laptop =>
        (background: const Color(0xFFDDF3EA), foreground: const Color(0xFF0F6E58)),
      DeviceCategory.phone =>
        (background: const Color(0xFFE6EAFB), foreground: const Color(0xFF3646A6)),
      DeviceCategory.tablet =>
        (background: const Color(0xFFE9F1FB), foreground: const Color(0xFF2A5C99)),
      DeviceCategory.watch =>
        (background: const Color(0xFFFBE7EF), foreground: const Color(0xFF9B3B63)),
      DeviceCategory.audio =>
        (background: const Color(0xFFFCEFE1), foreground: const Color(0xFF9A5B22)),
      DeviceCategory.television =>
        (background: const Color(0xFFEAF2EA), foreground: const Color(0xFF3C6E42)),
      DeviceCategory.monitor =>
        (background: const Color(0xFFEDEBF6), foreground: const Color(0xFF4A3F86)),
      DeviceCategory.console =>
        (background: const Color(0xFFEDE7FB), foreground: const Color(0xFF5B3F9B)),
      DeviceCategory.accessory =>
        (background: const Color(0xFFF0F0F2), foreground: const Color(0xFF52525B)),
      DeviceCategory.other =>
        (background: const Color(0xFFF3E9FB), foreground: const Color(0xFF6B3FA0)),
    };
