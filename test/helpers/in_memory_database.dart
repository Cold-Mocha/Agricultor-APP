import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/native.dart';

AppDatabase createInMemoryDatabase() =>
    AppDatabase.forTesting(NativeDatabase.memory());
