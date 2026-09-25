import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../i18n/localizations.dart';
import '../state/account_state.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'auth_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final acc = context.watch<AccountState>();
    final i18n = context.watch<I18N>();
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        elevation: 0,
        titleSpacing: 20,
        title: Text(context.t('account'),
            style: const TextStyle(
                height: 1.4,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: C.ink)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            acc.name.isNotEmpty
                                ? acc.name
                                : (st.customerName.isNotEmpty
                                    ? st.customerName
                                    : 'Sastra Fitmeal'),
                            style: const TextStyle(
                                height: 1.4,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 3),
                        Text(
                            acc.loggedIn
                                ? (acc.userEmail?.contains('@fitmeal.tg') ?? true
                                    ? acc.phone.isNotEmpty
                                        ? acc.phone
                                        : (acc.tgName ?? '')
                                    : acc.userEmail ?? '')
                                : acc.inTelegram
                                    ? context.t('account_login')
                                    : context.t('login_benefit'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                height: 1.4,
                                fontSize: 12,
                                color: Colors.white70)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: acc.loggedIn
                        ? null
                        : () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AuthScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                          acc.loggedIn
                              ? '✓'
                              : context.t('account_login'),
                          style: const TextStyle(
                              height: 1.4,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            // ---- Stats ----
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(
                    value: '${st.favoriteCount}',
                    label: context.t('stat_recipes')),
                const SizedBox(width: 10),
                _StatCard(
                    value: '${st.orderCount}', label: context.t('stat_orders')),
                const SizedBox(width: 10),
                _StatCard(
                    value: '${st.cookedCount}/6',
                    label: context.t('stat_goal')),
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
                              height: 1.4,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: C.ink)),
                      const Spacer(),
                      Text('${(st.progress * 100).round()}%',
                          style: const TextStyle(
                              height: 1.4,
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
                  Text(context.t('weekly_sub_n', n: '${st.cookedCount}'),
                      style: const TextStyle(
                          height: 1.4, fontSize: 12, color: C.muted)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ---- Language ----
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
                        const Icon(Icons.translate,
                            size: 20, color: C.primary),
                        const SizedBox(width: 14),
                        Text(context.t('lang_title'),
                            style: const TextStyle(
                                height: 1.4,
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Text(i18n.label(l),
                                style: TextStyle(
                                    height: 1.4,
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
                              color:
                                  i18n.locale == l ? C.primary : C.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ---- Menu list (all real actions) ----
            _MenuGroup(items: [
              (Icons.notifications_outlined, context.t('m_notif'),
                  () => _showOrdersSheet(context)),
              (Icons.receipt_long_outlined, context.t('m_history'),
                  () => _showOrdersSheet(context)),
              (Icons.sports_kabaddi, context.t('m_help'),
                  () => _showHelp(context)),
              (Icons.privacy_tip_outlined, context.t('m_privacy'),
                  () => _showPrivacy(context)),
              (Icons.star_outline, context.t('m_rate'),
                  () => _showRate(context)),
            ]),
            const SizedBox(height: 12),
            _MenuGroup(
              items: [
                (Icons.logout, context.t('m_logout'),
                    () => _confirmSignOut(context)),
              ],
              danger: true,
            ),
            const SizedBox(height: 18),
            Center(
              child: Text('Sastra Fitmeal v1.0.0',
                  style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- real dialogs / sheets ----------

  static void _showOrdersSheet(BuildContext context) {
    final st = context.read<AppState>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.bg,
      isScrollControlled: true,
      builder: (bc) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(bc).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(bc.t('m_history'),
                          style: const TextStyle(
                              height: 1.4,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: C.ink)),
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(bc),
                        icon: const Icon(Icons.close, color: C.muted)),
                  ],
                ),
              ),
              if (st.orderHistory.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 44, color: C.muted),
                      const SizedBox(height: 10),
                      Text(bc.t('no_orders_yet'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              height: 1.4, fontSize: 13, color: C.muted)),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
                    itemCount: st.orderHistory.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final o = st.orderHistory[i];
                      final date = DateTime.tryParse(o['date'] ?? '') ??
                          DateTime.now();
                      final code = (o['method'] ?? 'cod').toUpperCase();
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: C.line),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                code == 'CUTLUY'
                                    ? Icons.qr_code_2
                                    : Icons.payments_outlined,
                                color: C.primary,
                                size: 26),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text('#${o['ref'] ?? ''}',
                                      style: const TextStyle(
                                          height: 1.4,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: C.ink)),
                                  Text(
                                      '${date.day.toString().padLeft(2, '0')}/'
                                      '${date.month.toString().padLeft(2, '0')}/'
                                      '${date.year}  ·  $code',
                                      style: const TextStyle(
                                          height: 1.4,
                                          fontSize: 12,
                                          color: C.muted)),
                                ],
                              ),
                            ),
                            Text(o['total'] ?? '',
                                style: const TextStyle(
                                    height: 1.4,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
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
      ),
    );
  }

  static void _showHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.bg,
      builder: (bc) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bc.t('m_help'),
                  style: const TextStyle(
                      height: 1.4,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: C.ink)),
              const SizedBox(height: 10),
              Text(bc.t('help_body'),
                  style: const TextStyle(
                      height: 1.5, fontSize: 13, color: C.ink)),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.phone_in_talk, size: 18, color: C.primary),
                  const SizedBox(width: 8),
                  Text('+855 12 000 000',
                      style: const TextStyle(
                          height: 1.4,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: C.ink)),
                  const SizedBox(width: 18),
                  const Icon(Icons.mail_outline, size: 18, color: C.primary),
                  const SizedBox(width: 8),
                  Text('support@sastrafitmeal.com',
                      style: const TextStyle(
                          height: 1.4,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: C.ink)),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static void _showPrivacy(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.bg,
      isScrollControlled: true,
      builder: (bc) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(22),
          children: [
            Text(bc.t('m_privacy'),
                style: const TextStyle(
                    height: 1.4,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: C.ink)),
            const SizedBox(height: 10),
            Text(bc.t('privacy_body'),
                style: const TextStyle(height: 1.5, fontSize: 13, color: C.ink)),
          ],
        ),
      ),
    );
  }

  static void _showRate(BuildContext context) {
    final st = context.read<AppState>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: C.bg,
      builder: (bc) => SafeArea(
        child: StatefulBuilder(
          builder: (_, setSheet) => Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(bc.t('rate_title'),
                    style: const TextStyle(
                        height: 1.4,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: C.ink)),
                const SizedBox(height: 4),
                Text(bc.t('rate_sub'),
                    style: const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var s = 1; s <= 5; s++)
                      IconButton(
                        onPressed: () {
                          st.setRating(s);
                          setSheet(() {});
                        },
                        icon: Icon(
                          s <= st.appRating ? Icons.star : Icons.star_border,
                          size: 34,
                          color: C.amber,
                        ),
                      ),
                  ],
                ),
                if (st.appRating > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(bc.t('rate_thanks'),
                        style: const TextStyle(
                            height: 1.4,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: C.green)),
                  ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (bc) => AlertDialog(
        backgroundColor: C.card,
        title: Text(context.t('m_logout'),
            style: const TextStyle(
                height: 1.4, fontSize: 16, fontWeight: FontWeight.w800)),
        content: Text(context.t('logout_confirm'),
            style: const TextStyle(height: 1.5, fontSize: 13, color: C.muted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(bc),
              child: Text(context.t('cancel'))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: C.red),
            onPressed: () {
              context.read<AppState>().clearProfile();
              context.read<AccountState>().logout();
              Navigator.pop(bc);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t('logout_done'))));
            },
            child: Text(context.t('m_logout')),
          ),
        ],
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
                    height: 1.4,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: C.ink)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(height: 1.4, fontSize: 12, color: C.muted)),
          ],
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<(IconData, String, VoidCallback)> items;
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
              onTap: items[i].$3,
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
                              height: 1.4,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: C.ink)),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 18, color: C.muted),
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
