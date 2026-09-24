import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../i18n/localizations.dart';
import '../models/meal.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final AppCategory? initialCategory;
  const SearchScreen({super.key, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _ctrl;
  String _activeQuery = '';
  AppCategory? _activeCat;
  List<Meal> _results = [];
  bool _loading = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialCategory?.query ?? '');
    if (widget.initialCategory != null) {
      _activeCat = widget.initialCategory;
      _activeQuery = widget.initialCategory!.query ?? '';
      _search();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _ctrl.text.trim().isEmpty ? _activeQuery : _ctrl.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _searched = true;
      _activeQuery = q;
    });
    final r = await MealApi.search(q);
    if (!mounted) return;
    setState(() {
      _results = r;
      _loading = false;
    });
  }

  void _open(Meal m) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => DetailScreen(meal: m)));

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        titleSpacing: 20,
        title: Text(_searched ? context.t('search_results') : context.t('search'),
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: C.ink),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: C.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: C.muted, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              onSubmitted: (_) => _search(),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText: context.t('search_ph'),
                                hintStyle:
                                    const TextStyle(color: C.muted, fontSize: 14),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.mic_none,
                                color: C.muted, size: 20),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _search,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: C.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child:
                          const Icon(Icons.search, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            // ---- Category grid (only when pushed from home) ----
            if (widget.initialCategory != null && !_searched) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Text(context.t('category'),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: C.ink)),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.35),
                  itemCount: _cats(context).length,
                  itemBuilder: (_, i) {
                    final c = _cats(context)[i];
                    return GestureDetector(
                      onTap: () {
                        _ctrl.text = c.query ?? '';
                        _activeCat = c;
                        _search();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: _activeCat == c ? C.primary : C.line),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Color(int.parse(c.soft.substring(1), radix: 16)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                  child: Text(c.emoji,
                                      style: const TextStyle(fontSize: 22))),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(c.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: C.ink)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              // ---- Search results ----
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: C.primary))
                    : !_searched
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text(
                                  context.t('empty_search'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: C.muted,
                                      fontSize: 14,
                                      height: 1.5)),
                            ),
                          )
                        : _results.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🍽️',
                                        style: TextStyle(fontSize: 40)),
                                    const SizedBox(height: 12),
                                    Text(
                                        '${context.t('no_results')} “$_activeQuery”',
                                        style:
                                            const TextStyle(color: C.muted)),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 24),
                                itemCount: _results.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 4),
                                itemBuilder: (_, i) {
                                  final m = _results[i];
                                  final inList = st.isRecipeListed(m.id);
                                  return _ResultRow(
                                    meal: m,
                                    inList: inList,
                                    onTap: () => _open(m),
                                  );
                                },
                              ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final Meal meal;
  final bool inList;
  final VoidCallback onTap;
  const _ResultRow(
      {required this.meal, required this.inList, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final st = context.read<AppState>();
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
              child: Image.network(meal.image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: C.primarySoft,
                      child: const Icon(Icons.restaurant, color: C.primary))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: C.ink)),
                  const SizedBox(height: 4),
                  Text(meal.category,
                      style: const TextStyle(fontSize: 12, color: C.muted)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => st.addRecipe(meal),
              child: Icon(
                inList ? Icons.check_circle : Icons.add_circle_outline,
                color: inList ? C.primary : C.muted,
                size: 24,
              ),
            ),
          ],
        ),
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
