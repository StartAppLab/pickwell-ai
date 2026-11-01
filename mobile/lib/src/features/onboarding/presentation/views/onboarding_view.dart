import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../notification/notification.dart';
import '../blocs/_blocs.dart';
import '../widgets/_widgets.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  final _nameController = TextEditingController();

  static const _notificationPromptIndex = 13;
  static const _notificationMissedIndex = 14;
  static const _allDoneIndex = 15;
  static const _congratsIndex = 16;
  bool get _notificationsEnabled => getIt<AppConfig>().features.notificationsEnabled;

  // Keep persisted slide IDs stable while removing disabled steps from the pager.
  List<int> get _steps => [
    for (var step = 0; step < (getIt<AppConfig>().features.authEnabled ? 18 : 17); step++)
      if (_notificationsEnabled ||
          !{11, 12, _notificationPromptIndex, _notificationMissedIndex}.contains(step))
        step,
  ];

  int get _totalSteps => _steps.length;

  void _jumpToStep(int step) => _pageController.jumpToPage(_steps.indexOf(step));
  bool _isAnalyzingProfile = false;
  bool _isFinishingOnboarding = false;

  @override
  void initState() {
    super.initState();
    final savedStep = context.read<OnboardingCubit>().state.slideIndex;
    final step = _steps.firstWhere((step) => step >= savedStep, orElse: () => _steps.last);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OnboardingCubit>().setSlideIndex(step);
        _jumpToStep(step);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final name = context.read<OnboardingCubit>().state.name;
    if (name != null && _nameController.text != name) {
      _nameController.text = name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isAnalyzingProfile
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: BlocBuilder<OnboardingCubit, OnboardingState>(
                buildWhen: (previous, current) => previous.slideIndex != current.slideIndex,
                builder: (context, state) => MaterialAppBar(
                  leading: state.slideIndex == 0 && !context.canPop()
                      ? const SizedBox.shrink()
                      : null,
                  onIconPressed: () {
                    final slideIndex = _pageController.page?.round() ?? 0;
                    if (slideIndex > 0) {
                      _prev();
                    } else if (context.canPop()) {
                      context.pop();
                    }
                  },
                  title: BlocBuilder<OnboardingCubit, OnboardingState>(
                    builder: (context, state) {
                      final slideIndex = state.slideIndex;
                      final didAllowNotifications = state.didAllowNotifications ?? false;

                      var totalPages = _totalSteps;
                      var currentProgressIndex = _steps
                          .indexOf(slideIndex)
                          .clamp(0, _totalSteps - 1);

                      if (_notificationsEnabled && didAllowNotifications) {
                        totalPages -= 1;
                        if (slideIndex > _notificationMissedIndex) {
                          currentProgressIndex -= 1;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (currentProgressIndex + 1) / totalPages,
                            minHeight: 6,
                            backgroundColor: context.colorScheme.surfaceContainer,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            // Onboarding Pages
            Expanded(
              child: ExpandablePageView(
                controller: _pageController,
                scrollPhysics: const NeverScrollableScrollPhysics(),
                itemCount: _totalSteps,
                onPageChanged: (index) {
                  context.read<OnboardingCubit>().setSlideIndex(_steps[index]);
                },
                itemBuilder: (context, index) {
                  switch (_steps[index]) {
                    case 0:
                      return const GenderSelectionWidget();
                    case 1:
                      return const AgeSelectionWidget();
                    case 2:
                      return NameInputWidget(controller: _nameController);
                    case 3:
                      return const FrequencySelectionWidget();
                    case 4:
                      return const ExperienceSelectionWidget();
                    case 5:
                      return const BenefitsWidget();
                    case 6:
                      return const UsesSelectionWidget();
                    case 7:
                      return const CaptureTimeSelectionWidget();
                    case 8:
                      return const GoalSelectionWidget();
                    case 9:
                      return const ChallengeSelectionWidget();
                    case 10:
                      return const PrivacyTrustWidget();
                    case 11:
                      return const DailyReminderWidget();
                    case 12:
                      return const StreakWidget();
                    case _notificationPromptIndex:
                      return const NotificationPromptWidget();
                    case _notificationMissedIndex:
                      final didAllowNotifications =
                          context.read<OnboardingCubit>().state.didAllowNotifications ?? false;
                      if (didAllowNotifications && !kDebugMode) return const SizedBox.shrink();
                      return const NotificationMissedWidget();
                    case _allDoneIndex:
                      return const AllDoneWidget();
                    case _congratsIndex:
                      return CongratsWidget(isLoading: _isAnalyzingProfile);
                    case 17:
                      return BlocBuilder<OnboardingCubit, OnboardingState>(
                        buildWhen: (previous, current) => previous.slideIndex != current.slideIndex,
                        builder: (context, state) =>
                            SaveProgressWidget(isActive: state.slideIndex == 17),
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isAnalyzingProfile
          ? null
          : SafeArea(
              child: Padding(
                padding: context.themeData.edgeInsetsData.pagePadding.copyWith(
                  top: 0,
                  bottom: MediaQuery.viewInsetsOf(context).bottom <= 0
                      ? context.themeData.edgeInsetsData.pagePadding.bottom
                      : context.themeData.edgeInsetsData.pagePadding.bottom +
                            MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: BlocBuilder<OnboardingCubit, OnboardingState>(
                  builder: (context, state) {
                    final slideIndex = state.slideIndex;

                    final lastPageIndex = _steps.last;
                    final isLastPage = slideIndex == lastPageIndex;

                    // Button configuration per slide
                    switch (slideIndex) {
                      // === Pages with validation-based Continue button ===
                      case 0: // Gender
                        return OnboardingContinueButton(
                          isValid: state.gender != null,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );
                      case 1: // Age
                        return OnboardingContinueButton(
                          isValid: state.ageRange != null,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );
                      case 2: // Name
                        return OnboardingContinueButton(
                          isValid: state.name != null && state.name!.trim().isNotEmpty,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );
                      case 3: // Frequency
                        return OnboardingContinueButton(
                          isValid: state.frequency != null,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );
                      case 4: // Experience
                        return OnboardingContinueButton(
                          isValid: state.hasUsedOtherApps != null,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );
                      case 6: // Uses
                        return OnboardingContinueButton(
                          isValid: state.selectedUseCases.isNotEmpty,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );
                      case 7: // Capture Time
                        return OnboardingContinueButton(
                          isValid: state.captureTime != null,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );
                      case 8: // Goal
                        return OnboardingContinueButton(
                          isValid: state.goal != null,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );
                      case 9: // Challenge
                        return OnboardingContinueButton(
                          isValid: state.challenge != null,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );

                      // === Pages with Continue button ===
                      case 5: // Benefits (read-only)
                      case 10: // Privacy Trust (read-only)
                      case 12: // Streak (read-only)
                        return OnboardingContinueButton(
                          isValid: true,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );

                      // === Pages with Yes/No buttons ===
                      case 11: // Daily Reminder
                        return OnboardingYesNoButtons(
                          noLabel: 'No',
                          yesLabel: 'Yes',
                          onYes: () {
                            context.read<OnboardingCubit>().setWantsDailyReminders(true);
                            _next();
                          },
                          onNo: () {
                            context.read<OnboardingCubit>().setWantsDailyReminders(false);
                            _next();
                          },
                        );

                      // === Pages with Continue/Skip buttons ===
                      case _notificationPromptIndex: // Notification Prompt
                        return OnboardingContinueWithSkipButton(
                          continueLabel: 'Enable Notifications',
                          skipLabel: 'Not Now',
                          onContinue: () async {
                            if (!_notificationsEnabled) return;
                            final granted = await NotificationManager.requestPermission();
                            if (!context.mounted) return;

                            if (granted) {
                              context.read<OnboardingCubit>().setDidAllowNotifications(true);
                              _jumpToStep(_allDoneIndex);
                            } else {
                              _next();
                            }
                          },
                          onSkip: kDebugMode
                              ? () async {
                                  _jumpToStep(_notificationMissedIndex);
                                }
                              : _next,
                        );

                      case _notificationMissedIndex: // Notification Missed
                        return OnboardingContinueWithSkipButton(
                          continueLabel: 'Go to Settings',
                          skipLabel: 'Skip',
                          onContinue: () async {
                            await openAppSettings();
                          },
                          onSkip: _next,
                        );

                      case _allDoneIndex: // All Done
                        return OnboardingContinueButton(
                          isValid: true,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );

                      case 16: // Congrats
                        return OnboardingContinueButton(
                          isValid: !_isFinishingOnboarding,
                          label: _isFinishingOnboarding ? context.l10n.loading : null,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );

                      case 17: // Save Progress
                        return const SizedBox.shrink();

                      // === Default ===
                      default:
                        return OnboardingContinueButton(
                          isValid: true,
                          isLastPage: isLastPage,
                          onPressed: _next,
                        );
                    }
                  },
                ),
              ),
            ),
    );
  }

  Future<void> _prev() async {
    FocusScope.of(context).unfocus();

    final slideIndex = _steps[_pageController.page?.round() ?? 0];
    final didAllowNotifications =
        context.read<OnboardingCubit>().state.didAllowNotifications ?? false;

    if (_notificationsEnabled && slideIndex == _allDoneIndex && didAllowNotifications) {
      _jumpToStep(_notificationPromptIndex);
      return;
    }

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    final pageIndex = _pageController.page?.round() ?? 0;
    final slideIndex = _steps[pageIndex];
    final totalPages = _totalSteps;

    if (pageIndex < totalPages - 1) {
      if (_steps[pageIndex + 1] == _congratsIndex) {
        setState(() {
          _isAnalyzingProfile = true;
        });
      }

      final didAllowNotifications =
          context.read<OnboardingCubit>().state.didAllowNotifications ?? false;

      if (slideIndex == _notificationPromptIndex && didAllowNotifications) {
        _jumpToStep(_allDoneIndex);
        return;
      }

      await _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.linear,
      );

      if (_steps[pageIndex + 1] == _congratsIndex) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isAnalyzingProfile = false;
            });
          }
        });
      }
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    if (_isFinishingOnboarding) return;
    setState(() => _isFinishingOnboarding = true);
    try {
      await getIt<OnboardingCubit>().save();
      await getIt<AppSession>().completeOnboarding();
      final destination = await AppFlowResolver.resolve();
      if (!mounted) return;
      context.go(AppFlowResolver.takeLocation(destination));
    } catch (_) {
      if (mounted) {
        AppWidgets.showErrorSnackBar(context, context.l10n.authContinueError);
      }
    } finally {
      if (mounted) setState(() => _isFinishingOnboarding = false);
    }
  }
}
