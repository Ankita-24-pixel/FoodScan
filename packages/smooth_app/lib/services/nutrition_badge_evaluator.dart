import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/services/nutrition_thresholds.dart';

enum NutritionBadge {
  highSugar('assets/symbols/high_sugar.jpg'),
  highSodium('assets/symbols/high_sodium.jpg'),
  highSaturatedFat('assets/symbols/high_saturated_fat.jpg'),
  highCalories('assets/symbols/high_calories.jpg'),
  containsTransFat('assets/symbols/contains_trans_fat.jpg'),
  containsAddedSugar('assets/symbols/contains_added_sugar.jpg'),
  containsPalmOil('assets/symbols/contains_palm_oil.jpg'),
  containsArtificialColours('assets/symbols/contains_artificial_colours.jpg'),
  safeChoice('assets/symbols/safe_choice.jpg');

  const NutritionBadge(this.assetPath);

  final String assetPath;
}

class NutritionBadgeNutrientReading {
  const NutritionBadgeNutrientReading({
    required this.value,
    required this.threshold,
    required this.unit,
    required this.thresholdBasis,
  });

  final double value;
  final double threshold;
  final String unit;
  final String thresholdBasis;
}

class NutritionBadgeEvaluator {
  const NutritionBadgeEvaluator();

  static final RegExp _liquidCategory = RegExp(
    r'\b(?:beverages?|drinks?)\b',
    caseSensitive: false,
  );
  static final RegExp _transFatIngredients = RegExp(
    r'\bpartially\s+hydrogenated\b|\bhydrogenated\s+vegetable\s+fat\b|\bvanaspati\b',
    caseSensitive: false,
  );
  static final RegExp _addedSugarIngredients = RegExp(
    r'\b(?:sugars?|sucrose|glucose\s+syrup|fructose(?:\s+syrup)?|invert\s+sugar|jaggery|honey|dextrose|maltodextrin|corn\s+syrup|molasses|agave\s+syrup|maple\s+syrup)\b',
    caseSensitive: false,
  );
  static final RegExp _palmOilIngredients = RegExp(
    r'\bpalm\s+oil\b|\bpalmolein\b|\bpalm\s+fat\b|\bvegetable\s+oil\s*\(\s*palm\b',
    caseSensitive: false,
  );
  static final RegExp _artificialColourIngredients = RegExp(
    r'\bins\s*(?:102|110|129)\b|\btartrazine\b|\bsunset\s+yellow\b|\bcarmoisine\b|\ballura\s+red\b|\b(?:synthetic|artificial|added)\s+colou?rs?\b',
    caseSensitive: false,
  );

  List<NutritionBadge> evaluate(Product product) {
    final bool liquid = isLiquidProduct(product);
    final String? ingredients = product.ingredientsText;
    final bool hasIngredients = ingredients?.trim().isNotEmpty ?? false;
    final double? sugar = _value(product, Nutrient.sugars);
    final double? salt = _saltValue(product);
    final double? saturatedFat = _value(product, Nutrient.saturatedFat);
    final double? calories = _value(product, Nutrient.energyKCal);
    final List<NutritionBadge> badges = <NutritionBadge>[];

    if (sugar != null &&
        sugar >
            (liquid
                ? NutritionThresholds.highSugarLiquidsGrams
                : NutritionThresholds.highSugarSolidsGrams)) {
      badges.add(NutritionBadge.highSugar);
    }

    final double sodiumThreshold =
        (liquid
            ? NutritionThresholds.highSodiumSaltLiquidsGrams
            : NutritionThresholds.highSodiumSaltSolidsGrams) /
        NutritionThresholds.sodiumPerSalt;
    final double? sodium = _sodiumValue(product);
    if (sodium != null && sodium > sodiumThreshold) {
      badges.add(NutritionBadge.highSodium);
    }

    if (saturatedFat != null &&
        saturatedFat >
            (liquid
                ? NutritionThresholds.highSaturatedFatLiquidsGrams
                : NutritionThresholds.highSaturatedFatSolidsGrams)) {
      badges.add(NutritionBadge.highSaturatedFat);
    }

    if (calories != null &&
        calories >
            (liquid
                ? NutritionThresholds.highCaloriesLiquidsKcal
                : NutritionThresholds.highCaloriesSolidsKcal)) {
      badges.add(NutritionBadge.highCalories);
    }

    final double? transFat = _value(product, Nutrient.transFat);
    if ((transFat != null && transFat > 0) ||
        (hasIngredients && _transFatIngredients.hasMatch(ingredients!))) {
      badges.add(NutritionBadge.containsTransFat);
    }

    final double? addedSugars = _value(product, Nutrient.addedSugars);
    if ((addedSugars != null && addedSugars > 0) ||
        (hasIngredients && _addedSugarIngredients.hasMatch(ingredients!))) {
      badges.add(NutritionBadge.containsAddedSugar);
    }

    if (hasIngredients && _palmOilIngredients.hasMatch(ingredients!)) {
      badges.add(NutritionBadge.containsPalmOil);
    }

    if (hasIngredients && _artificialColourIngredients.hasMatch(ingredients!)) {
      badges.add(NutritionBadge.containsArtificialColours);
    }

    if (badges.isEmpty &&
        sugar != null &&
        salt != null &&
        saturatedFat != null &&
        hasIngredients) {
      badges.add(NutritionBadge.safeChoice);
    }

    return badges;
  }

