import 'package:flutter/material.dart';

abstract final class ReminderLabels {
  static String dateTime(BuildContext context, DateTime value) {
    final local = value.toLocal();
    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatMediumDate(local)} · '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
  }

  static String status(String status) => switch (status) {
    'scheduled' => 'Programado',
    'completed' => 'Completado',
    'cancelled' => 'Cancelado',
    _ => status,
  };

  /// In local-only builds nothing is ever uploaded, so a pending record is
  /// already in its final state on the device.
  static String syncState(String syncState, {required bool localMode}) =>
      switch (syncState) {
        'pending' || 'local' when localMode => 'Guardado en este dispositivo',
        'pending' || 'local' => 'Pendiente de sincronización',
        'syncing' => 'Sincronizando',
        'synced' => 'Sincronizado',
        'error' || 'conflict' => 'Requiere revisar el respaldo',
        _ => syncState,
      };
}
