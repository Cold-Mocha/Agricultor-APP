import 'package:agrocampo_backend/src/platform/database/app_database.dart';
import 'package:drift/native.dart';

AppDatabase createInMemoryDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());
