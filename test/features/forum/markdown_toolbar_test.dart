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

  testWidgets('le bloc de code porte un langage et place le curseur dedans', (
    tester,
  ) async {
    await pumpToolbar(tester);
    controller.text = 'Contexte';
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );

    await tester.tap(find.byTooltip('Bloc de code'));
    await tester.pump();

    expect(controller.text, 'Contexte\n```dart\n\n```\n');
    expect(
      controller.selection,
      TextSelection.collapsed(offset: 'Contexte\n```dart\n'.length),
    );
  });

  testWidgets('le bloc de code entoure la sélection', (tester) async {
    await pumpToolbar(tester);
    controller.text = 'print(1)';
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 8);

    await tester.tap(find.byTooltip('Bloc de code'));
    await tester.pump();

    expect(controller.text, '\n```dart\nprint(1)\n```\n');
  });

  testWidgets('le lien sélectionne l’URL pour la remplacer aussitôt', (
    tester,
  ) async {
    await pumpToolbar(tester);
    controller.text = 'voir ceci';
    controller.selection = const TextSelection(baseOffset: 5, extentOffset: 9);

    await tester.tap(find.byTooltip('Lien'));
    await tester.pump();

    expect(controller.text, 'voir [ceci](https://)');
    expect(controller.selection.textInside(controller.text), 'https://');
  });

  testWidgets('la liste à puces préfixe toutes les lignes couvertes', (
    tester,
  ) async {
    await pumpToolbar(tester);
    controller.text = 'un\ndeux\ntrois';
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 13);

    await tester.tap(find.byTooltip('Liste à puces'));
    await tester.pump();

    expect(controller.text, '- un\n- deux\n- trois');
  });

  testWidgets('la liste numérotée incrémente chaque ligne', (tester) async {
    await pumpToolbar(tester);
    controller.text = 'un\ndeux';
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 7);

    await tester.tap(find.byTooltip('Liste numérotée'));
    await tester.pump();

    expect(controller.text, '1. un\n2. deux');
  });

  testWidgets('la citation préfixe toutes les lignes couvertes', (
    tester,
  ) async {
    await pumpToolbar(tester);
    controller.text = 'première\nseconde';
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 16);

    await tester.tap(find.byTooltip('Citation'));
    await tester.pump();

    expect(controller.text, '> première\n> seconde');
  });

  testWidgets('le titre bascule le préfixe sur la ligne', (tester) async {
    await pumpToolbar(tester);
    controller.text = 'Mon titre';
    controller.selection = TextSelection.collapsed(offset: 9);

    await tester.tap(find.byTooltip('Titre'));
    await tester.pump();
    expect(controller.text, '# Mon titre');

    await tester.tap(find.byTooltip('Titre'));
    await tester.pump();
    expect(controller.text, 'Mon titre');
  });

  testWidgets('les boutons offrent une cible tactile de 48', (tester) async {
    await pumpToolbar(tester);

    expect(tester.getSize(find.byTooltip('Gras')), const Size(48, 48));
    expect(tester.getSize(find.byTooltip('Bloc de code')), const Size(48, 48));
  });

  testWidgets('taper la barre ne ferme pas le clavier', (tester) async {
    final fieldFocus = FocusNode();
    addTearDown(fieldFocus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextField(focusNode: fieldFocus, controller: controller),
              MarkdownToolbar(controller: controller),
            ],
          ),
        ),
      ),
    );
    controller.text = 'du texte';
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(fieldFocus.hasFocus, isTrue);

    await tester.tap(find.byTooltip('Gras'));
    await tester.pump();

    expect(fieldFocus.hasFocus, isTrue);
    // Le tap place le curseur en début de champ : les marqueurs vides
    // s'insèrent là.
    expect(controller.text, '****du texte');
  });
}
