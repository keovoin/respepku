import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../i18n/localizations.dart';
import '../models/meal.dart';
import '../state/app_state.dart';
import '../theme.dart';

class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final kh = context.useKhmer;
    final items = st.shoppingItems;
    final done = items.where((i) => i.checked).length;
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        titleSpacing: 20,
        title: Text(context.t('shopping'),
            style: const TextStyle(height: 1.4, 
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () {
                st.checkAll();
              },
              child: Text(context.t('done_all'),
                  style:
                      const TextStyle(height: 1.4, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🛒', style: TextStyle(height: 1.4, fontSize: 44)),
                      const SizedBox(height: 14),
                      Text(context.t('shop_empty_t'),
                          style: const TextStyle(height: 1.4, 
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: C.ink)),
                      const SizedBox(height: 6),
                      Text(context.t('shop_empty_s'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: C.muted, fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                              context.t('shop_sub'),
                              style: const TextStyle(height: 1.4, 
                                  fontSize: 12, color: C.muted)),
                        ),
                        Text('$done/${items.length}',
                            style: const TextStyle(height: 1.4, 
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: C.primaryDark)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final it = items[i];
                        // Re-derive display names in the current locale
                        // (items were stored in English at add-time).
                        String itemName = it.name;
                        String mealName = it.mealName;
                        final parts = it.key.split('|');
                        if (parts.isNotEmpty) {
                          final m = MealApi.lookup(parts[0]);
                          if (m != null) {
                            mealName = m.nameIn(kh);
                            if (it.name.isNotEmpty) {
                              final ing = m.ingredients.firstWhere(
                                  (e) => e.name == it.name,
                                  orElse: () =>
                                      const Ingredient('', ''));
                              if (ing.name.isNotEmpty) {
                                itemName = m.ingNameIn(kh, ing);
                              }
                            }
                          }
                        }
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
                                      itemName,
                                      style: TextStyle(height: 1.4, 
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
                                    Text(mealName,
                                        style: const TextStyle(height: 1.4, 
                                            fontSize: 12, color: C.muted)),
                                  ],
                                ),
                              ),
                              if (it.measure.isNotEmpty)
                                Text(it.measure,
                                    style: const TextStyle(height: 1.4, 
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
