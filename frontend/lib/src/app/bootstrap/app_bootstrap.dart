import 'package:agrocampo/src/app/agro_campo_app.dart';
import 'package:agrocampo/src/app/routing/app_routes.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrapAgroCampo() async {
  WidgetsFlutterBinding.ensureInitialized();
  final backend = await AgroCampoBackend.initialize(
    reminderNotificationPayload: AppRoutes.reminder,
  );
  runApp(
    UncontrolledProviderScope(
      container: backend.container,
      child: const AgroCampoApp(),
    ),
  );
}
