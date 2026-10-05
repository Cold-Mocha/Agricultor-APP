import 'package:agrocampo/src/modules/auth/auth_ui.dart';
import 'package:agrocampo/src/modules/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _darkModeEnabledProvider = StreamProvider.family<bool, String>(
  (ref, ownerId) =>
      ref.watch(profileControllerProvider).watchDarkModeEnabled(ownerId),
);

/// Light until an owner is unlocked and opts into dark mode in
/// Perfil > Tema; the preference is local to this device, not synced.
final themeModeProvider = Provider<ThemeMode>((ref) {
  final ownerId = ref.watch(unlockedOwnerIdProvider);
  if (ownerId == null) return ThemeMode.light;
  final enabled = ref.watch(_darkModeEnabledProvider(ownerId)).value;
  return enabled ?? false ? ThemeMode.dark : ThemeMode.light;
});
