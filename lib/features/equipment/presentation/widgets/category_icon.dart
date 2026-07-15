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
