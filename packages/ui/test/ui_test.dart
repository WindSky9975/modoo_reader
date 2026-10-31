import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modoo_ui/modoo_ui.dart';

void main() {
  test('every theme variant yields a distinct scaffold background', () {
    final backgrounds = <Color>{
      for (final variant in AppThemeVariant.values) buildAppTheme(variant).scaffoldBackgroundColor,
    };
    expect(backgrounds, hasLength(AppThemeVariant.values.length));
  });

  test('night themes are dark', () {
    expect(AppPalette.of(AppThemeVariant.night).brightness, Brightness.dark);
    expect(AppPalette.of(AppThemeVariant.amoled).brightness, Brightness.dark);
    expect(AppPalette.of(AppThemeVariant.paper).brightness, Brightness.light);
  });

  testWidgets('ModooEmptyState renders text and action', (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(AppThemeVariant.paper),
        home: Scaffold(
          body: ModooEmptyState(
            title: '还没有书',
            message: '导入一个 TXT 文件开始阅读。',
            action: FilledButton(onPressed: () => tapped = true, child: const Text('导入书籍')),
          ),
        ),
      ),
    );

    expect(find.text('还没有书'), findsOneWidget);
    expect(find.text('导入一个 TXT 文件开始阅读。'), findsOneWidget);
    await tester.tap(find.text('导入书籍'));
    expect(tapped, isTrue);
  });

  testWidgets('ModooSectionHeader shows the trailing widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(AppThemeVariant.paper),
        home: const Scaffold(
          body: ModooSectionHeader(title: '主题', trailing: Icon(Icons.palette_outlined)),
        ),
      ),
    );

    expect(find.text('主题'), findsOneWidget);
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
  });
}
