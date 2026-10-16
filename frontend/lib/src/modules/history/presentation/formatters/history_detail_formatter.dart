import 'package:agrocampo_backend/agrocampo_backend.dart';

abstract final class HistoryDetailFormatter {
  static String date(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  static String status(String? value) => switch (value) {
    'recorded' => 'Registrada',
    'corrected' => 'Corregida',
    'voided' => 'Anulada',
    'active' => 'Activo',
    'ended' => 'Finalizado',
    _ => value ?? 'Sin estado registrado',
  };
  static Map<String, String> fields(HistoryEvent event) => {
    'Sector':
        '${event.sectorName ?? event.sectorId}${event.sectorNumber == null ? '' : ' · N.º ${event.sectorNumber}'}${event.sectorRetired ? ' · Retirado' : ''}',
    'Fecha':
        '${date(event.occurredAt)} · ${event.occurredAt.toLocal().hour.toString().padLeft(2, '0')}:${event.occurredAt.toLocal().minute.toString().padLeft(2, '0')}',
    'Estado': status(event.status),
    'Temporada': event.seasonLabel ?? 'Sin temporada registrada',
    if (event.cropLabel != null) 'Cultivo': event.cropLabel!,
    if (event.detail?.isNotEmpty == true) 'Notas / resumen': event.detail!,
    ..._flatten(event.details),
    if (event.supersedesLaborId != null)
      'Corrige la labor': event.supersedesLaborId!,
    if (event.replacedByLaborId != null)
      'Corrección registrada': event.replacedByLaborId!,
    'ID del registro': event.id,
  };
  static Map<String, String> _flatten(
    Map<String, Object?> data, [
    String prefix = '',
  ]) {
    final result = <String, String>{};
    for (final entry in data.entries) {
      if (entry.value == null || entry.value == '') continue;
      final label = '$prefix${_labels[entry.key] ?? entry.key}';
      if (entry.value is Map) {
        result.addAll(
          _flatten(Map<String, Object?>.from(entry.value as Map), '$label · '),
        );
      } else {
        result[label] = entry.value is bool
            ? (entry.value == true ? 'Sí' : 'No')
            : entry.value.toString();
      }
    }
    return result;
  }

  static const _labels = {
    'product': 'Producto',
    'notes': 'Notas',
    'destination': 'Destino',
    'workShift': 'Jornada',
    'target': 'Objetivo',
    'dose': 'Dosis',
    'safetyIntervalDays': 'Intervalo de seguridad (días)',
    'appliedVolumeLiters': 'Volumen aplicado (L)',
    'pressureKpa': 'Presión (kPa)',
    'calculationFormula': 'Fórmula de cálculo',
    'roundingMode': 'Redondeo',
    'plantCount': 'Plantas',
    'performedWork': 'Trabajo realizado',
    'observedState': 'Estado observado',
    'variety': 'Variedad',
    'affectedPlants': 'Plantas afectadas',
    'name': 'Nombre',
    'seedQuantity': 'Cantidad de semillas',
    'spacingCentimeters': 'Distancia (cm)',
    'irrigationLaborId': 'Labor de riego vinculada',
    'amount': 'Cantidad',
    'unit': 'Unidad',
    'applicationMethod': 'Método de aplicación',
    'method': 'Método',
    'description': 'Descripción',
    'quantity': 'Cantidad cosechada',
    'qualityNotes': 'Notas de calidad',
    'irrigationType': 'Tipo de riego',
    'soilTypeCode': 'Tipo de suelo',
    'flowLitersPerHour': 'Caudal (L/h)',
    'durationMinutes': 'Duración (min)',
    'durationSeconds': 'Duración (s)',
    'estimatedLiters': 'Volumen estimado (L)',
    'appliedVolumeMl': 'Volumen aplicado (mL)',
    'moisturePercent': 'Humedad (%)',
    'ph': 'pH',
    'temperatureCelsius': 'Temperatura (°C)',
    'conductivity': 'Conductividad',
    'nitrogen': 'Nitrógeno',
    'phosphorus': 'Fósforo',
    'potassium': 'Potasio',
    'units': 'Unidades',
    'taskType': 'Tarea',
    'beekeeperName': 'Apicultor',
    'hiveCount': 'Colmenas',
    'queenStatus': 'Estado de la reina',
    'broodStatus': 'Estado de cría',
    'feedingStatus': 'Alimentación',
    'healthNotes': 'Notas de salud',
    'pestNotes': 'Notas de plagas',
    'superInstalled': 'Alza instalada',
    'observations': 'Observaciones',
    'startsOn': 'Inicio',
    'endsOn': 'Término',
    'cropId': 'ID del cultivo',
    'configId': 'Configuración de riego',
    'configVersion': 'Versión de configuración',
  };
}
