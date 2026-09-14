import 'package:askdev/core/utils/markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stripMarkdown', () {
    test('retire le gras', () {
      expect(stripMarkdown("**J'ai besoin d'aide**"), "J'ai besoin d'aide");
    });

    test('retire italique, barré et code en ligne', () {
      expect(stripMarkdown('*en italique* et ~~barré~~ et `code`'), 'en italique et barré et code');
    });

    test('extrait le texte des liens', () {
      expect(
        stripMarkdown('[vite](https://flutter.dev) c\'est rapide'),
        'vite c\'est rapide',
      );
      expect(stripMarkdown('![alt](image.png)'), '');
    });

    test('retire titres, listes, bloc de code et citations', () {
      expect(
        stripMarkdown('## Titre\n> citation\n- item 1\n- item 2'),
        'Titre\ncitation\nitem 1\nitem 2',
      );
    });

    test('retourne vide pour nul, vide ou syntaxe seule', () {
      expect(stripMarkdown(null), '');
      expect(stripMarkdown('   '), '');
    });

    test('conserve le texte simple', () {
      expect(stripMarkdown('Texte simple.'), 'Texte simple.');
    });
  });
}