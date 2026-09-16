import 'package:askdev/core/themes/app_tokens.dart';
import 'package:flutter/material.dart';

/// Barre d'outils Markdown posée au-dessus d'un champ de texte.
///
/// Chaque bouton agit directement sur [controller] : le texte sélectionné est
/// entouré des marqueurs correspondants, ou les marqueurs sont insérés au
/// curseur quand rien n'est sélectionné.
class MarkdownToolbar extends StatefulWidget {
  const MarkdownToolbar({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onRequestImage,
    this.borderRadius = const BorderRadius.vertical(
      top: Radius.circular(AppRadius.md),
    ),
  });

  final TextEditingController controller;
  final bool enabled;

  /// Choisit et envoie une image, puis retourne son URL. Quand ce rappel est
  /// fourni, la barre affiche un bouton d'ajout d'image et insère le lien
  /// Markdown au curseur.
  final Future<String?> Function()? onRequestImage;

  /// Arrondi du fond : haut seulement quand la barre coiffe un champ.
  final BorderRadius borderRadius;

  @override
  State<MarkdownToolbar> createState() => _MarkdownToolbarState();
}

class _MarkdownToolbarState extends State<MarkdownToolbar> {
  bool _uploading = false;

  bool get _enabled => widget.enabled && !_uploading;

  TextEditingController get _controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
        borderRadius: widget.borderRadius,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          children: [
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Gras',
              onPressed: _enabled ? () => _wrap('**', '**') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Italique',
              onPressed: _enabled ? () => _wrap('_', '_') : null,
            ),
            _ToolbarButton(
              icon: Icons.strikethrough_s,
              tooltip: 'Barré',
              onPressed: _enabled ? () => _wrap('~~', '~~') : null,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.code,
              tooltip: 'Code en ligne',
              onPressed: _enabled ? () => _wrap('`', '`') : null,
            ),
            _ToolbarButton(
              icon: Icons.data_object,
              tooltip: 'Bloc de code',
              onPressed: _enabled ? () => _wrap('\n```\n', '\n```\n') : null,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.link,
              tooltip: 'Lien',
              onPressed: _enabled ? () => _wrap('[', '](https://)') : null,
            ),
            if (widget.onRequestImage != null)
              _ToolbarButton(
                icon: Icons.image_outlined,
                tooltip: 'Ajouter une image',
                busy: _uploading,
                onPressed: _enabled ? _insertImage : null,
              ),
            _ToolbarButton(
              icon: Icons.format_quote,
              tooltip: 'Citation',
              onPressed: _enabled ? () => _prefixLine('> ') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Liste à puces',
              onPressed: _enabled ? () => _prefixLine('- ') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Liste numérotée',
              onPressed: _enabled ? () => _prefixLine('1. ') : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _insertImage() async {
    setState(() => _uploading = true);
    try {
      final url = await widget.onRequestImage!();
      if (url == null || !mounted) return;
      _insertImageLink(url);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// Insère `![légende](url)` sur sa propre ligne et sélectionne la légende,
  /// pour que l'auteur puisse la remplacer aussitôt.
  void _insertImageLink(String url) {
    const caption = 'image';
    final value = _controller.value;
    final text = value.text;
    final at = value.selection.isValid ? value.selection.end : text.length;

    final before = text.substring(0, at);
    final after = text.substring(at);
    final prefix = before.isEmpty || before.endsWith('\n') ? '' : '\n';
    final suffix = after.startsWith('\n') ? '' : '\n';
    final snippet = '$prefix![$caption]($url)$suffix';

    _controller.value = TextEditingValue(
      text: '$before$snippet$after',
      selection: TextSelection(
        baseOffset: at + prefix.length + 2,
        extentOffset: at + prefix.length + 2 + caption.length,
      ),
    );
  }

  void _wrap(String left, String right) {
    final value = _controller.value;
    final selection = value.selection;
    if (!selection.isValid) {
      _appendAtEnd('$left$right', left.length + right.length);
      return;
    }

    final selected = selection.textInside(value.text);
    final text =
        '${selection.textBefore(value.text)}$left$selected$right'
        '${selection.textAfter(value.text)}';
    final caret = selected.isEmpty
        ? selection.start + left.length
        : selection.start + left.length + selected.length + right.length;

    _controller.value = value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: caret),
      composing: TextRange.empty,
    );
  }

  void _prefixLine(String prefix) {
    final value = _controller.value;
    final selection = value.selection;
    if (!selection.isValid) {
      _appendAtEnd(prefix, 0);
      return;
    }

    final lineStart = value.text.lastIndexOf('\n', selection.start - 1) + 1;
    final text = value.text.replaceRange(lineStart, lineStart, prefix);

    _controller.value = value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: selection.end + prefix.length),
      composing: TextRange.empty,
    );
  }

  /// Insère [snippet] en fin de texte quand le champ n'a jamais reçu le focus
  /// (aucune sélection valide) et place le curseur au milieu des marqueurs.
  void _appendAtEnd(String snippet, int markersLength) {
    final text = _controller.text + snippet;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length - (markersLength ~/ 2),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.busy = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      icon: busy
          ? SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primary,
              ),
            )
          : Icon(icon, size: 18),
      color: colors.onSurfaceVariant,
      disabledColor: colors.outline,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      padding: EdgeInsets.zero,
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 18,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
