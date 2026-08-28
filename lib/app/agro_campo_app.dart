import 'package:agrocampo/app/routing/app_router.dart';
import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo/features/auth/presentation/session_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AgroCampoApp extends ConsumerStatefulWidget {
  const AgroCampoApp({super.key});

  @override
  ConsumerState<AgroCampoApp> createState() => _AgroCampoAppState();
}

final class _AgroCampoAppState extends ConsumerState<AgroCampoApp> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      ref.read(sessionControllerProvider.notifier).restore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'AgroCampo',
      debugShowCheckedModeBanner: false,
      theme: AgroTheme.light,
      routerConfig: router,
      restorationScopeId: 'agrocampo',
    );
  }
}
