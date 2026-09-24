import 'dart:async';

import 'package:flutter/material.dart';

import '../i18n/localizations.dart';
import '../models/featured.dart';
import '../models/meal.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Meal> _popular = [];
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        MealApi.search('rice'),
        MealApi.search('chicken'),
        MealApi.search('noodle'),
      ]);
      final seen = <String>{};
      final popular = <Meal>[];
      for (final list in results) {
        for (final m in list) {
          if (seen.add(m.id) && m.image.isNotEmpty) popular.add(m);
        }
      }
      if (!mounted) return;
      setState(() {
        _popular = popular.take(12).toList();
        _loaded = true;
        _failed = popular.isEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loaded = true;
        _failed = true;
      });
    }
  }

  void _openDetail(Meal m) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(meal: m)));
  }

  @override
  Widget build(BuildContext context) {
    final featured = getFeaturedMeal();
    return Scaffold(
      backgroundColor: C.bg,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // ---- Header ----
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: C.primarySoft,
                  child: Icon(Icons.person, color: C.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.t('greeting'),
                          style: const TextStyle(fontSize: 12, color: C.muted)),
                      Text('${context.t('hi')}, Andi',
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: C.ink)),
                    ],
                  ),
                ),
                _CircleButton(
                    icon: Icons.notifications_outlined,
                    onTap: () =>
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(context.t('no_notifications'))))),
                _CircleButton(icon: Icons.shopping_bag_outlined,
                    onTap: () =>
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const SearchScreen()))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // ---- Search bar (decorative -> opens search tab) ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SearchScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: C.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: C.muted, size: 20),
                    const SizedBox(width: 10),
                    Text(context.t('search_hint'),
                        style: const TextStyle(color: C.muted, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          // ---- Featured banner ----
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: GestureDetector(
              onTap: () => _openDetail(featured),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9A3D), Color(0xFFFF7A00)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                        color: C.primary.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(context.t('featured_badge'),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                          const SizedBox(height: 10),
                          Text(featured.name,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.2)),
                          const SizedBox(height: 8),
                          const Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text('4.8 (320)',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(context.t('cook_now'),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: C.primaryDark)),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward,
                                    size: 14, color: C.primaryDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        featured.image,
                        width: 96,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 96,
                            height: 120,
                            color: Colors.white24,
                            child: const Icon(Icons.ramen_dining,
                                size: 40, color: Colors.white70)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ---- Categories ----
          SectionHeader(title: context.t('category')),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: List.generate(
                _cats(context).length,
                (i) {
                  final cat = _cats(context)[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CategoryChip(cat: cat, onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (_) => SearchScreen(
                                initialCategory: cat,
                              )));
                    }),
                  );
                },
              ),
            ),
          ),
          // ---- Popular today ----
          SectionHeader(title: context.t('popular_today')),
          if (!_loaded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const CircularProgressIndicator(strokeWidth: 2.5, color: C.primary),
                  const SizedBox(width: 10),
                  Text(context.t('loading'),
                      style: const TextStyle(color: C.muted)),
                ],
              ),
            )
          else if (_failed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(context.t('load_failed'),
                  style: const TextStyle(color: C.muted)),
            )
          else
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _popular.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => MealCardH(
                  meal: _popular[i],
                  onTap: () => _openDetail(_popular[i]),
                ),
              ),
            ),
          // ---- Continue cooking ----
          SectionHeader(title: context.t('continue_cooking')),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ContinueCard(meal: featured, onTap: () => _openDetail(featured)),
          ),
        ],
      ),
    );
  }
}

List<AppCategory> _cats(BuildContext context) => [
  AppCategory(context.t('cat_rice'), '🍚', Color(0xFFE8842C), '#FDF0E3', query: 'rice'),
  AppCategory(context.t('cat_noodle'), '🍜', Color(0xFFD96C2C), '#FBEDE4', query: 'noodle'),
  AppCategory(context.t('cat_chicken'), '🍗', Color(0xFFC25A2A), '#F9E8E0', query: 'chicken'),
  AppCategory(context.t('cat_seafood'), '🦐', Color(0xFF2E9CA6), '#E4F4F6', query: 'seafood'),
  AppCategory(context.t('cat_fish'), '🐟', Color(0xFF3E7CB1), '#E8F1FA', query: 'fish'),
  AppCategory(context.t('cat_dessert'), '🍰', Color(0xFFB06AB3), '#F4EAF7', query: 'dessert'),
  AppCategory(context.t('cat_veg'), '🥗', Color(0xFF2F9E63), '#E7F5EC', query: 'vegetable'),
  AppCategory(context.t('cat_drink'), '🥤', Color(0xFF8C8279), '#F0EBE5', query: 'drink'),
];

class _CategoryChip extends StatelessWidget {
  final AppCategory cat;
  final VoidCallback onTap;
  const _CategoryChip({required this.cat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 66,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(cat.soft.length >= 7 ? int.parse(cat.soft.substring(1), radix: 16) : 0xFFFFF1E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                  child: Text(cat.emoji, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(height: 6),
            FittedBox(
              child: Text(cat.name,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: C.ink)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  const _ContinueCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(meal.image,
                  width: 56, height: 56, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: C.primarySoft)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t('featured_name'),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: C.ink)),
                  const SizedBox(height: 4),
                  Text(context.t('step_of', a: '3', b: '7'),
                      style: const TextStyle(fontSize: 12, color: C.muted)),
                  const SizedBox(height: 6),
                  const LinearProgressIndicator(
                      value: 0.45,
                      minHeight: 6,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      backgroundColor: C.line,
                      color: C.primary),
                ],
              ),
            ),
            const Icon(Icons.play_circle_fill, color: C.primary, size: 28),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: C.line),
        ),
        child: Icon(icon, size: 20, color: C.ink),
      ),
    );
  }
}
