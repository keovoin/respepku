import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../i18n/localizations.dart';
import '../models/meal.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // Filter by i18n key, not by displayed text.
  String _filterKey = 'all';
  static const _filterKeys = ['all', 'easy', 'medium', 'spicy'];

  bool _matches(Meal m) {
    switch (_filterKey) {
      case 'easy':
        return m.difficulty == 'Mudah' ||
            m.difficulty?.toLowerCase() == 'easy';
      case 'medium':
        return m.difficulty == 'Sedang' ||
            m.difficulty?.toLowerCase() == 'medium';
      case 'spicy':
        return m.tags?.toLowerCase().contains('spicy') == true ||
            m.tags?.toLowerCase().contains('pedas') == true ||
            m.name.toLowerCase().contains('pedas');
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final favs = st.favoriteMeals;
    final shown = favs.where(_matches).toList();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        titleSpacing: 20,
        title: Text(context.t('favorites'),
            style: const TextStyle(height: 1.4, 
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(context.t('fav_sub'),
                  style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: List.generate(_filterKeys.length, (i) {
                  final k = _filterKeys[i];
                  final active = _filterKey == k;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterKey = k),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? C.primary : C.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active ? C.primary : C.line),
                        ),
                        child: Text(context.t(k),
                            style: TextStyle(height: 1.4, 
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: active ? Colors.white : C.ink)),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: shown.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: shown.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
                      itemBuilder: (_, i) => MealCardRow(
                        meal: shown[i],
                        showAdd: false,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailScreen(meal: shown[i]))),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤍', style: TextStyle(height: 1.4, fontSize: 44)),
            const SizedBox(height: 14),
            Text(context.t('fav_empty_t'),
                style: const TextStyle(height: 1.4, 
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: C.ink)),
            const SizedBox(height: 6),
            Text(context.t('fav_empty_s'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: C.muted, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
