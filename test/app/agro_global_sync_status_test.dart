import 'dart:async';

import 'package:agrocampo/app/providers.dart';
import 'package:agrocampo/app/shell/agro_global_sync_status.dart';
import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/core/network/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Connectivity implements ConnectivityService {
  final controller = StreamController<ConnectionSignal>.broadcast();

  @override
  Stream<ConnectionSignal> watch() => controller.stream;
}

void main() {
  testWidgets('shows truthful global offline and pending states', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final connectivity = _Connectivity();
    final pending = StreamController<int>.broadcast();
    addTearDown(connectivity.controller.close);
    addTearDown(pending.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityServiceProvider.overrideWithValue(connectivity),
          pendingSyncCountProvider.overrideWith(
            (ref, ownerId) => pending.stream,
          ),
        ],
        child: MaterialApp(
          theme: AgroTheme.light,
          home: const Scaffold(body: AgroGlobalSyncStatus(ownerId: 'owner-1')),
        ),
      ),
    );
    expect(find.text('Con conexión · respaldo al día.'), findsOneWidget);

    pending.add(1);
    await tester.pumpAndSettle();
    expect(
      find.text('1 registro pendiente de sincronización.'),
      findsOneWidget,
    );

    connectivity.controller.add(ConnectionSignal.offline);
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión · 1 registro pendiente.'), findsOneWidget);
    expect(
      find.bySemanticsLabel(
        RegExp('Estado de conexión.*Estado de sincronización'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
