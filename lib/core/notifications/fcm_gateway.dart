import 'package:agrocampo/core/database/app_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final class FcmGateway {
  const FcmGateway(this._messaging);

  final FirebaseMessaging _messaging;

  Future<String?> registerInstallation(
    AppDatabase database,
    String ownerId,
    String installationId,
  ) async {
    final permission = await _messaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      return null;
    }
    final token = await _messaging.getToken();
    if (token == null) return null;
    await database
        .into(database.deviceInstallations)
        .insertOnConflictUpdate(
          DeviceInstallationsCompanion.insert(
            id: installationId,
            ownerId: ownerId,
            fcmToken: token,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return token;
  }
}
