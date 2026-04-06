import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/providers/user_provider.dart';
import '../../../../shared/widgets/finn_button.dart';
import '../../../goals/domain/entities/goal_entity.dart';
import '../../../goals/domain/entities/goal_type.dart';
import '../../../goals/presentation/providers/goals_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _incomeController = TextEditingController();
  int _page = 0;
  bool _showPreview = false;
  double? _enteredIncome;

  final _slides = const <_SlideData>[
    _SlideData(
      title: AppStrings.onboardingTrackTitle,
      body: AppStrings.onboardingTrackBody,
      assetPath: AppAssets.onboardingTrack,
    ),
    _SlideData(
      title: AppStrings.onboardingUnderstandTitle,
      body: AppStrings.onboardingUnderstandBody,
      assetPath: AppAssets.onboardingUnderstand,
    ),
    _SlideData(
      title: AppStrings.onboardingGrowTitle,
      body: AppStrings.onboardingGrowBody,
      assetPath: AppAssets.onboardingGrow,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showPreview) {
      return _buildPreviewCard(context);
    }

    final isLastPage = _page == _slides.length;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: SvgPicture.asset(
                        'assets/images/finn_wordmark.svg',
                        height: 24,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _finish,
                      child: const Text('Skip'),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemCount: _slides.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _slides.length) {
                      return _buildIncomeStep(context);
                    }
                    final slide = _slides[index];
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
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
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Lottie.asset(
                                slide.assetPath,
                                repeat: true,
                                fit: BoxFit.contain,
                              ),
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
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        _slides.length + 1,
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
                      label: isLastPage ? 'Continue' : 'Next',
                      onPressed: () {
                        if (isLastPage) {
                          _processIncome();
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeStep(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '💸',
            style: TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 24),
          Text(
            'One quick thing —\nwhat\'s your monthly income?',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'We\'ll use this to suggest a healthy savings goal. You can change it later.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _incomeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'e.g. 50000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final savings = (_enteredIncome ?? 0) * 0.20;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '💰',
                style: TextStyle(fontSize: 80),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Based on your income, saving ${savings.toStringAsFixed(0)} this month is a great start.',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'This is the 50/30/20 rule in action.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FinnButton(
                label: 'Create this goal',
                onPressed: () async {
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    final now = DateTime.now();
                    final goal = GoalEntity(
                      id: const Uuid().v4(),
                      title: 'Monthly Savings Goal',
                      type: GoalType.savings,
                      targetAmount: savings,
                      currentAmount: 0,
                      deadline: DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1)),
                      icon: '💰',
                      colorHex: '0xFF34A853',
                      createdAt: now,
                      updatedAt: now,
                    );
                    await ref.read(createGoalUseCaseProvider)(
                      uid: user.uid,
                      goal: goal,
                    );
                  }
                  _finish();
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _finish,
                child: const Text('I\'ll do it myself'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processIncome() {
    final text = _incomeController.text.trim();
    if (text.isEmpty) {
      _finish();
      return;
    }
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      _finish();
      return;
    }
    ref.read(appSessionProvider).saveMonthlyIncome(amount);
    setState(() {
      _enteredIncome = amount;
      _showPreview = true;
    });
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
    required this.assetPath,
  });

  final String title;
  final String body;
  final String assetPath;
}
