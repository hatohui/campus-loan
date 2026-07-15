import '../../domain/entities/device.dart';

/// Maps the public API's free-form JSON objects into [Device] entities.
///
/// The upstream `GET /objects` payload is deliberately loose: `data` may be
/// `null`, keys vary in casing (`"price"`, `"Price"`, `"capacity"`), and many
/// fields are simply absent. All of that tolerance is quarantined here so the
/// rest of the app can rely on a clean, typed [Device].
class DeviceModel {
  const DeviceModel._();

  /// Builds a [Device] from one raw API object at position [apiIndex].
  ///
  /// Never throws on missing/malformed fields — unknown values become `null`
  /// and `data` collapses to an empty map, which is exactly what the detail
  /// screen's fallbacks and the mapper unit test assert.
  static Device fromJson(Map<String, dynamic> json, {int apiIndex = 0}) {
    final attributes = _asStringKeyedMap(json['data']);
    final name = (json['name'] as Object?)?.toString().trim();

    return Device(
      id: (json['id'] as Object?)?.toString() ?? '',
      name: (name == null || name.isEmpty) ? 'Unknown device' : name,
      category: _inferCategory(name ?? '', attributes),
      attributes: attributes,
      apiIndex: apiIndex,
      year: _extractYear(attributes, name ?? ''),
      price: _extractPrice(attributes),
    );
  }

  /// Maps a full list response, preserving the API order as [Device.apiIndex].
  static List<Device> fromJsonList(List<dynamic> jsonList) {
    return [
      for (var i = 0; i < jsonList.length; i++)
        if (jsonList[i] is Map)
          fromJson(Map<String, dynamic>.from(jsonList[i] as Map), apiIndex: i),
    ];
  }

  // --- tolerant field extraction ----------------------------------------

  static Map<String, dynamic> _asStringKeyedMap(Object? raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  /// Finds the first attribute whose key looks like a price and parses it.
  static num? _extractPrice(Map<String, dynamic> data) {
    for (final entry in data.entries) {
      if (entry.key.toLowerCase().contains('price')) {
        final parsed = _parseNum(entry.value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  /// Prefers an explicit year attribute; otherwise infers a 19xx/20xx year
  /// embedded in the device name; otherwise `null`.
  static int? _extractYear(Map<String, dynamic> data, String name) {
    for (final entry in data.entries) {
      if (entry.key.toLowerCase().contains('year')) {
        final parsed = _parseNum(entry.value);
        if (parsed != null) return parsed.toInt();
      }
    }
    final match = RegExp(r'(19|20)\d{2}').firstMatch(name);
    return match == null ? null : int.tryParse(match.group(0)!);
  }

  /// Parses numbers that may arrive as `num` or as strings like `"$1,449.99"`.
  static num? _parseNum(Object? value) {
    if (value is num) return value;
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleaned.isEmpty) return null;
      return num.tryParse(cleaned);
    }
    return null;
  }

  /// Keyword-based category inference over the name and attribute values.
  static DeviceCategory _inferCategory(String name, Map<String, dynamic> data) {
    final haystack =
        '$name ${data.values.join(' ')}'.toLowerCase();

    bool has(List<String> keys) => keys.any(haystack.contains);

    if (has(['iphone', 'pixel', 'galaxy s', 'phone', 'oneplus'])) {
      return DeviceCategory.phone;
    }
    if (has(['macbook', 'laptop', 'thinkpad', 'notebook', 'surface laptop'])) {
      return DeviceCategory.laptop;
    }
    if (has(['ipad', 'tablet', 'galaxy tab'])) return DeviceCategory.tablet;
    if (has(['watch'])) return DeviceCategory.watch;
    if (has(['airpods', 'earbuds', 'headphone', 'speaker', 'beats'])) {
      return DeviceCategory.audio;
    }
    if (has(['tv', 'television'])) return DeviceCategory.television;
    if (has(['monitor', 'display'])) return DeviceCategory.monitor;
    if (has(['playstation', 'xbox', 'nintendo', 'console'])) {
      return DeviceCategory.console;
    }
    if (has(['case', 'cable', 'charger', 'pencil', 'keyboard', 'mouse'])) {
      return DeviceCategory.accessory;
    }
    return DeviceCategory.other;
  }
}
