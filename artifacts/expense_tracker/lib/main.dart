import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  final storage = await StorageService.create();
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider(storage)..init(),
      child: const App(),
    ),
  );
}
