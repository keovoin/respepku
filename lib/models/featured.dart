import '../data/khmer_meals.dart';
import 'meal.dart';

/// Hand-crafted featured recipe: Amok Trey — Cambodia's national dish.
/// Sourced from the offline Khmer collection (real TheMealDB data, id 53495).
Meal getFeaturedMeal() => const Meal(
      id: '53495',
      name: 'Amok Trey – Cambodian Fish Curry',
      image:
          'https://www.themealdb.com/images/media/meals/diuub11782687570.jpg',
      area: 'Cambodia',
      category: 'Seafood',
      tags: 'Khmer,Coconut,Curry',
      ingredients: [
        Ingredient('Fish fillet', '1 lb'),
        Ingredient('Coconut Milk', '1 Can'),
        Ingredient('Kaffir Lime Leaves', '2'),
        Ingredient('Banana Leaves', 'Handful'),
        Ingredient('Cilantro', 'Garnish'),
        Ingredient('Lime', 'Garnish'),
      ],
      bumbu: [
        Ingredient('Red Curry Paste', '2 tablespoons'),
        Ingredient('Fish Sauce', '1 tablespoon'),
        Ingredient('Brown Sugar', '1 tsp'),
        Ingredient('Chicken Stock', '1 cup'),
        Ingredient('Egg', '1'),
        Ingredient('Vegetable Oil', '1 tablespoon'),
      ],
      instructions:
          'In a medium bowl, combine the coconut milk, red curry paste, fish sauce, palm sugar, and broth, whisking until smooth.\n'
          'Heat the vegetable oil in a large skillet over medium heat for 30 seconds until shimmering.\n'
          'Pour the coconut milk mixture into the skillet and bring it to a gentle simmer, stirring occasionally, for 3-4 minutes.\n'
          'Add the fish cubes and kaffir lime leaves, submerging them fully in the sauce.\n'
          'Reduce the heat to low, cover, and let it cook for 10 minutes until the fish is opaque and flakes easily.\n'
          'Stir in the beaten egg slowly, cooking for 2 more minutes until the sauce thickens slightly into a custard-like texture.\n'
          'Prepare the banana leaves by briefly passing them over a flame for 10 seconds to make them pliable.\n'
          'Spoon the curry into the center of each banana leaf square, folding the edges to form a tight packet.\n'
          'Steam the packets over boiling water for 10 minutes until heated through and fragrant.\n'
          'Unwrap, garnish with fresh cilantro and lime wedges, and serve.',
      rating: 4.8,
      ratingsCount: 320,
      minutes: 35,
      difficulty: 'Medium',
      servings: 2,
      kcal: 480,
      carb: 12,
      protein: 34,
      fat: 36,
    );

/// The full offline Khmer collection, led by the featured dish.
List<Meal> featuredKhmerMeals() => khmerMeals;
