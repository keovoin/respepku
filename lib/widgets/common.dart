import 'package:flutter/material.dart' hide Banner;
import 'package:provider/provider.dart';
import '../data/local_db.dart';
import '../i18n/localizations.dart';
import '../models/meal.dart';
import '../screens/cart_screen.dart';
import '../screens/detail_screen.dart';
import '../state/app_state.dart';
import '../state/shop_state.dart';
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
              child: Text(context.t('see_all'),
                  style: const TextStyle(height: 1.4, fontSize: 13, fontWeight: FontWeight.w600)),
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
    final kh = context.useKhmer;
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
                  Text(meal.nameIn(kh),
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
                        Text(context.t('min_short', n: '${meal.minutes}'),
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
    final kh = context.useKhmer;
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
                  Text(meal.nameIn(kh),
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
                      Text(context.t(catKey(meal.category)),
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

/// Store shelf: buy-able ingredient sets (from the live backend catalog).
class StoreSection extends StatelessWidget {
  const StoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    if (!shop.loaded || shop.sets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        SectionHeader(
          title: context.t('store_section'),
          onSeeAll: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 208,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: shop.sets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _SetCard(set: shop.sets[i]),
          ),
        ),
      ],
    );
  }
}

/// Live promo banners from the store, shown as a horizontal carousel on Home.
class ShopBannerCarousel extends StatelessWidget {
  const ShopBannerCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final banners = shop.banners;
    if (!shop.loaded || banners.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        itemCount: banners.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _BannerCard(banner: banners[i]),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final Banner banner;
  const _BannerCard({required this.banner});

  void _tap(BuildContext context) {
    final link = banner.link;
    if (link.startsWith('promo:')) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CartScreen(promoHint: link.substring(6))),
      );
      return;
    }
    if (link.startsWith('meal:')) {
      final m = MealApi.lookup(link.substring(5));
      if (m != null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => DetailScreen(meal: m)));
        return;
      }
    }
    if (link.isNotEmpty) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CartScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.useKhmer;
    return GestureDetector(
      onTap: () => _tap(context),
      child: Container(
        width: 240,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: C.line),
          color: C.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            fit: StackFit.expand,
            children: [
              banner.imageUrl.isNotEmpty
                  ? Image.network(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFFF9A3D)),
                    )
                  : Container(color: const Color(0xFFFF9A3D)),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xB0000000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(banner.title(kh),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              height: 1.3,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      if (banner.subtitle(kh).isNotEmpty)
                        Text(banner.subtitle(kh),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                height: 1.3,
                                fontSize: 11.5,
                                color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  final RecipeSet set;
  const _SetCard({required this.set});

  @override
  Widget build(BuildContext context) {
    final shop = context.read<ShopState>();
    final inCart = shop.cartQty(set.id);
    final kh = context.useKhmer;
    return Container(
      width: 168,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: C.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: set.imageUrl != null && set.imageUrl!.isNotEmpty
                  ? Image.network(
                      set.imageUrl!,
                      fit: BoxFit.cover,
                      width: 148,
                      height: 88,
                      errorBuilder: (_, __, ___) => _SetFallback(set),
                    )
                  : _SetFallback(set),
            ),
          ),
          const SizedBox(height: 8),
          Text(set.name(kh),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(height: 1.4,
                  fontSize: 14, fontWeight: FontWeight.w700, color: C.ink)),
          const SizedBox(height: 2),
          Text(shop.money(set.price),
              style: const TextStyle(height: 1.4,
                  fontSize: 14, fontWeight: FontWeight.w800, color: C.primary)),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: inCart == 0
                ? FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: C.primary, padding: const EdgeInsets.symmetric(vertical: 8)),
                    onPressed: () => shop.addToCart(set),
                    child: Text(context.t('add'),
                        style: const TextStyle(height: 1.4,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  )
                : FilledButton.tonal(
                    style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8)),
                    onPressed: () => shop.setQty(set, inCart - 1),
                    child: Text(context.t('in_cart', n: '$inCart'),
                        style: const TextStyle(height: 1.4, fontSize: 13, fontWeight: FontWeight.w700))),
          ),
        ],
      ),
    );
  }
}

class _SetFallback extends StatelessWidget {
  final RecipeSet set;
  const _SetFallback(this.set);

  @override
  Widget build(BuildContext context) {
    final meal = MealApi.lookup(set.mealId);
    return MealImage(
      meal: meal ??
          Meal(
            id: set.mealId,
            name: set.nameEn,
            image: 'assets/food/${set.mealId}.jpg',
          ),
      width: 148,
      height: 88,
    );
  }
}
