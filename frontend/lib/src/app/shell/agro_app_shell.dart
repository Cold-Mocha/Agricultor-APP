import 'package:agrocampo/src/app/theme/agro_tokens.dart';
import 'package:agrocampo/src/shared/design_system/semantics/agro_semantics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

final class AgroAppShell extends StatelessWidget {
  const AgroAppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: Semantics(
      label: AgroSemantics.primaryNavigation,
      child: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.home),
            selectedIcon: Icon(LucideIcons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.layoutGrid),
            selectedIcon: Icon(LucideIcons.layoutGrid),
            label: 'Sectores',
          ),
          NavigationDestination(
            icon: _RegisterNavIcon(),
            selectedIcon: _RegisterNavIcon(selected: true),
            label: 'Registrar',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.sparkles),
            selectedIcon: Icon(LucideIcons.sparkles),
            label: 'AgroIA',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.grid2x2),
            selectedIcon: Icon(LucideIcons.grid2x2),
            label: 'Más',
          ),
        ],
      ),
    ),
  );
}

final class _RegisterNavIcon extends StatelessWidget {
  const _RegisterNavIcon({this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: AgroSizes.touchTarget,
    height: AgroSizes.touchTarget,
    decoration: BoxDecoration(
      color: selected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(AgroRadii.medium),
    ),
    child: Icon(
      LucideIcons.plus,
      color: selected
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  );
}
