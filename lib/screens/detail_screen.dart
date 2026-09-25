import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../i18n/localizations.dart';
import '../models/meal.dart';
import '../state/app_state.dart';
import '../state/shop_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';

/// Localized difficulty label (API returns Indonesian values).
String _diff(BuildContext context, String? d) {
  switch (d) {
    case 'Mudah':
    case 'Easy':
      return context.t('easy');
    case 'Sedang':
    case 'Medium':
      return context.t('medium');
    case 'Pedas':
    case 'Spicy':
      return context.t('spicy');
    default:
      return d ?? context.t('easy');
  }
}

class DetailScreen extends StatefulWidget {
  final Meal meal;
  const DetailScreen({super.key, required this.meal});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final shop = context.watch<ShopState>();
    final kh = context.useKhmer;
    final m = widget.meal;
    final fav = st.isFavorite(m.id);
    final set = shop.setForMeal(m.id);
    return DefaultTabController(
      length: shop.loaded ? 5 : 4,
      child: Scaffold(
      backgroundColor: C.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: C.bg,
            elevation: 0,
            leading: _RoundBack(
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _RoundBack(onTap: () {
                st.toggleFavorite(m);
              },
                  icon: fav ? Icons.favorite : Icons.favorite_border,
                  color: fav ? C.red : C.ink),
              const SizedBox(width: 10),
              const SizedBox(height: 56),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  MealImage(meal: m, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          m.nameIn(kh),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: C.ink,
                              height: 1.25),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => st.toggleFavorite(m),
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: C.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: C.line),
                          ),
                          child: Icon(
                            fav ? Icons.favorite : Icons.favorite_border,
                            color: fav ? C.red : C.muted,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (m.rating != null) ...[
                        const Icon(Icons.star, size: 16, color: C.amber),
                        const SizedBox(width: 4),
                        Text(m.rating!.toStringAsFixed(1),
                            style: const TextStyle(height: 1.4, 
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: C.ink)),
                        const SizedBox(width: 6),
                        Text(context.t('review_count', n: '${m.ratingsCount ?? 320}'),
                            style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaPill(
                          icon: Icons.category,
                          label: context.t(catKey(m.category))),
                      _MetaPill(
                          icon: Icons.timer_outlined,
                          label: context.t('minutes', n: '${m.minutes ?? 20}')),
                      _MetaPill(
                          icon: Icons.speed, label: _diff(context, m.difficulty)),
                      _MetaPill(
                          icon: Icons.groups_outlined,
                          label: context.t('servings', n: '${m.servings ?? 2}')),
                      if (set != null)
                        _MetaPill(
                            icon: Icons.price_change,
                            label: shop.money(set.price)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Nutrition strip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: C.line),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Nutri(value: '${m.kcal ?? 0}', label: context.t('kcal')),
                        const SizedBox(width: 8),
                        _Nutri(
                            value: '${m.carb ?? 0}g', label: context.t('carb')),
                        const SizedBox(width: 8),
                        _Nutri(value: '${m.protein ?? 0}g',
                            label: context.t('protein')),
                        const SizedBox(width: 8),
                        _Nutri(value: '${m.fat ?? 0}g', label: context.t('fat')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: C.line),
                    ),
                    child: TabBar(
                      labelColor: C.primary,
                      unselectedLabelColor: C.muted,
                      indicatorColor: C.primary,
                      labelStyle: const TextStyle(height: 1.4, 
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: const TextStyle(height: 1.4, 
                          fontSize: 13.5, fontWeight: FontWeight.w600),
                      tabs: [
                        Tab(text: context.t('tab_ing')),
                        Tab(text: context.t('tab_steps')),
                        Tab(text: context.t('tab_nutri')),
                        Tab(text: context.t('tab_reviews')),
                        if (shop.loaded) Tab(text: context.t('tab_buy')),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _IngredientsTab(meal: m),
                        _StepsTab(meal: m),
                        _NutritionTab(meal: m),
                        _ReviewsTab(meal: m),
                        if (shop.loaded) _BuyTab(meal: m),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
        floatingActionButton: _AddAllButton(meal: m),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class _RoundBack extends StatelessWidget {
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;
  const _RoundBack({required this.onTap, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
            ],
          ),
          child: Icon(icon ?? Icons.arrow_back_ios_new,
              size: 20, color: color ?? C.ink),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: C.primary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(height: 1.4, 
                  fontSize: 13, fontWeight: FontWeight.w600, color: C.ink)),
        ],
      ),
    );
  }
}

class _Nutri extends StatelessWidget {
  final String value;
  final String label;
  const _Nutri({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(height: 1.4, 
                fontSize: 15, fontWeight: FontWeight.w800, color: C.ink)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
      ],
    );
  }
}

class _IngredientsTab extends StatelessWidget {
  final Meal meal;
  const _IngredientsTab({required this.meal});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final kh = context.useKhmer;
    final ing = meal.ingredientsIn(kh);
    final bumbu = kh ? <Ingredient>[] : meal.bumbu;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      children: [
        _GroupHeader(context.t('ingredients')),
        ...ing.map((i) => _IngRow(
            ing: i,
            listKey: '${meal.id}|${i.name}|${i.measure}',
            checked: st.isListed('${meal.id}|${i.name}|${i.measure}'))),
        if (bumbu.isNotEmpty) ...[
          const SizedBox(height: 16),
          _GroupHeader(context.t('spices')),
          ...bumbu
              .map((i) => _IngRow(
                  ing: i,
                  listKey: '${meal.id}|${i.name}|${i.measure}',
                  checked: st.isListed('${meal.id}|${i.name}|${i.measure}'))),
        ],
      ],
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String text;
  const _GroupHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(height: 1.4, 
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: C.primaryDark)),
    );
  }
}

