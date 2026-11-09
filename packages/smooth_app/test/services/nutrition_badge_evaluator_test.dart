import 'package:flutter_test/flutter_test.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/services/nutrition_badge_evaluator.dart';
import 'package:smooth_app/services/nutrition_thresholds.dart';

void main() {
  const NutritionBadgeEvaluator evaluator = NutritionBadgeEvaluator();

  group('NutritionBadgeEvaluator', () {
    test('evaluates high nutrient badges in the required order', () {
      final List<NutritionBadge> badges = evaluator.evaluate(
        _product(
          sugar: 22.6,
          salt: 1.6,
          saturatedFat: 5.1,
          calories: 401,
          ingredients: 'Water',
        ),
      );

      expect(badges, <NutritionBadge>[
        NutritionBadge.highSugar,
        NutritionBadge.highSodium,
        NutritionBadge.highSaturatedFat,
        NutritionBadge.highCalories,
      ]);
    });

    test('does not flag nutrient values at solid cutoffs', () {
      expect(
        evaluator.evaluate(
          _product(
            sugar: NutritionThresholds.highSugarSolidsGrams,
            salt: NutritionThresholds.highSodiumSaltSolidsGrams,
            saturatedFat: NutritionThresholds.highSaturatedFatSolidsGrams,
            calories: NutritionThresholds.highCaloriesSolidsKcal,
            ingredients: 'Water',
          ),
        ),
        <NutritionBadge>[NutritionBadge.safeChoice],
      );
    });

    test('applies stricter liquid cutoffs to beverage categories', () {
      final Product beverage = _product(
        sugar: 11.3,
        salt: 0.8,
        saturatedFat: 2.6,
        calories: 101,
        ingredients: 'Water',
        categories: <String>['en:beverages'],
      );

      expect(evaluator.evaluate(beverage), <NutritionBadge>[
        NutritionBadge.highSugar,
        NutritionBadge.highSodium,
        NutritionBadge.highSaturatedFat,
        NutritionBadge.highCalories,
      ]);
      expect(
        evaluator
            .readingFor(beverage, NutritionBadge.highSugar)!
            .thresholdBasis,
        'ml',
      );
    });

    test('does not flag liquid values at liquid cutoffs', () {
      expect(
        evaluator.evaluate(
          _product(
            sugar: NutritionThresholds.highSugarLiquidsGrams,
            salt: NutritionThresholds.highSodiumSaltLiquidsGrams,
            saturatedFat: NutritionThresholds.highSaturatedFatLiquidsGrams,
            calories: NutritionThresholds.highCaloriesLiquidsKcal,
            ingredients: 'Water',
            categories: <String>['en:drinks'],
          ),
        ),
        <NutritionBadge>[NutritionBadge.safeChoice],
      );
    });

    test('uses sodium when salt is not available', () {
      expect(
        evaluator.evaluate(_product(sodium: 0.61, ingredients: 'Water')),
        contains(NutritionBadge.highSodium),
      );
    });

    test('flags trans fat from nutrient data or hydrogenated ingredients', () {
      expect(
        evaluator.evaluate(_product(transFat: 0.01, ingredients: 'Water')),
        contains(NutritionBadge.containsTransFat),
      );
      expect(
        evaluator.evaluate(
          _product(ingredients: 'Partially HYDROGENATED vegetable oil'),
        ),
        contains(NutritionBadge.containsTransFat),
      );
      expect(
        evaluator.evaluate(_product(ingredients: 'Hydrogenated vegetable fat')),
        contains(NutritionBadge.containsTransFat),
      );
      expect(
        evaluator.evaluate(_product(ingredients: 'Vanaspati')),
        contains(NutritionBadge.containsTransFat),
      );
    });

    test('flags added sugar from nutrient data or ingredient text', () {
      expect(
        evaluator.evaluate(_product(addedSugars: 0.1, ingredients: 'Water')),
        contains(NutritionBadge.containsAddedSugar),
      );
      expect(
        evaluator.evaluate(
          _product(ingredients: 'Water, INVERT SUGAR, maltodextrin'),
        ),
        contains(NutritionBadge.containsAddedSugar),
      );
    });

    test('flags palm oil and artificial colours case-insensitively', () {
      final List<NutritionBadge> badges = evaluator.evaluate(
        _product(
          ingredients: 'Palmolein, INS 102, SUNSET YELLOW, added colour',
        ),
      );

      expect(badges, <NutritionBadge>[
        NutritionBadge.containsPalmOil,
        NutritionBadge.containsArtificialColours,
      ]);
    });

    test('recognizes the requested palm oil and colour names', () {
      for (final String ingredient in <String>[
        'PALM OIL',
        'palm fat',
        'vegetable oil (palm kernel)',
      ]) {
        expect(
          evaluator.evaluate(_product(ingredients: ingredient)),
          contains(NutritionBadge.containsPalmOil),
          reason: ingredient,
        );
      }

      for (final String ingredient in <String>[
        'INS 110',
        'INS 129',
        'tartrazine',
        'carmoisine',
        'allura red',
        'synthetic color',
        'artificial colours',
      ]) {
        expect(
          evaluator.evaluate(_product(ingredients: ingredient)),
          contains(NutritionBadge.containsArtificialColours),
          reason: ingredient,
        );
      }
    });

    test(
      'shows safe choice only with complete core data and clean ingredients',
      () {
        expect(
          evaluator.evaluate(
            _product(
              sugar: 2,
              salt: 0.2,
              saturatedFat: 1,
              ingredients: 'Water, oats',
            ),
          ),
          <NutritionBadge>[NutritionBadge.safeChoice],
        );
      },
    );

    test('does not show safe choice when required data is missing', () {
      expect(
        evaluator.evaluate(
          _product(sugar: 2, saturatedFat: 1, ingredients: 'Water'),
        ),
        isNot(contains(NutritionBadge.safeChoice)),
      );
      expect(
        evaluator.evaluate(_product(sugar: 2, salt: 0.2, saturatedFat: 1)),
        isNot(contains(NutritionBadge.safeChoice)),
      );
      expect(
        evaluator.evaluate(
          _product(
            sugar: 2,
            salt: 0.2,
            saturatedFat: 1,
            ingredients: 'Water, palm oil',
          ),
        ),
        isNot(contains(NutritionBadge.safeChoice)),
      );
    });

    test('skips missing nutrient checks without guessing', () {
      expect(evaluator.evaluate(_product(ingredients: 'Water')), isEmpty);
      expect(
        evaluator.evaluate(_product(sugar: 23, ingredients: 'Water')),
        <NutritionBadge>[NutritionBadge.highSugar],
      );
    });
  });
}

Product _product({
  double? sugar,
  double? salt,
  double? sodium,
  double? saturatedFat,
  double? calories,
  double? transFat,
  double? addedSugars,
  String? ingredients,
  List<String>? categories,
}) {
  final Nutriments nutriments = Nutriments.empty();
  void setValue(Nutrient nutrient, double? value) {
    if (value != null) {
      nutriments.setValue(nutrient, PerSize.oneHundredGrams, value);
    }
  }

  setValue(Nutrient.sugars, sugar);
  setValue(Nutrient.salt, salt);
  setValue(Nutrient.sodium, sodium);
  setValue(Nutrient.saturatedFat, saturatedFat);
  setValue(Nutrient.energyKCal, calories);
  setValue(Nutrient.transFat, transFat);
  setValue(Nutrient.addedSugars, addedSugars);

  return Product(
    nutriments: nutriments,
    ingredientsText: ingredients,
    categoriesTags: categories,
  );
}
