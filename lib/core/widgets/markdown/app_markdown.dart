import 'package:askdev/core/themes/app_palette.dart';
import 'package:askdev/core/themes/app_theme.dart';
import 'package:askdev/core/themes/app_tokens.dart';
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
      sizedImageBuilder: (config) => MarkdownImage(
        url: config.uri.toString(),
        alt: config.alt ?? config.title,
      ),
    );
  }

  /// Apparence alignée sur le thème : texte de lecture en 14 aéré, titres
  /// sur l'échelle de l'app, code en JetBrains Mono sur fond dédié.
  static MarkdownStyleSheet _styleSheet(ThemeData theme) {
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final palette = theme.extension<AppPalette>() ?? AppPalette.light;
    final body = text.bodyMedium?.copyWith(height: 1.6);
    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: body,
      listBullet: body,
      h1: text.headlineSmall,
      h2: text.titleMedium?.copyWith(fontSize: 16),
      h3: text.titleSmall,
      h4: text.titleSmall,
      a: body?.copyWith(
        color: colors.primary,
        decoration: TextDecoration.underline,
        decorationColor: colors.primary.withValues(alpha: 0.4),
      ),
      blockquote: body?.copyWith(color: colors.onSurfaceVariant),
      blockquotePadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.primary, width: 3)),
      ),
      code: TextStyle(
        fontFamily: AppTheme.monoFamily,
        fontSize: 13,
        backgroundColor: palette.codeBackground,
        color: colors.onSurface,
      ),
      codeblockPadding: EdgeInsets.zero,
      codeblockDecoration: BoxDecoration(
        color: palette.codeBackground,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.outlineVariant),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      pPadding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      blockSpacing: AppSpacing.md,
    );
  }
}

/// Image jointe à une question ou une réponse : hauteur plafonnée, coins
/// arrondis, et plein écran au toucher.
class MarkdownImage extends StatelessWidget {
  const MarkdownImage({super.key, required this.url, this.alt});

  /// Au-delà, l'image serait plus haute que l'écran sur téléphone.
  static const double maxHeight = 320;

  final String url;
  final String? alt;

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      DialogRoute<void>(
        context: context,
        barrierColor: Colors.black87,
        builder: (dialogContext) => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            title: alt == null ? null : Text(alt!),
            leading: IconButton(
              onPressed: () => Navigator.of(dialogContext).maybePop(),
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Fermer',
            ),
          ),
          body: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(child: Image.network(url)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Semantics(
        button: true,
        label: alt ?? 'Image jointe',
        child: GestureDetector(
          onTap: () => _openFullScreen(context),
          child: ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: maxHeight),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _ImagePlaceholder(
                    color: colors.surfaceContainer,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stack) => _ImagePlaceholder(
                  color: colors.surfaceContainer,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Image indisponible',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      color: color,
      child: child,
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
        fontFamily: AppTheme.monoFamily,
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
          padding: const EdgeInsets.only(left: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label ?? 'code',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontFamily: AppTheme.monoFamily,
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: selectable
              ? SelectableText.rich(span)
              : Text.rich(span, softWrap: false),
        ),
      ],
    );
  }
}