class _IngRow extends StatelessWidget {
  final Ingredient ing;
  final String listKey;
  final bool checked;
  const _IngRow(
      {required this.ing, required this.listKey, required this.checked});

  @override
  Widget build(BuildContext context) {
    final st = context.read<AppState>();
    return GestureDetector(
      onTap: () => st.toggleChecked(listKey),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: checked ? C.primary : C.line),
        ),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: checked ? C.primary : C.muted,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                ing.name,
                style: TextStyle(height: 1.4, 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: checked ? C.muted : C.ink,
                    decoration: checked ? TextDecoration.lineThrough : null),
              ),
            ),
            Text(ing.label,
                style: const TextStyle(height: 1.4, 
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: C.primaryDark)),
          ],
        ),
      ),
    );
  }
}

class _StepsTab extends StatelessWidget {
  final Meal meal;
  const _StepsTab({required this.meal});

  @override
  Widget build(BuildContext context) {
    final kh = context.useKhmer;
    final steps = meal.stepsIn(kh);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      itemCount: steps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.line),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: C.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${i + 1}',
                      style: const TextStyle(height: 1.4, 
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: C.primaryDark)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(steps[i],
                    style: const TextStyle(
                        fontSize: 14, color: C.ink, height: 1.5)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NutritionTab extends StatelessWidget {
  final Meal meal;
  const _NutritionTab({required this.meal});

  @override
  Widget build(BuildContext context) {
    final rows = [
      (context.t('nut_kcal'), '${meal.kcal ?? 0} kkal',
          Icons.local_fire_department, C.primary),
      (context.t('nut_carb'), '${meal.carb ?? 0} g',
          Icons.restaurant_menu, C.amber),
      (context.t('nut_prot'), '${meal.protein ?? 0} g',
          Icons.fitness_center, C.teal),
      (context.t('nut_fat'), '${meal.fat ?? 0} g', Icons.water_drop, C.blue),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      children: [
        for (final r in rows)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(r.$4.red, r.$4.green, r.$4.blue, 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(r.$3, color: r.$4, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.$1,
                          style: const TextStyle(height: 1.4, 
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: C.muted)),
                      Text(r.$2,
                          style: const TextStyle(height: 1.4, 
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: C.ink)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Text(context.t('nut_per'),
            style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final Meal meal;
  const _ReviewsTab({required this.meal});

  @override
  Widget build(BuildContext context) {
    final kh = context.useKhmer;
    final rating = meal.rating ?? 4.8;
    final reviews = [
      (kh ? 'សុភា ឃ.' : 'Sari W.', '4.9', context.t('rev_1'),
          context.t('days_ago')),
      (kh ? 'សុបាត ហ.' : 'Budi H.', '4.7', context.t('rev_2'),
          context.t('week_ago')),
      (kh ? 'ដេវី អ.' : 'Dewi A.', '4.8', context.t('rev_3'),
          context.t('weeks_ago')),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.line),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(rating.toStringAsFixed(1),
                      style: const TextStyle(height: 1.4, 
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: C.ink)),
                  const Row(
                    children: [
                      Icon(Icons.star, size: 14, color: C.amber),
                      Icon(Icons.star, size: 14, color: C.amber),
                      Icon(Icons.star, size: 14, color: C.amber),
                      Icon(Icons.star, size: 14, color: C.amber),
                      Icon(Icons.star_half, size: 14, color: C.amber),
                    ],
                  ),
                  Text(context.t('review_count', n: '320'),
                      style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 5; i >= 1; i--)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text('$i',
                                style:
                                    const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: [0.72, 0.21, 0.05, 0.01, 0.01][5 - i]
                                      .toDouble(),
                                  minHeight: 8,
                                  backgroundColor: C.line,
                                  color: C.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final rv in reviews)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: C.primarySoft,
                      child: Text(rv.$1[0],
                          style: const TextStyle(height: 1.4, 
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: C.primaryDark)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rv.$1,
                              style: const TextStyle(height: 1.4, 
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: C.ink)),
                          Text(rv.$4,
                              style: const TextStyle(height: 1.4, 
                                  fontSize: 12, color: C.muted)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 15, color: C.amber),
                        const SizedBox(width: 3),
                        Text(rv.$2,
                            style: const TextStyle(height: 1.4, 
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: C.ink)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(rv.$3,
                    style:
                        const TextStyle(fontSize: 13, color: C.ink, height: 1.5)),
              ],
            ),
          ),
      ],
    );
  }
}

class _AddAllButton extends StatelessWidget {
  final Meal meal;
  const _AddAllButton({required this.meal});

  @override
  Widget build(BuildContext context) {
    final st = context.read<AppState>();
    final addedMsg = context.t('added_snack');
    final addLabel = context.t('add_shop');
    return FloatingActionButton.extended(
      onPressed: () {
        st.addRecipe(meal);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(addedMsg)),
        );
      },
      backgroundColor: C.primary,
      foregroundColor: Colors.white,
      label: Text(addLabel,
          style: const TextStyle(height: 1.4, fontWeight: FontWeight.w700)),
      icon: const Icon(Icons.shopping_bag, size: 18),
    );
  }
}

/// "Buy set" tab: order the full ingredient set for this recipe.
class _BuyTab extends StatelessWidget {
  final Meal meal;
  const _BuyTab({required this.meal});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopState>();
    final kh = context.useKhmer;
    final set = shop.setForMeal(meal.id);
    if (set == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(context.t('not_sellable'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  height: 1.4, fontSize: 14, color: C.muted)),
        ),
      );
    }
    final qty = shop.cartQty(set.id);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: C.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MealImage(meal: meal, width: 72, height: 72),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(set.name(kh),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(height: 1.4,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: C.ink)),
                        const SizedBox(height: 4),
                        Text(shop.money(set.price),
                            style: const TextStyle(height: 1.4,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: C.primary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (set.desc(kh).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(set.desc(kh),
                      style: const TextStyle(
                          height: 1.4, fontSize: 13, color: C.muted)),
                ),
              Text(context.t('stock'),
                  style: const TextStyle(height: 1.4,
                      fontSize: 12, color: C.muted)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _QtyBtn(icon: Icons.remove, onPressed: () {
                    if (qty > 0) shop.setQty(set, qty - 1);
                  }),
                  const SizedBox(width: 10),
                  Text('$qty',
                      style: const TextStyle(height: 1.4,
                          fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(width: 10),
                  _QtyBtn(icon: Icons.add, enabled: qty < set.stock,
                      onPressed: () {
                    if (qty < set.stock) shop.setQty(set, qty + 1);
                  }),
                  const Spacer(),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: C.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () {
                        if (qty == 0) shop.addToCart(set);
                        Navigator.popUntil(
                            context, (r) => r.settings.name == '/');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CartScreen()),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart, size: 18),
                      label: Text(
                          qty == 0 ? context.t('buy_set') : context.t('go_cart'),
                          style: const TextStyle(height: 1.4,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // what's inside the set
        if (set.ingredients.isNotEmpty) ...[
          _GroupHeader(context.t('in_set')),
          ...set.ingredients.map(
                (e) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: C.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: C.line),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(e['name'].toString(),
                            style: const TextStyle(
                                height: 1.4, fontSize: 13.5, color: C.ink)),
                      ),
                      Text(e['measure'].toString(),
                          style: const TextStyle(height: 1.4,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: C.primaryDark)),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;
  const _QtyBtn(
      {required this.icon, required this.onPressed, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: C.primarySoft,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, size: 18,
            color: enabled ? C.primaryDark : C.muted.withOpacity(0.5)),
        onPressed: enabled ? onPressed : null,
      ),
    );
  }
}
