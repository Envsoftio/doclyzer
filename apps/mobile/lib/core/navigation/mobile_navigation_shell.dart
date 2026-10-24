import 'package:flutter/material.dart';

/// Main destinations only; pushed details keep the full screen and native back.
class MobileNavigationShell extends StatelessWidget {
  const MobileNavigationShell({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onBackToHome,
    required this.child,
    this.isChangingDestination = false,
    this.contentIndex,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onBackToHome;
  final Widget child;
  final bool isChangingDestination;

  /// The page already on screen while a new destination is being checked.
  final int? contentIndex;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: selectedIndex == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) onBackToHome();
    },
    child: Scaffold(
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: isChangingDestination,
            child: ClipRect(
              child: AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  fit: StackFit.expand,
                  children: [
                    for (final previous in previousChildren)
                      IgnorePointer(child: previous),
                    ?currentChild,
                  ],
                ),
                transitionBuilder: (page, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: page,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(contentIndex ?? selectedIndex),
                  child: child,
                ),
              ),
            ),
          ),
          if (isChangingDestination)
            Positioned.fill(
              child: Scaffold(
                key: const Key('tab-loading-page'),
                appBar: AppBar(
                  title: Text(selectedIndex == 1 ? 'Reports' : 'Trends'),
                  leading: selectedIndex == 0
                      ? null
                      : BackButton(onPressed: onBackToHome),
                ),
                body: const Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Opening page',
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
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
            icon: Icon(Icons.show_chart_outlined),
            selectedIcon: Icon(Icons.show_chart_rounded),
            label: 'Trends',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Family',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
        ],
      ),
    ),
  );
}
