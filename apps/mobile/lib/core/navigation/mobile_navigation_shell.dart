import 'package:flutter/material.dart';

/// Main destinations only; pushed details keep the full screen and native back.
class MobileNavigationShell extends StatelessWidget {
  const MobileNavigationShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onBackToHome,
    required this.child,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onBackToHome;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: selectedIndex == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) onBackToHome();
    },
    child: Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description_rounded),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Profiles',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    ),
  );
}
