import 'package:askdev/core/themes/app_tokens.dart';
import 'package:flutter/material.dart';

/// Barre d'outils Markdown posée au-dessus d'un champ de texte.
///
/// Chaque bouton agit directement sur [controller] : le texte sélectionné est
/// entouré des marqueurs correspondants, ou les marqueurs sont insérés au
/// curseur quand rien n'est sélectionné. Les listes, citations et titres
/// s'appliquent à toutes les lignes couvertes par la sélection.
///
/// Les boutons ne prennent jamais le focus : le clavier reste ouvert pendant
/// la frappe sur mobile.
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
  static const _codeLanguage = 'dart';
  static const _urlPlaceholder = 'https://';
  static final _headingRegExp = RegExp(r'^#{1,6} ');

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
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            _ToolbarButton(
              icon: Icons.title_rounded,
              tooltip: 'Titre',
              onPressed: _enabled ? _toggleHeading : null,
            ),
            _ToolbarButton(
              icon: Icons.format_bold,
              tooltip: 'Gras',
              onPressed: _enabled ? () => _wrap('**', '**') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_italic,
              tooltip: 'Italique',
              onPressed: _enabled ? () => _wrap('*', '*') : null,
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
              onPressed: _enabled ? _insertCodeBlock : null,
            ),
            const _ToolbarDivider(),
            _ToolbarButton(
              icon: Icons.link,
              tooltip: 'Lien',
              onPressed: _enabled ? _insertLink : null,
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
              onPressed: _enabled ? () => _prefixSelection((_, line) => '> $line') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_list_bulleted,
              tooltip: 'Liste à puces',
              onPressed: _enabled ? () => _prefixSelection((_, line) => '- $line') : null,
            ),
            _ToolbarButton(
              icon: Icons.format_list_numbered,
              tooltip: 'Liste numérotée',
              onPressed: _enabled ? () => _prefixSelection((i, line) => '${i + 1}. $line') : null,
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

    _setValue(
      '$before$snippet$after',
      TextSelection(
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

    _setValue(text, TextSelection.collapsed(offset: caret));
  }

  /// Insère `[sélection](https://)` et sélectionne l'URL, pour qu'elle soit
  /// remplacée dès la première frappe.
  void _insertLink() {
    final value = _controller.value;
    final selection = value.selection;
    if (!selection.isValid) {
      final appended = '${_controller.text}[]($_urlPlaceholder)';
      _setValue(
        appended,
        TextSelection(
          baseOffset: appended.length - 1 - _urlPlaceholder.length,
          extentOffset: appended.length - 1,
        ),
      );
      return;
    }

    final selected = selection.textInside(value.text);
    final before = selection.textBefore(value.text);
    // '[sélection](' mesure la sélection + 3 caractères.
    final urlStart = before.length + selected.length + 3;
    _setValue(
      '$before[$selected]($_urlPlaceholder)${selection.textAfter(value.text)}',
      TextSelection(
        baseOffset: urlStart,
        extentOffset: urlStart + _urlPlaceholder.length,
      ),
    );
  }

  /// Insère un bloc de code avec langage (coloration syntaxique) sur ses
  /// propres lignes. Sans sélection, le curseur atterrit sur la ligne vide
  /// entre les délimiteurs.
  void _insertCodeBlock() {
    const open = '\n```$_codeLanguage\n';
    const close = '```\n';
    final value = _controller.value;
    final selection = value.selection;
    if (!selection.isValid) {
      final base = _controller.text;
      final sep = base.isEmpty || base.endsWith('\n') ? '' : '\n';
      final next = '$base$sep```$_codeLanguage\n\n$close';
      _setValue(
        next,
        TextSelection.collapsed(
          offset: base.length + sep.length + open.length,
        ),
      );
      return;
    }

    final selected = selection.textInside(value.text);
    final before = selection.textBefore(value.text);
    final after = selection.textAfter(value.text);
    final body = selected.isEmpty ? '\n' : '$selected\n';
    final snippet = '$open$body$close';
    final caret = selected.isEmpty
        ? before.length + open.length
        : before.length + snippet.length;
    _setValue('$before$snippet$after', TextSelection.collapsed(offset: caret));
  }

  /// Applique [buildLine] à chaque ligne couverte par la sélection
  /// (listes, citation, titre). Une sélection qui se termine pile au début
  /// d'une ligne ne couvre pas cette dernière ligne.
  void _prefixSelection(String Function(int lineIndex, String line) buildLine) {
    final value = _controller.value;
    final selection = value.selection;
    if (!selection.isValid) {
      _appendLine(buildLine(0, ''));
      return;
    }

    final text = value.text;
    final start = selection.start;
    var end = selection.end;
    if (end > start && text[end - 1] == '\n') end -= 1;

    final blockStart = start == 0 ? 0 : text.lastIndexOf('\n', start - 1) + 1;
    var blockEnd = text.indexOf('\n', end);
    if (blockEnd == -1) blockEnd = text.length;

    final lines = text.substring(blockStart, blockEnd).split('\n');
    final prefixed = [
      for (var i = 0; i < lines.length; i++) buildLine(i, lines[i]),
    ].join('\n');

    final next = text.replaceRange(blockStart, blockEnd, prefixed);
    _setValue(
      next,
      TextSelection.collapsed(offset: blockStart + prefixed.length),
    );
  }

  /// Bascule `# ` sur chaque ligne couverte : ajouté s'il est absent,
  /// retiré s'il est déjà là.
  void _toggleHeading() {
    _prefixSelection((_, line) {
      final match = _headingRegExp.firstMatch(line);
      return match == null ? '# $line' : line.substring(match.end);
    });
  }

  /// Ajoute [line] sur sa propre ligne en fin de texte, quand le champ n'a
  /// jamais reçu le focus.
  void _appendLine(String line) {
    final text = _controller.text;
    final sep = text.isEmpty || text.endsWith('\n') ? '' : '\n';
    final next = '$text$sep$line';
    _setValue(next, TextSelection.collapsed(offset: next.length));
  }

  /// Insère [snippet] en fin de texte quand le champ n'a jamais reçu le focus
  /// (aucune sélection valide) et place le curseur au milieu des marqueurs.
  void _appendAtEnd(String snippet, int markersLength) {
    final text = _controller.text + snippet;
    _setValue(
      text,
      TextSelection.collapsed(
        offset: text.length - (markersLength ~/ 2),
      ),
    );
  }

  void _setValue(String text, TextSelection selection) {
    _controller.value = TextEditingValue(
      text: text,
      selection: selection,
      composing: TextRange.empty,
    );
  }
}

/// Bouton tactile 48×48 construit sur [InkWell] plutôt que [IconButton] :
/// sans nœud de focus, le clavier reste ouvert quand on tape la barre.
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
    final enabled = onPressed != null && !busy;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: SizedBox.square(
            dimension: 48,
            child: busy
                ? Center(
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    size: 22,
                    color: enabled
                        ? colors.onSurfaceVariant
                        : colors.outline,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
