import 'package:agrocampo/core/database/app_database.dart';
import 'package:agrocampo/core/export/xlsx_exporter.dart';
import 'package:agrocampo/features/agro_ai/data/agro_ai_gateway.dart';
import 'package:agrocampo/features/agro_ai/data/agro_ai_repository.dart';
import 'package:agrocampo/features/export/data/export_repository.dart';
import 'package:agrocampo/features/weather/data/weather_gateway.dart';
import 'package:agrocampo/features/weather/data/weather_repository.dart';
import 'package:agrocampo/features/weather/domain/weather_snapshot.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

final class _Weather implements WeatherGateway {
  @override
  Future<WeatherSnapshot> fetch(String locality) async => WeatherSnapshot(
    locality: locality,
    temperatureC: 14,
    humidityPercent: 80,
    rainMillimeters: 2,
    summary: 'Lluvia',
    fetchedAt: DateTime.utc(2026, 8, 28),
  );
}

final class _Ai implements AgroAiGateway {
  @override
  Future<String> ask(String question) async =>
      'Valida humedad antes de decidir.';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'weather and AI degrade independently while XLSX remains offline',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await WeatherRepository(
        database,
        _Weather(),
      ).refresh(ownerId: 'owner-1', locality: 'Curicó');
      await AgroAiRepository(
        database,
        _Ai(),
      ).ask(ownerId: 'owner-1', question: '¿Riego hoy?');
      final snapshot = await ExportRepository(database).snapshot('owner-1');
      final bytes = const XlsxExporter().encode(snapshot);
      expect(
        (await WeatherRepository(database, _Weather()).cached('owner-1'))
            ?.summary,
        'Lluvia',
      );
      expect(await database.select(database.aiMessages).get(), hasLength(2));
      expect(bytes.take(2), [80, 75]);
    },
  );
}
