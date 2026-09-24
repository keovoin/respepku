import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:respepku/i18n/localizations.dart';
import 'package:respepku/main.dart';

void main() {
  testWidgets('boots with Khmer UI and 5-tab nav', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ResepKuApp());
    await tester.pump(const Duration(seconds: 2));

    // Khmer greeting + today's featured title
    expect(find.text('ជំរាបសួរ 👋'), findsOneWidget);
    expect(find.text('🔥 រូបមន្តពិសេសថ្ងៃនេះ'), findsOneWidget);
    // 5-tab bottom navigation in Khmer
    expect(find.text('ទំព័រដើម'), findsOneWidget);
    expect(find.text('ស្វែងរក'), findsOneWidget);
    expect(find.text('ចូលចិត្ត'), findsOneWidget);
    expect(find.text('គណនី'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching to English re-localizes the UI', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ResepKuApp());
    await tester.pump(const Duration(seconds: 2));

    // Switch locale the same way the Account tab does.
    final ctx = tester.element(find.text('ជំរាបសួរ 👋'));
    ctx.read<I18N>().setLocale(I18N.en);
    await tester.pump();

    expect(find.text('Welcome 👋'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    // Khmer strings are gone
    expect(find.text('ជំរាបសួរ 👋'), findsNothing);
  });
}
