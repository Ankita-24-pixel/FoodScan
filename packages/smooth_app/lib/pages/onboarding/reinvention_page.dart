import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/onboarding_loader.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/onboarding/onboarding_flow_navigator.dart';
import 'package:smooth_app/pages/onboarding/v2/onboarding_bottom_hills.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';
import 'package:smooth_app/widgets/text/text_highlighter.dart';

/// Onboarding page: "reinvention"
class OnboardingHomePage extends StatelessWidget {
  const OnboardingHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SmoothBrightnessOverride(
      brightness: Brightness.dark,
      child: SmoothScaffold(
        backgroundColor: const Color(0xFFFFFBF0),
        body: Provider<OnboardingConfig>.value(
          value: OnboardingConfig._(MediaQuery.sizeOf(context)),
          child: Stack(
            children: <Widget>[
              const _OnboardingWelcomePageContent(),
              OnboardingBottomHills(
                onTap: () async {
                  final UserPreferences userPreferences = context
                      .read<UserPreferences>();
                  final LocalDatabase localDatabase = context
                      .read<LocalDatabase>();

                  /// Enable crash reports and user tracking by default
                  /// (Can be disabled by the user later in the settings)
                  await userPreferences.setCrashReports(true);
                  await userPreferences.setUserTracking(true);

                  if (context.mounted) {
                    await OnboardingLoader(
                      localDatabase,
                    ).runAtNextTime(OnboardingPage.HOME_PAGE, context);
                  }

                  if (context.mounted) {
                    await OnboardingFlowNavigator(
                      userPreferences,
                    ).navigateToPage(
                      context,
                      OnboardingPage.HOME_PAGE.getNextPage(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingWelcomePageContent extends StatelessWidget {
  const _OnboardingWelcomePageContent();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final double fontMultiplier = OnboardingConfig.of(context).fontMultiplier;
    final double hillsHeight = OnboardingBottomHills.height(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: hillsHeight * 0.5 + MediaQuery.viewPaddingOf(context).top,
        bottom: hillsHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 15,
            child: Text(
              appLocalizations.onboarding_home_welcome_text1,
              style: TextStyle(
                fontSize: 45 * fontMultiplier,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(flex: 37, child: _FoodScanLogo()),
          Expanded(
            flex: 45,
            child: FractionallySizedBox(
              widthFactor: 0.65,
              child: Align(
                alignment: const Alignment(0, -0.2),
                child: TextWithBubbleParts(
                  text: appLocalizations.onboarding_home_welcome_text2,
                  fontMultiplier: fontMultiplier,
                  backgroundColor: context
                      .extension<SmoothColorsThemeExtension>()
                      .secondaryVibrant,
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    fontSize: 26,
                    height: 1.48,
                    fontWeight: FontWeight.w600,
                  ),
                  bubblePadding: const EdgeInsetsDirectional.only(
                    top: 1.0,
                    bottom: 5.0,
                    start: 15.0,
                    end: 15.0,
                  ),
                  bubbleTextStyle: const TextStyle(
                    fontSize: 22,
                    height: 1.53,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodScanLogo extends StatelessWidget {
  const _FoodScanLogo();

  @override
  Widget build(BuildContext context) => Center(
    child: Image.asset(
      'assets/app/foodscan_logo.png',
      width: 220,
      fit: BoxFit.contain,
    ),
  );
}

// TODO(g123k): Move elsewhere when the onboarding will be redesigned
class OnboardingConfig {
  OnboardingConfig._(Size screenSize)
    : fontMultiplier = computeFontMultiplier(screenSize);
  final double fontMultiplier;

  static double computeFontMultiplier(Size screenSize) =>
      ((screenSize.width * 45) / 428) / 45;

  static OnboardingConfig of(BuildContext context) =>
      context.watch<OnboardingConfig>();
}
