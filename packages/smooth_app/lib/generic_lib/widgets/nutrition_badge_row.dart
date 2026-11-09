import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/services/nutrition_badge_evaluator.dart';

class NutritionBadgeRow extends StatelessWidget {
  const NutritionBadgeRow({
    required this.badges,
    required this.product,
    this.size = 28.0,
    this.leading = const <Widget>[],
    super.key,
  });

  final List<NutritionBadge> badges;
  final Product product;
  final double size;
  final List<Widget> leading;

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty && leading.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        ...leading,
        for (final NutritionBadge badge in badges)
          _NutritionBadgeIcon(badge: badge, product: product, size: size),
      ],
    );
  }
}

class _NutritionBadgeIcon extends StatelessWidget {
  const _NutritionBadgeIcon({
    required this.badge,
    required this.product,
    required this.size,
  });

  final NutritionBadge badge;
  final Product product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    final String label = _label(localizations, badge);
    final NutritionBadgeNutrientReading? reading =
        const NutritionBadgeEvaluator().readingFor(product, badge);
    final String tooltip = reading == null
        ? label
        : localizations.nutrition_badge_measurement_tooltip(
            label,
            _format(reading.value, reading.unit),
            reading.unit,
          );
    final String details = _details(localizations, reading);

    return Semantics(
      label: tooltip,
      button: true,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) => SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8.0),
                    Text(details),
                  ],
                ),
              ),
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              badge.assetPath,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? _) =>
                      SizedBox.square(
                        dimension: size,
                        child: const ColoredBox(
                          color: Color(0xFFE0E0E0),
                          child: Icon(Icons.warning_amber_rounded),
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }

  static String _format(double value, String unit) =>
      value.toStringAsFixed(unit == 'kcal' ? 0 : 1);

  static String _label(AppLocalizations localizations, NutritionBadge badge) =>
      switch (badge) {
        NutritionBadge.highSugar =>
          localizations.nutrition_badge_high_sugar_label,
        NutritionBadge.highSodium =>
          localizations.nutrition_badge_high_sodium_label,
        NutritionBadge.highSaturatedFat =>
          localizations.nutrition_badge_high_saturated_fat_label,
        NutritionBadge.highCalories =>
          localizations.nutrition_badge_high_calories_label,
        NutritionBadge.containsTransFat =>
          localizations.nutrition_badge_contains_trans_fat_label,
        NutritionBadge.containsAddedSugar =>
          localizations.nutrition_badge_contains_added_sugar_label,
        NutritionBadge.containsPalmOil =>
          localizations.nutrition_badge_contains_palm_oil_label,
        NutritionBadge.containsArtificialColours =>
          localizations.nutrition_badge_contains_artificial_colours_label,
        NutritionBadge.safeChoice =>
          localizations.nutrition_badge_safe_choice_label,
      };

  String _details(
    AppLocalizations localizations,
    NutritionBadgeNutrientReading? reading,
  ) {
    if (reading != null) {
      final String details = localizations.nutrition_badge_nutrient_details(
        _format(reading.value, reading.unit),
        reading.unit,
        _format(reading.threshold, reading.unit),
        reading.thresholdBasis,
      );
      if (NutritionBadgeEvaluator.isLiquidProduct(product)) {
        return '$details ${localizations.nutrition_badge_liquid_data_note}';
      }
      return details;
    }

    return switch (badge) {
      NutritionBadge.containsTransFat =>
        localizations.nutrition_badge_contains_trans_fat_details,
      NutritionBadge.containsAddedSugar =>
        localizations.nutrition_badge_contains_added_sugar_details,
      NutritionBadge.containsPalmOil =>
        localizations.nutrition_badge_contains_palm_oil_details,
      NutritionBadge.containsArtificialColours =>
        localizations.nutrition_badge_contains_artificial_colours_details,
      NutritionBadge.safeChoice =>
        localizations.nutrition_badge_safe_choice_details,
      NutritionBadge.highSugar ||
      NutritionBadge.highSodium ||
      NutritionBadge.highSaturatedFat ||
      NutritionBadge.highCalories => _label(localizations, badge),
    };
  }
}
