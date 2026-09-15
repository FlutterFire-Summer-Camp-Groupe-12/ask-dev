import 'package:askdev/features/forum/presentation/widgets/markdown_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  Future<void> pumpToolbar(
    WidgetTester tester, {
    Future<String?> Function()? onRequestImage,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarkdownToolbar(
            controller: controller,
            onRequestImage: onRequestImage,
          ),
        ),
      ),
    );
  }

  testWidgets('le bouton image n\'apparaît que si l\'envoi est possible', (
    tester,
  ) async {
    await pumpToolbar(tester);
    expect(find.byTooltip('Ajouter une image'), findsNothing);

    await pumpToolbar(tester, onRequestImage: () async => null);
    expect(find.byTooltip('Ajouter une image'), findsOneWidget);
  });

  testWidgets('insère le lien Markdown et sélectionne la légende', (
    tester,
  ) async {
    await pumpToolbar(
      tester,
      onRequestImage: () async => 'https://exemple.test/capture.png',
    );
    controller.text = 'Voici mon erreur :';
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );

    await tester.tap(find.byTooltip('Ajouter une image'));
    await tester.pumpAndSettle();

    expect(
      controller.text,
      'Voici mon erreur :\n![image](https://exemple.test/capture.png)\n',
    );
    // La légende est sélectionnée pour être remplacée aussitôt.
    expect(controller.selection.textInside(controller.text), 'image');
  });

  testWidgets('ne touche pas au texte si l\'envoi échoue', (tester) async {
    await pumpToolbar(tester, onRequestImage: () async => null);
    controller.text = 'Mon texte';

    await tester.tap(find.byTooltip('Ajouter une image'));
    await tester.pumpAndSettle();

    expect(controller.text, 'Mon texte');
  });

  testWidgets('entoure la sélection avec les marqueurs de gras', (
    tester,
  ) async {
    await pumpToolbar(tester);
    controller.text = 'texte important';
    controller.selection = const TextSelection(baseOffset: 6, extentOffset: 15);

    await tester.tap(find.byTooltip('Gras'));
    await tester.pump();

    expect(controller.text, 'texte **important**');
  });
}