  NutritionBadgeNutrientReading? readingFor(
    Product product,
    NutritionBadge badge,
  ) {
    final bool liquid = isLiquidProduct(product);
    final String thresholdBasis = liquid ? 'ml' : 'g';

    return switch (badge) {
      NutritionBadge.highSugar => _reading(
        _value(product, Nutrient.sugars),
        liquid
            ? NutritionThresholds.highSugarLiquidsGrams
            : NutritionThresholds.highSugarSolidsGrams,
        'g',
        thresholdBasis,
      ),
      NutritionBadge.highSodium => _reading(
        _sodiumValue(product),
        (liquid
                ? NutritionThresholds.highSodiumSaltLiquidsGrams
                : NutritionThresholds.highSodiumSaltSolidsGrams) /
            NutritionThresholds.sodiumPerSalt,
        'g',
        thresholdBasis,
      ),
      NutritionBadge.highSaturatedFat => _reading(
        _value(product, Nutrient.saturatedFat),
        liquid
            ? NutritionThresholds.highSaturatedFatLiquidsGrams
            : NutritionThresholds.highSaturatedFatSolidsGrams,
        'g',
        thresholdBasis,
      ),
      NutritionBadge.highCalories => _reading(
        _value(product, Nutrient.energyKCal),
        liquid
            ? NutritionThresholds.highCaloriesLiquidsKcal
            : NutritionThresholds.highCaloriesSolidsKcal,
        'kcal',
        thresholdBasis,
      ),
      NutritionBadge.containsTransFat ||
      NutritionBadge.containsAddedSugar ||
      NutritionBadge.containsPalmOil ||
      NutritionBadge.containsArtificialColours ||
      NutritionBadge.safeChoice => null,
    };
  }

  static bool isLiquidProduct(Product product) =>
      product.categoriesTags?.any(_liquidCategory.hasMatch) ?? false;

  static NutritionBadgeNutrientReading? _reading(
    double? value,
    double threshold,
    String unit,
    String thresholdBasis,
  ) => value == null
      ? null
      : NutritionBadgeNutrientReading(
          value: value,
          threshold: threshold,
          unit: unit,
          thresholdBasis: thresholdBasis,
        );

  static double? _value(Product product, Nutrient nutrient) {
    final double? value = product.nutriments?.getValue(
      nutrient,
      PerSize.oneHundredGrams,
    );
    return value != null && value.isFinite && value >= 0 ? value : null;
  }

  static double? _saltValue(Product product) {
    final double? salt = _value(product, Nutrient.salt);
    if (salt != null) {
      return salt;
    }
    final double? sodium = _value(product, Nutrient.sodium);
    return sodium == null ? null : sodium * NutritionThresholds.sodiumPerSalt;
  }

  static double? _sodiumValue(Product product) {
    final double? sodium = _value(product, Nutrient.sodium);
    if (sodium != null) {
      return sodium;
    }
    final double? salt = _value(product, Nutrient.salt);
    return salt == null ? null : salt / NutritionThresholds.sodiumPerSalt;
  }
}
