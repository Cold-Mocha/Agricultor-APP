import 'package:agrocampo/src/modules/auth/presentation/controllers/session_controller.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// master.md: progreso y errores recuperables; acceso sin credenciales solicitado.
final class DeviceAccessPage extends ConsumerWidget {
  const DeviceAccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final locked = session.status == SessionStatus.locked;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (session.status == SessionStatus.restoring)
                const CircularProgressIndicator()
              else ...[
                Text(
                  session.message ??
                      (locked
                          ? 'Desbloquea tu dispositivo para abrir AgroCampo.'
                          : 'No fue posible abrir tus datos.'),
                ),
                FilledButton(
                  onPressed: () => locked
                      ? ref
                            .read(sessionControllerProvider.notifier)
                            .unlockWithBiometrics()
                      : ref.read(sessionControllerProvider.notifier).restore(),
                  child: Text(locked ? 'Desbloquear' : 'Reintentar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
