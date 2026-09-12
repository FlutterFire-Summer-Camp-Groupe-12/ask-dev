import 'package:askdev/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

/// Barre d'outils Markdown posée au-dessus du champ de description.
///
/// Chaque bouton agit directement sur [controller] : le texte sélectionné est
/// entouré des marqueurs correspondants, ou les marqueurs sont insérés au
/// curseur quand rien n'est sélectionné.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceHigh,
        border: Border(bottom: BorderSide(color: AppColors.border)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Gras',
              onPressed: enabled ? () => _wrap('**', '**') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Italique',
              onPressed: enabled ? () => _wrap('_', '_') : null,
            ),
            _ToolbarButton(
              icon: Icons.strikethrough_s,
              tooltip: 'Barré',
              onPressed: enabled ? () => _wrap('~~', '~~') : null,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.code,
              tooltip: 'Code en ligne',
              onPressed: enabled ? () => _wrap('`', '`') : null,
            ),
            _ToolbarButton(
              icon: Icons.data_object,
              tooltip: 'Bloc de code',
              onPressed: enabled ? () => _wrap('\n```\n', '\n```\n') : null,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.link,
              tooltip: 'Lien',
              onPressed: enabled ? () => _wrap('[', '](https://)') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_quote,
              tooltip: 'Citation',
              onPressed: enabled ? () => _prefixLine('> ') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Liste à puces',
              onPressed: enabled ? () => _prefixLine('- ') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Liste numérotée',
              onPressed: enabled ? () => _prefixLine('1. ') : null,
            ),
          ],
        ),
      ),
    );
  }

  void _wrap(String left, String right) {
    final value = controller.value;
    final selection = value.selection;
    if (!selection.isValid) {
      _appendAtEnd('$left$right', left.length + right.length);
      return;
    }

    final selected = selection.textInside(value.text);
    final text =
        '${selection.textBefore(value.text)}$left$selected$right${selection.textAfter(value.text)}';
    final caret = selected.isEmpty
        ? selection.start + left.length
        : selection.start + left.length + selected.length + right.length;

    controller.value = value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: caret),
      composing: TextRange.empty,
    );
  }

  void _prefixLine(String prefix) {
    final value = controller.value;
    final selection = value.selection;
    if (!selection.isValid) {
      _appendAtEnd(prefix, 0);
      return;
    }

    final lineStart = value.text.lastIndexOf('\n', selection.start - 1) + 1;
    final text = value.text.replaceRange(lineStart, lineStart, prefix);

    controller.value = value.copyWith(
      text: text,
      selection: TextSelection.collapsed(
        offset: selection.end + prefix.length,
      ),
      composing: TextRange.empty,
    );
  }

  /// Insère [snippet] en fin de texte quand le champ n'a jamais reçu le focus
  /// (aucune sélection valide) et place le curseur au milieu des marqueurs.
  void _appendAtEnd(String snippet, int markersLength) {
    final text = controller.text + snippet;
    controller.value = TextEditingValue(
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
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      color: AppColors.textSecondary,
      disabledColor: AppColors.textFaint,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 34, height: 34),
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
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: AppColors.border,
    );
  }
}
