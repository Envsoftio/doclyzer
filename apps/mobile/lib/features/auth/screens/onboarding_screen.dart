import 'package:mobile/l10n/l10n.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_components.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const _pageIcons = [
    Icons.folder_copy_outlined,
    Icons.fact_check_outlined,
    Icons.show_chart_rounded,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _pageIcons.length - 1) {
      widget.onComplete();
      return;
    }
    _controller.animateToPage(
      _page + 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final pages = [
      (
        eyebrow: l10n.onboardingStoreEyebrow,
        title: l10n.onboardingStoreTitle,
        body: l10n.onboardingStoreBody,
        icon: _pageIcons[0],
      ),
      (
        eyebrow: l10n.onboardingUnderstandEyebrow,
        title: l10n.onboardingUnderstandTitle,
        body: l10n.onboardingUnderstandBody,
        icon: _pageIcons[1],
      ),
      (
        eyebrow: l10n.onboardingTrackEyebrow,
        title: l10n.onboardingTrackTitle,
        body: l10n.onboardingTrackBody,
        icon: _pageIcons[2],
      ),
    ];
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  const DoclyzerMark(size: 36),
                  const SizedBox(width: 9),
                  Text('doclyzer', style: theme.textTheme.titleLarge),
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onComplete,
                    child: Text(context.l10n.uiSkip),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      right: -35,
                                      top: -35,
                                      child: CircleAvatar(
                                        radius: 100,
                                        backgroundColor: AppColors.teal
                                            .withValues(alpha: .22),
                                      ),
                                    ),
                                    Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color:
                                              theme.colorScheme.outlineVariant,
                                        ),
                                      ),
                                      child: Icon(
                                        page.icon,
                                        size: 78,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          page.eyebrow,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.title,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontSize: 30,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var index = 0; index < pages.length; index++)
                        AnimatedContainer(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 220),
                          width: index == _page ? 20 : 7,
                          height: 7,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: index == _page
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _next,
                    child: Text(
                      _page == pages.length - 1
                          ? l10n.onboardingGetStarted
                          : l10n.onboardingNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
