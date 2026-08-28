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
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Sectores',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Registrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'AgroIA',
          ),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Más'),
        ],
      ),
    ),
  );
}
