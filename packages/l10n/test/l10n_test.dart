import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modoo_l10n/modoo_l10n.dart';

void main() {
  test('Chinese template has a translation for every key', () {
    expect(ModooLocalizations.delegate.isSupported(const Locale('zh')), isTrue);
    expect(ModooLocalizations.supportedLocales, contains(const Locale('zh')));
    expect(ModooLocalizations.supportedLocales, contains(const Locale('en')));
  });

  testWidgets('context.l10n resolves the active locale', (WidgetTester tester) async {
    late ModooLocalizations zh;
    late ModooLocalizations en;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: ModooLocalizations.localizationsDelegates,
        supportedLocales: ModooLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: Builder(
          builder: (BuildContext context) {
            zh = context.l10n;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: ModooLocalizations.localizationsDelegates,
        supportedLocales: ModooLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Builder(
          builder: (BuildContext context) {
            en = context.l10n;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(zh.bookshelfTitle, '书架');
    expect(en.bookshelfTitle, 'Shelf');
    expect(zh.appName, isNot(en.appName));
  });
}
