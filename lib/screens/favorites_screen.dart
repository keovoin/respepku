import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _filter = 'Semua';
  final List<String> _filters = ['Semua', 'Mudah', 'Sedang', 'Pedas'];

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final favs = st.favoriteMeals;
    final shown = _filter == 'Semua'
        ? favs
        : favs
            .where((m) => (m.difficulty ?? '') == _filter ||
                (_filter == 'Pedas' && m.name.toLowerCase().contains('pedas')))
            .toList();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        titleSpacing: 20,
        title: const Text('Favorit',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text('Resep yang kamu simpan',
                  style: TextStyle(fontSize: 12, color: C.muted)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: List.generate(_filters.length, (i) {
                  final f = _filters[i];
                  final active = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? C.primary : C.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: active ? C.primary : C.line),
                        ),
                        child: Text(f,
                            style: TextStyle(
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🤍', style: TextStyle(fontSize: 44)),
            SizedBox(height: 14),
            Text('Belum ada resep favorit',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: C.ink)),
            SizedBox(height: 6),
            Text('Tekan ikon hati pada resep\nuntuk menyimpannya di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: C.muted, fontSize: 13, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
