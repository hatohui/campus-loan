import 'package:flutter_application_1/core/constants/app_constants.dart';
import 'package:flutter_application_1/features/equipment/data/models/device_model.dart';
import 'package:flutter_application_1/features/equipment/domain/entities/device.dart';
import 'package:flutter_test/flutter_test.dart';

/// Part 4 — mapper test for missing nested fields and tolerant parsing.
void main() {
  group('DeviceModel.fromJson', () {
    test('tolerates a null data object and missing fields', () {
      final device = DeviceModel.fromJson({
        'id': '1',
        'name': 'Basic Item',
        'data': null,
      });

      expect(device.id, '1');
      expect(device.name, 'Basic Item');
      expect(device.attributes, isEmpty);
      expect(device.price, isNull);
      expect(device.year, isNull);
      // Missing price -> standard deposit, consistent with the deposit rule.
      expect(device.estimatedDeposit, AppConstants.standardDeposit);
    });

    test('falls back to a placeholder name when name is missing', () {
      final device = DeviceModel.fromJson({'id': '2'});
      expect(device.name, 'Unknown device');
      expect(device.category, DeviceCategory.other);
    });

    test('parses a nested price given as a formatted string', () {
      final device = DeviceModel.fromJson({
        'id': '3',
        'name': 'MacBook Pro 16',
        'data': {'Price': r'$1,449.99', 'year': 2021},
      });

      expect(device.price, 1449.99);
      expect(device.year, 2021);
      expect(device.category, DeviceCategory.laptop);
      expect(device.estimatedDeposit, AppConstants.highDeposit);
    });

    test('fromJsonList preserves the original API order as apiIndex', () {
      final list = DeviceModel.fromJsonList([
        {'id': 'a', 'name': 'First'},
        {'id': 'b', 'name': 'Second'},
      ]);

      expect(list.map((d) => d.apiIndex), [0, 1]);
      expect(list.first.id, 'a');
    });
  });
}
