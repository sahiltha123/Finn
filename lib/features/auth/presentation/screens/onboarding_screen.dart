import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/widgets/finn_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  final _slides = const <_SlideData>[
    _SlideData(
      title: AppStrings.onboardingTrackTitle,
      body: AppStrings.onboardingTrackBody,
      icon: Icons.auto_graph_rounded,
    ),
    _SlideData(
      title: AppStrings.onboardingUnderstandTitle,
      body: AppStrings.onboardingUnderstandBody,
      icon: Icons.insights_rounded,
    ),
    _SlideData(
      title: AppStrings.onboardingGrowTitle,
      body: AppStrings.onboardingGrowBody,
      icon: Icons.flag_circle_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLastPage = _page == _slides.length - 1;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colors.primary.withValues(alpha: 0.18),
                                colors.secondary.withValues(alpha: 0.18),
                              ],
                            ),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 92,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          slide.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.body,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == index ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == index
                          ? colors.primary
                          : colors.outline.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FinnButton(
                label: isLastPage ? 'Choose currency' : 'Next',
                onPressed: () {
                  if (isLastPage) {
                    _finish();
                    return;
                  }
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    await ref.read(appSessionProvider).completeOnboarding();
    if (!mounted) return;
    context.go(AppRoutes.currency);
  }
}

class _SlideData {
  const _SlideData({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
