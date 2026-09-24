import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final items = st.shoppingItems;
    final done = items.where((i) => i.checked).length;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        titleSpacing: 20,
        title: const Text('Daftar Belanja',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                st.checkAll();
              },
              child: const Text('Selesaikan Semua',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🛒', style: TextStyle(fontSize: 44)),
                      SizedBox(height: 14),
                      Text('Daftar belanja kosong',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: C.ink)),
                      SizedBox(height: 6),
                      Text('Tambahkan bahan dari halaman resep\ndengan tombol “+ Belanja”.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: C.muted, fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                              'Yuk, belanja bahan buat hari ini',
                              style: TextStyle(
                                  fontSize: 12, color: C.muted)),
                        ),
                        Text('$done/${items.length}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: C.primaryDark)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: items.isEmpty ? 0 : done / items.length,
                        minHeight: 8,
                        backgroundColor: C.line,
                        color: C.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final it = items[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 13),
                          decoration: BoxDecoration(
                            color: C.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: it.checked ? C.primary : C.line),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => st.toggleChecked(it.key),
                                child: Icon(
                                  it.checked
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: it.checked
                                      ? C.primary
                                      : C.muted,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.name,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: it.checked
                                              ? C.muted
                                              : C.ink,
                                          decoration: it.checked
                                              ? TextDecoration
                                                  .lineThrough
                                              : null),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(it.mealName,
                                        style: const TextStyle(
                                            fontSize: 11, color: C.muted)),
                                  ],
                                ),
                              ),
                              if (it.measure.isNotEmpty)
                                Text(it.measure,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: C.primaryDark)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
