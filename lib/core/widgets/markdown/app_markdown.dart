import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/core/widgets/markdown/code_highlighter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

/// Rendu Markdown commun aux questions et aux réponses, avec coloration
/// syntaxique des blocs de code.
class AppMarkdown extends StatelessWidget {
  const AppMarkdown({super.key, required this.data, this.selectable = true});

  final String data;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: selectable,
      styleSheet: _styleSheet(Theme.of(context)),
      builders: {'code': _CodeElementBuilder(selectable: selectable)},
    );
  }

  /// Apparence alignée sur le thème de l'app (corps 14, hauteur confortable,
  /// palette issue du ColorScheme).
  static MarkdownStyleSheet _styleSheet(ThemeData theme) {
    final colors = theme.colorScheme;
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: TextStyle(fontSize: 14, height: 1.5, color: colors.onSurface),
      blockquote: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: colors.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        backgroundColor: colors.surfaceContainerHighest,
        color: colors.onSurface,
      ),
      codeblockPadding: EdgeInsets.zero,
      codeblockDecoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// Remplace le rendu des blocs de code. Le code en ligne garde le rendu par
/// défaut (retour `null`).
class _CodeElementBuilder extends MarkdownElementBuilder {
  _CodeElementBuilder({required this.selectable});

  final bool selectable;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final source = element.textContent;
    final languageClass = element.attributes['class'];
    // Un bloc clôturé porte `language-xxx` ou, sans langage, se termine par un
    // saut de ligne. Le code en ligne n'a ni l'un ni l'autre.
    final isBlock = languageClass != null || source.contains('\n');
    if (!isBlock) return null;

    return _CodeBlock(
      source: source.endsWith('\n')
          ? source.substring(0, source.length - 1)
          : source,
      language: languageClass?.replaceFirst('language-', ''),
      selectable: selectable,
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({
    required this.source,
    required this.language,
    required this.selectable,
  });

  final String source;
  final String? language;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightTheme = isDark ? atomOneDarkTheme : githubTheme;
    final highlighter = CodeHighlighter.instance;
    final label =
        highlighter.resolveLanguage(source, language: language) ?? language;

    final span = TextSpan(
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        height: 1.45,
        color: highlightTheme['root']?.color ?? colors.onSurface,
      ),
      children: [
        highlighter.format(source, theme: highlightTheme, language: language),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label ?? 'code',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: source));
                  if (context.mounted) context.showSnackBar('Code copié.');
                },
                icon: const Icon(Icons.copy_rounded),
                iconSize: 16,
                visualDensity: VisualDensity.compact,
                color: colors.onSurfaceVariant,
                tooltip: 'Copier le code',
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: selectable
              ? SelectableText.rich(span)
              : Text.rich(span, softWrap: false),
        ),
      ],
    );
  }
}
