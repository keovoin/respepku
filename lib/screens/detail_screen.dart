import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../state/app_state.dart';
import '../theme.dart';

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
    final m = widget.meal;
    final fav = st.isFavorite(m.id);
    return DefaultTabController(
      length: 4,
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
                  Image.network(
                    m.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: C.primarySoft,
                      child: const Icon(Icons.restaurant,
                          size: 60, color: C.primary),
                    ),
                  ),
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
                          m.name,
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
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: C.ink)),
                        const SizedBox(width: 6),
                        const Text('(320 ulasan)',
                            style: TextStyle(fontSize: 12, color: C.muted)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MetaPill(
                          icon: Icons.timer_outlined,
                          label: '${m.minutes ?? 20} Menit'),
                      _MetaPill(
                          icon: Icons.speed, label: m.difficulty ?? 'Mudah'),
                      _MetaPill(
                          icon: Icons.groups_outlined, label: '2 Porsi'),
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
                        _Nutri(value: '${m.kcal ?? 0}', label: 'kkal'),
                        const SizedBox(width: 8),
                        _Nutri(
                            value: '${m.carb ?? 0}g', label: 'karbohidrat'),
                        const SizedBox(width: 8),
                        _Nutri(value: '${m.protein ?? 0}g', label: 'protein'),
                        const SizedBox(width: 8),
                        _Nutri(value: '${m.fat ?? 0}g', label: 'lemak'),
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
                      labelStyle: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(text: 'Bahan'),
                        Tab(text: 'Langkah Memasak'),
                        Tab(text: 'Nutrisi'),
                        Tab(text: 'Penilaian'),
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
      margin: const EdgeInsets.only(right: 8),
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
              style: const TextStyle(
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
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: C.ink)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: C.muted)),
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
    final ing = meal.ingredients;
    final bumbu = meal.bumbu;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      children: [
        if (bumbu.isEmpty)
          const _GroupHeader('Bahan')
        else ...[
          const _GroupHeader('Bahan'),
          ...ing.map((i) => _IngRow(
              ing: i,
              listKey: '${meal.id}|${i.name}|${i.measure}',
              checked: st.isListed('${meal.id}|${i.name}|${i.measure}'))),
          const SizedBox(height: 16),
          const _GroupHeader('Bumbu'),
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
          style: const TextStyle(
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
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: checked ? C.muted : C.ink,
                    decoration: checked ? TextDecoration.lineThrough : null),
              ),
            ),
            Text(ing.label,
                style: const TextStyle(
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      itemCount: meal.steps.length,
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
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: C.primaryDark)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(meal.steps[i],
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
      ('Kalori', '${meal.kcal ?? 0} kkal', Icons.local_fire_department, C.primary),
      ('Karbohidrat', '${meal.carb ?? 0} g', Icons.restaurant_menu, C.amber),
      ('Protein', '${meal.protein ?? 0} g', Icons.fitness_center, C.teal),
      ('Lemak', '${meal.fat ?? 0} g', Icons.water_drop, C.blue),
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
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: C.muted)),
                      Text(r.$2,
                          style: const TextStyle(
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
        Text('* Nilai per porsi, perkiraan.',
            style: const TextStyle(fontSize: 11, color: C.muted)),
      ],
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final Meal meal;
  const _ReviewsTab({required this.meal});

  static const _reviews = [
    ('Sari W.', '4.9', 'Enak banget! Bumbunya pas, anak-anak langsung nambah. Resepnya gampang diikuti, cocok buat pemula.', '2 hari lalu'),
    ('Budi H.', '4.7', 'Hasilnya mirip restoran. Tips api kecil saat menumis benar-benar ngaruh. Sudah masuk resep langganan.', '1 minggu lalu'),
    ('Dewi A.', '4.8', 'Wangi bawang putihnya nagih. Saya tambahin sedikit cabai merah, makin pedas manis. Recommended!', '2 minggu lalu'),
  ];

  @override
  Widget build(BuildContext context) {
    final rating = meal.rating ?? 4.8;
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
                      style: const TextStyle(
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
                  const Text('320 ulasan',
                      style: TextStyle(fontSize: 11, color: C.muted)),
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
                                style: const TextStyle(
                                    fontSize: 11, color: C.muted)),
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
        for (final rv in _reviews)
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
                          style: const TextStyle(
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
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: C.ink)),
                          Text(rv.$4,
                              style: const TextStyle(
                                  fontSize: 11, color: C.muted)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 15, color: C.amber),
                        const SizedBox(width: 3),
                        Text(rv.$2,
                            style: const TextStyle(
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
    return FloatingActionButton.extended(
      onPressed: () {
        st.addRecipe(meal);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bahan ditambahkan ke Daftar Belanja 🛒')),
        );
      },
      backgroundColor: C.primary,
      foregroundColor: Colors.white,
      label: const Text('+ Belanja',
          style: TextStyle(fontWeight: FontWeight.w700)),
      icon: const Icon(Icons.shopping_bag, size: 18),
    );
  }
}
