import 'package:askdev/core/widgets/markdown/app_markdown.dart';
import 'package:askdev/core/widgets/markdown/code_highlighter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(String data) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(child: AppMarkdown(data: data)),
    ),
  );
}

void main() {
  group('CodeHighlighter', () {
    test('colors a known language', () {
      final span = CodeHighlighter.instance.format(
        'final count = 0;',
        theme: githubTheme,
        language: 'dart',
      );

      // Le style est porté par le segment parent, le texte par ses enfants.
      bool hasStyledSpan(InlineSpan span) =>
          span is TextSpan &&
          (span.style != null ||
              (span.children ?? const []).any(hasStyledSpan));
      expect(span.children, isNotEmpty);
      expect(span.children!.any(hasStyledSpan), isTrue);
    });

    test('accepts aliases such as js', () {
      expect(
        CodeHighlighter.instance.resolveLanguage(
          'const a = 1;',
          language: 'js',
        ),
        'js',
      );
    });

    test('falls back to plain text for an unknown language', () {
      final span = CodeHighlighter.instance.format(
        'du texte',
        theme: githubTheme,
        language: 'langage-inconnu',
      );
      expect(span.toPlainText(), 'du texte');
    });
  });

  group('AppMarkdown', () {
    testWidgets('renders a fenced block with its language and copy button', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap('Voici :\n\n```dart\nvoid main() {}\n```\n'),
      );

      expect(find.text('dart'), findsOneWidget);
      expect(find.byTooltip('Copier le code'), findsOneWidget);
    });

    testWidgets('leaves inline code without a code block header', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap('Appelez `setState` ici.'));

      expect(find.byTooltip('Copier le code'), findsNothing);
    });
  });
}
