/// Canonical route locations for the five-tab AgroCampo information
/// architecture described in `master.md`.
abstract final class AppRoutes {
  static const login = '/acceso';
  static const home = '/inicio';
  static const profile = '/mas/perfil';

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
  static const export = '/mas/exportar';
  static const settings = '/mas/configuracion';

  static const profileNotifications = '/mas/perfil/notificaciones';
  static const profileLanguage = '/mas/perfil/idioma';
  static const profileSecurity = '/mas/perfil/seguridad';
  static const profileTheme = '/mas/perfil/tema';
  static const profileHelp = '/mas/perfil/ayuda';
  static const profileContact = '/mas/perfil/contacto';
  static const profilePrivacy = '/mas/perfil/privacidad';

  static const quadrantMap = '$sectors/mapa';

  static String sector(String sectorId) =>
      '$sectors/${Uri.encodeComponent(sectorId)}';

  static String sectorRotation(String sectorId) =>
      '${sector(sectorId)}/rotacion';

  static String sectorHistory(String sectorId) =>
      '${sector(sectorId)}/historial';

  static String sectorApiary(String sectorId) =>
      '${sector(sectorId)}/apicultura';

  static String labor(String type, {String? sectorId}) =>
      _withSector('$register/labor/$type', sectorId);

  static String laborEdit(String laborId) =>
      '$register/labor/editar/${Uri.encodeComponent(laborId)}';

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

  static String reminder(String reminderId) =>
      '$reminders/${Uri.encodeComponent(reminderId)}';

  static String _withSector(String path, String? sectorId) {
    final value = sectorId?.trim();
    if (value == null || value.isEmpty) return path;
    return Uri(path: path, queryParameters: {'sectorId': value}).toString();
  }
}
