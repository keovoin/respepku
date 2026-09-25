import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/local_db.dart';
import '../models/meal.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Recipe photo.
///
/// Always reads from the bundled asset catalog (assets/food/*.jpg) —
/// no network needed. Legacy favorites saved by older app versions may
/// carry a remote URL; those are re-mapped to the local asset by id.
class MealImage extends StatelessWidget {
  final Meal meal;
  final double? width;
  final double? height;
  final BoxFit fit;
  const MealImage({
    super.key,
    required this.meal,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  String _path() {
    if (meal.image.startsWith('assets/')) return meal.image;
    return localImageFor(meal.id) ?? meal.image;
  }

  @override
  Widget build(BuildContext context) {
    final path = _path();
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: C.primarySoft,
          child: const Icon(Icons.restaurant, color: C.primary),
        ),
      );
    }
    // Not in the bundled catalog — show a placeholder, never the network.
    return Container(
      width: width,
      height: height,
      color: C.primarySoft,
      child: const Icon(Icons.restaurant, color: C.primary),
    );
  }
}

/// Best known bundled photo path for a meal id (null if not bundled).
String? localImageFor(String id) {
  for (final m in localMeals) {
    if (m.id == id) return m.image;
  }
  return null;
}

/// Section heading with optional "Lihat Semua" action.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(height: 1.4, 
                    fontSize: 17, fontWeight: FontWeight.w800, color: C.ink)),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('Lihat Semua',
                  style: TextStyle(height: 1.4, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

/// Favorite / heart button.
class FavButton extends StatelessWidget {
  final Meal meal;
  const FavButton({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final fav = st.isFavorite(meal.id);
    return GestureDetector(
      onTap: () => st.toggleFavorite(meal),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: fav ? 1.12 : 1.0,
        child: Icon(
          fav ? Icons.favorite : Icons.favorite_border,
          color: fav ? C.red : C.muted,
          size: 22,
        ),
      ),
    );
  }
}

/// Compact recipe card for horizontal rows.
class MealCardH extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  const MealCardH({super.key, required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  child: MealImage(meal: meal, width: 150, height: 108),
                ),
                Positioned(top: 8, right: 8, child: FavButton(meal: meal)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(height: 1.4, 
                          fontSize: 14, fontWeight: FontWeight.w700, color: C.ink)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (meal.rating != null) ...[
                        const Icon(Icons.star, size: 14, color: C.amber),
                        const SizedBox(width: 3),
                        Text(meal.rating!.toStringAsFixed(1),
                            style: const TextStyle(height: 1.4, 
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: C.muted)),
                      ],
                      const Spacer(),
                      if (meal.minutes != null)
                        Text('${meal.minutes} mnt',
                            style: const TextStyle(height: 1.4, 
                                fontSize: 12, color: C.muted)),
                    ],
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

/// Full-width row card (search results, favorites).
class MealCardRow extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  final bool showAdd;
  const MealCardRow(
      {super.key,
      required this.meal,
      required this.onTap,
      this.showAdd = true});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final fav = st.isFavorite(meal.id);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MealImage(meal: meal, width: 64, height: 64),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(height: 1.4, 
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: C.ink)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (meal.rating != null) ...[
                        const Icon(Icons.star, size: 14, color: C.amber),
                        const SizedBox(width: 3),
                        Text(meal.rating!.toStringAsFixed(1),
                            style:
                                const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
                      ],
                      const SizedBox(width: 10),
                      Text(meal.category,
                          style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
                    ],
                  ),
                ],
              ),
            ),
            if (showAdd)
              GestureDetector(
                onTap: () => st.toggleFavorite(meal),
                child: Icon(
                  fav ? Icons.add_circle : Icons.add_circle_outline,
                  color: C.primary,
                  size: 24,
                ),
              )
            else
              FavButton(meal: meal),
          ],
        ),
      ),
    );
  }
}
