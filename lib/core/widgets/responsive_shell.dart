import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.child});

  final Widget child;

  static const destinations = [
    _Destination('Inicio', Icons.home_outlined, '/home'),
    _Destination('Mapa', Icons.map_outlined, '/mapa'),
    _Destination('Rede', Icons.people_outline, '/contatos'),
    _Destination('Perfil', Icons.person_outline, '/perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final location = GoRouterState.of(context).uri.path;
    final index = destinations.indexWhere((item) => location.startsWith(item.path));
    final selectedIndex = index < 0 ? 0 : index;

    if (width >= 900) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) => context.go(destinations[value].path),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final item in destinations)
                  NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => context.go(destinations[value].path),
        destinations: [
          for (final item in destinations)
            NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}
