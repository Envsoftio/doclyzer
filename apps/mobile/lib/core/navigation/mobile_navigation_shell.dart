import 'package:mobile/l10n/l10n.dart';
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
                  title: Text(
                    selectedIndex == 1
                        ? context.l10n.reports
                        : context.l10n.trends,
                  ),
                  leading: selectedIndex == 0
                      ? null
                      : BackButton(onPressed: onBackToHome),
                ),
                body: Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: context.l10n.openingPage,
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
        destinations:
            <Widget>[
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: context.l10n.home,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.description_outlined),
                    selectedIcon: Icon(Icons.description_rounded),
                    label: context.l10n.reports,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.show_chart_outlined),
                    selectedIcon: Icon(Icons.show_chart_rounded),
                    label: context.l10n.trends,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: context.l10n.family,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.account_circle_outlined),
                    selectedIcon: Icon(Icons.account_circle_rounded),
                    label: context.l10n.profile,
                  ),
                ]
                .map(
                  (destination) => DefaultTextStyle.merge(
                    // Keep long translations inside the existing navigation bar.
                    // NavigationDestination retains the full label in its tooltip.
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    child: destination,
                  ),
                )
                .toList(),
      ),
    ),
  );
}
