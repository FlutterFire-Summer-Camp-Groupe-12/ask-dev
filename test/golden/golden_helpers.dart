import 'dart:io';

import 'package:askdev/core/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Charge Inter et JetBrains Mono : les tests n'utilisent sinon que la
/// police de test, et les captures ne montreraient pas la vraie typographie.
Future<void> loadAppFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(
        File('assets/fonts/$file').readAsBytes().then(ByteData.sublistView),
      );
    }
    await loader.load();
  }

  await load(AppTheme.fontFamily, [
    'Inter-Regular.ttf',
    'Inter-Medium.ttf',
    'Inter-SemiBold.ttf',
    'Inter-Bold.ttf',
  ]);
  // Sans cette police, toutes les icônes seraient des carrés vides.
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();

  await load(AppTheme.monoFamily, [
    'JetBrainsMono-Regular.ttf',
    'JetBrainsMono-Medium.ttf',
  ]);
}

/// Enveloppe un écran dans le thème de l'app, à taille de téléphone.
Widget themedApp(Widget child, {required Brightness brightness}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: const AppTheme().light,
    darkTheme: const AppTheme().dark,
    themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
    home: child,
  );
}

/// Rend [child] en clair puis en sombre et compare aux références
/// `<name>_light.png` et `<name>_dark.png`.
Future<void> expectGoldenPair(
  WidgetTester tester,
  String name,
  Widget child, {
  Size size = const Size(400, 860),
}) async {
  for (final brightness in Brightness.values) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(themedApp(child, brightness: brightness));
    await tester.pumpAndSettle();

    final suffix = brightness == Brightness.dark ? 'dark' : 'light';
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/${name}_$suffix.png'),
    );
  }
}
