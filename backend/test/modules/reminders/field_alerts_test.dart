import 'dart:convert';

import 'package:agrocampo_backend/src/modules/reminders/domain/entities/field_alerts.dart';
import 'package:agrocampo_backend/src/modules/reminders/infrastructure/alerts/field_alert_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/territory_fixture.dart';

List<FieldAlertForecastDay> _forecast(List<(double, double)> minMax) => [
  for (final (index, (min, max)) in minMax.indexed)
    (date: DateTime(2026, 7, 1 + index), minimumC: min, maximumC: max),
];

void main() {
  final today = DateTime(2026, 7, 1);

  group('evaluateFieldAlerts', () {
    test('warns of a season ending within the chosen days', () {
      List<String> keys(double days) => evaluateFieldAlerts(
        settings: FieldAlertSettings.defaults.withRule(
          FieldAlertKind.seasonEnd,
          FieldAlertRule(enabled: true, threshold: days),
        ),
        seasons: [
          (
            seasonId: 'season-1',
            sectorName: 'Sector 1',
            endsOn: DateTime(2026, 7, 6),
          ),
        ],
        forecasts: const [],
        today: today,
      ).map((notice) => notice.key).toList();

      expect(keys(7), ['seasonEnd:season-1:2026-07-06']);
      expect(keys(3), isEmpty, reason: 'five days left is beyond three');
    });

    test('frost, cold and heat follow their own thresholds', () {
      final settings = FieldAlertSettings.defaults
          .withRule(
            FieldAlertKind.cold,
            const FieldAlertRule(enabled: true, threshold: 4),
          )
          .withRule(
            FieldAlertKind.heat,
            const FieldAlertRule(enabled: true, threshold: 28),
          );
      final notices = evaluateFieldAlerts(
        settings: settings,
        seasons: const [],
        forecasts: [
          (
            sectorId: 'sector-1',
            sectorName: 'Sector 1',
            forecast: _forecast([(-1, 12), (3, 20), (8, 31)]),
          ),
        ],
        today: today,
      );
      expect(notices.map((notice) => notice.key), [
        'frost:sector-1:2026-07-01',
        'cold:sector-1:2026-07-02',
        'heat:sector-1:2026-07-03',
      ]);
      expect(notices.first.body, contains('no es alerta oficial'));
    });

    test('disabled alerts stay silent', () {
      final settings = FieldAlertSettings.defaults.withRule(
        FieldAlertKind.frost,
        const FieldAlertRule(enabled: false, threshold: 0),
      );
      final notices = evaluateFieldAlerts(
        settings: settings,
        seasons: const [],
        forecasts: [
          (
            sectorId: 'sector-1',
            sectorName: 'Sector 1',
            forecast: _forecast([(-3, 10)]),
          ),
        ],
        today: today,
      );
      expect(notices, isEmpty);
    });
  });

  test('settings round-trip and fall back to defaults', () {
    final custom = FieldAlertSettings.defaults.withRule(
      FieldAlertKind.heat,
      const FieldAlertRule(enabled: true, threshold: 33),
    );
    final restored = FieldAlertSettings.fromJson(
      jsonDecode(jsonEncode(custom.toJson())) as Map<String, dynamic>,
    );
    expect(restored.rule(FieldAlertKind.heat).threshold, 33);
    expect(restored.rule(FieldAlertKind.heat).enabled, isTrue);
    expect(
      FieldAlertSettings.fromJson(const {}).rule(FieldAlertKind.frost).enabled,
      isTrue,
    );
  });

  test('each alert is notified only once', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    await seedAgriculturalContextFixture(
      database,
      endsOn: DateTime(2026, 7, 3),
    );
    final service = FieldAlertService(database);

    final first = await service.takeNewNotices('owner-1', today: today);
    final second = await service.takeNewNotices('owner-1', today: today);

    expect(first.map((notice) => notice.kind), [FieldAlertKind.seasonEnd]);
    expect(second, isEmpty, reason: 'the same season end is not repeated');
  });

  test('saved thresholds are read back', () async {
    final database = createInMemoryDatabase();
    addTearDown(database.close);
    final service = FieldAlertService(database);
    await service.saveSettings(
      'owner-1',
      FieldAlertSettings.defaults.withRule(
        FieldAlertKind.frost,
        const FieldAlertRule(enabled: true, threshold: -2),
      ),
    );
    final settings = await service.loadSettings('owner-1');
    expect(settings.rule(FieldAlertKind.frost).threshold, -2);
  });
}
