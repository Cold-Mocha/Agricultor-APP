import 'package:agrocampo/app/theme/agro_tokens.dart';
import 'package:agrocampo/shared/presentation/semantics/agro_semantics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_outlined),
            label: 'Sectores',
          ),
          NavigationDestination(
            icon: _RegisterNavIcon(),
            selectedIcon: _RegisterNavIcon(selected: true),
            label: 'Registrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome_outlined),
            label: 'AgroIA',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps_outlined),
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
      Icons.add_outlined,
      color: selected
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onPrimaryContainer,
    ),
  );
}
