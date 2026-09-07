import 'package:agrocampo/app/routing/app_router.dart';
import 'package:agrocampo/app/theme/agro_theme.dart';
import 'package:agrocampo_backend/agrocampo_backend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AgroCampoApp extends ConsumerStatefulWidget {
  const AgroCampoApp({super.key});

  @override
  ConsumerState<AgroCampoApp> createState() => _AgroCampoAppState();
}

final class _AgroCampoAppState extends ConsumerState<AgroCampoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.microtask(ref.read(appLifecycleControllerProvider).restore);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    Future<void>.microtask(ref.read(appLifecycleControllerProvider).resume);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'AgroCampo',
      debugShowCheckedModeBanner: false,
      theme: AgroTheme.light,
      locale: const Locale('es', 'CL'),
      supportedLocales: const [Locale('es', 'CL')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: router,
      restorationScopeId: 'agrocampo',
    );
  }
}
