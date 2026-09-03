import 'package:agrocampo/app/agro_campo_app.dart';
import 'package:agrocampo/core/auth/auth_repository.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('signed-out owner is redirected to Acceso', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            const _SignedOutRepository(),
          ),
        ],
        child: const AgroCampoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acceso'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
  });

  testWidgets('locked owner cannot render a private route', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(const _LockedRepository()),
        ],
        child: const AgroCampoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Acceso'), findsOneWidget);
    expect(find.text('Desbloquear con biometría'), findsOneWidget);
    expect(find.text('Resumen del campo'), findsNothing);
  });
}

final class _LockedRepository implements AuthRepository {
  const _LockedRepository();

  @override
  Future<RestoredAuthSession?> restoreSession() async =>
      const RestoredAuthSession(
        ownerId: 'owner-1',
        biometricEnabled: true,
        offline: true,
      );

  @override
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> setBiometricEnabled(bool enabled) async {}

  @override
  Future<void> signOut() async {}
}

final class _SignedOutRepository implements AuthRepository {
  const _SignedOutRepository();

  @override
  Future<RestoredAuthSession?> restoreSession() async => null;

  @override
  Future<AuthenticatedOwner> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> setBiometricEnabled(bool enabled) async {}

  @override
  Future<void> signOut() async {}
}
