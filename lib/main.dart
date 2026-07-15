import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/storage/hive_service.dart';
import 'features/equipment/data/datasources/equipment_local_datasource.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await EquipmentLocalDataSourceImpl().seedIfEmpty();
  runApp(const ProviderScope(child: CampusLoanApp()));
}
