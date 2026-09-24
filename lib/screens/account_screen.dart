import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../i18n/localizations.dart';
import '../state/app_state.dart';
import '../theme.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final i18n = context.watch<I18N>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        titleSpacing: 20,
        title: Text(context.t('account'),
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ---- Profile card ----
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9A3D), Color(0xFFFF7A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: C.primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: C.primary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Andi Pratama',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        SizedBox(height: 3),
                        Text('andi.pratama@mail.com',
                            style: TextStyle(
                                fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
            // ---- Stats ----
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(value: '${st.favoriteCount}',
                    label: context.t('stat_recipes')),
                const SizedBox(width: 10),
                _StatCard(value: '${st.listCount}',
                    label: context.t('stat_shop')),
                const SizedBox(width: 10),
                _StatCard(value: '23/12', label: context.t('stat_goal')),
              ],
            ),
            const SizedBox(height: 16),
            // ---- Weekly progress ----
            Container(
              padding: const EdgeInsets.all(16),
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
                      Text(context.t('weekly'),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: C.ink)),
                      const Spacer(),
                      const Text('62%',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: C.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: st.progress,
                      minHeight: 10,
                      backgroundColor: C.line,
                      color: C.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(context.t('weekly_sub'),
                      style: const TextStyle(fontSize: 11.5, color: C.muted)),
                ],
              ),
            ),
            // ---- Language ----
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: C.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: C.line),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: Row(
                      children: [
                        const Icon(Icons.translate, size: 20,
                            color: C.primary),
                        const SizedBox(width: 14),
                        Text(context.t('lang_title'),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: C.ink)),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: C.line),
                  for (final l in I18N.locales)
                    InkWell(
                      onTap: () => i18n.setLocale(l),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Text(i18n.label(l),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: i18n.locale == l
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: i18n.locale == l
                                        ? C.primary
                                        : C.ink)),
                            const Spacer(),
                            Icon(
                              i18n.locale == l
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 20,
                              color: i18n.locale == l ? C.primary : C.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ---- Menu list ----
            _MenuGroup(
              items: [
                (Icons.notifications_outlined, context.t('m_notif'), '#FFFFFF80'),
                (Icons.receipt_long_outlined, context.t('m_history'), '#FFFFFF'),
                (Icons.download_outlined, context.t('m_downloads'), '#FFFFFF'),
              ],
            ),
            const SizedBox(height: 12),
            _MenuGroup(
              items: [
                (Icons.help_outline, context.t('m_help'), '#FFFFFF80'),
                (Icons.privacy_tip_outlined, context.t('m_privacy'), '#FFFFFF'),
                (Icons.star_outline, context.t('m_rate'), '#FFFFFF80'),
              ],
            ),
            const SizedBox(height: 12),
            _MenuGroup(
              items: [
                (Icons.logout, context.t('m_logout'), '#FFFFFF'),
              ],
              danger: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.line),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800, color: C.ink)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11.5, color: C.muted)),
          ],
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<(IconData, String, String)> items;
  final bool danger;
  const _MenuGroup({required this.items, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('“${items[i].$2}” — ${context.t('coming_soon')}'))),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(items[i].$1,
                        size: 20, color: danger ? C.red : C.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(items[i].$2,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: C.ink)),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: C.muted),
                  ],
                ),
              ),
            ),
            if (i < items.length - 1)
              const Divider(height: 1, indent: 52, color: C.line),
          ],
        ],
      ),
    );
  }
}
