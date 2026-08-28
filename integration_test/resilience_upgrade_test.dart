import 'package:agrocampo/core/database/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('current schema recovers after a failed atomic write', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    expect(database.schemaVersion, 9);
    await expectLater(
      database.transaction(() async {
        await database
            .into(database.localProfiles)
            .insert(
              LocalProfilesCompanion.insert(
                id: 'owner-1',
                displayName: 'Temporal',
                updatedAt: DateTime.utc(2026),
              ),
            );
        throw StateError('simulated interruption');
      }),
      throwsStateError,
    );
    expect(await database.select(database.localProfiles).get(), isEmpty);
    expect(await database.select(database.weatherCache).get(), isEmpty);
    expect(await database.select(database.exportSnapshots).get(), isEmpty);
  });
}
