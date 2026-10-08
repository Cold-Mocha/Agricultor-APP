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
}
