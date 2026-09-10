import 'package:agrocampo/src/app/bootstrap/app_bootstrap.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapAgroCampo();
}
