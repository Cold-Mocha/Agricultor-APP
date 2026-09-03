import 'package:agrocampo/features/labors/domain/labor_type.dart';

/// Canonical route locations for the five-tab AgroCampo information
/// architecture described in `master.md`.
abstract final class AppRoutes {
  static const login = '/acceso';
  static const home = '/inicio';
  static const profile = '/inicio/perfil';
  static const parcels = '/inicio/parcelas';
  static const newParcel = '/inicio/parcelas/nueva';

  static const sectors = '/sectores';

  static const register = '/registrar';
  static const soil = '/registrar/suelo';
  static const irrigation = '/registrar/riego';
  static const irrigationConfiguration = '/registrar/riego/configuracion';
  static const production = '/registrar/produccion';
  static const photo = '/registrar/foto';

  static const agroAi = '/agroia';
  static const more = '/mas';
  static const seasons = '/mas/temporadas';
  static const cropCatalog = '/mas/catalogo';
  static const history = '/mas/historial';
  static const reminders = '/mas/recordatorios';
  static const synchronization = '/mas/sincronizacion';
  static const export = '/mas/exportar';
  static const settings = '/mas/configuracion';

  static const profilePersonalInformation = '/inicio/perfil/informacion';
  static const profileNotifications = '/inicio/perfil/notificaciones';
  static const profileLanguage = '/inicio/perfil/idioma';
  static const profileSecurity = '/inicio/perfil/seguridad';
  static const profileTheme = '/inicio/perfil/tema';
  static const profileHelp = '/inicio/perfil/ayuda';
  static const profileContact = '/inicio/perfil/contacto';
  static const profilePrivacy = '/inicio/perfil/privacidad';

  static String editParcel(String parcelId) =>
      '$parcels/${Uri.encodeComponent(parcelId)}/editar';

  static String quadrantMap(String parcelId) =>
      '$sectors/parcela/${Uri.encodeComponent(parcelId)}/mapa';

  static String sector(String sectorId) =>
      '$sectors/${Uri.encodeComponent(sectorId)}';

  static String sectorRotation(String sectorId) =>
      '${sector(sectorId)}/rotacion';

  static String sectorHistory(String sectorId) =>
      '${sector(sectorId)}/historial';

  static String sectorApiary(String sectorId) =>
      '${sector(sectorId)}/apicultura';

  static String labor(LaborType type, {String? sectorId}) =>
      _withSector('$register/labor/${type.name}', sectorId);

  static String registerFor({String? sectorId}) =>
      _withSector(register, sectorId);

  static String soilFor({String? sectorId}) => _withSector(soil, sectorId);

  static String irrigationFor({String? sectorId}) =>
      _withSector(irrigation, sectorId);

  static String irrigationConfigurationFor({String? sectorId}) =>
      _withSector(irrigationConfiguration, sectorId);

  static String productionFor({String? sectorId}) =>
      _withSector(production, sectorId);

  static String photoFor({String? sectorId}) => _withSector(photo, sectorId);

  static String historyFor({String? sectorId}) =>
      _withSector(history, sectorId);

  static String conflict(String conflictId) =>
      '$synchronization/conflictos/${Uri.encodeComponent(conflictId)}';

  static String reminder(String reminderId) =>
      '$reminders/${Uri.encodeComponent(reminderId)}';

  static String _withSector(String path, String? sectorId) {
    final value = sectorId?.trim();
    if (value == null || value.isEmpty) return path;
    return Uri(path: path, queryParameters: {'sectorId': value}).toString();
  }
}
