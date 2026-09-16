import 'package:askdev/core/themes/app_palette.dart';
import 'package:askdev/core/themes/app_tokens.dart';
import 'package:flutter/material.dart';

/// Tag d'une question ou topic d'un profil.
///
/// Passif par défaut ; [onDeleted] ajoute la croix de retrait et [onTap]
/// rend la puce cliquable (suggestion).
class TagChip extends StatelessWidget {
  const TagChip(
    this.label, {
    super.key,
    this.onTap,
    this.onDeleted,
    this.muted = false,
  });

  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  /// Style neutre, pour les suggestions pas encore choisies.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final colors = Theme.of(context).colorScheme;
    final background = muted ? colors.surfaceContainer : palette.tagBackground;
    final foreground = muted ? colors.onSurfaceVariant : palette.tagForeground;
    final style = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: foreground, letterSpacing: 0);

    return Material(
      color: background,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.sm,
            right: onDeleted != null ? AppSpacing.xs : AppSpacing.sm,
            top: AppSpacing.xs,
            bottom: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: style),
              if (onDeleted != null) ...[
                const SizedBox(width: AppSpacing.xxs),
                Semantics(
                  button: true,
                  label: 'Retirer $label',
                  child: InkResponse(
                    onTap: onDeleted,
                    radius: 14,
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Rangée de tags qui passe à la ligne.
class TagWrap extends StatelessWidget {
  const TagWrap({super.key, required this.tags, this.maxVisible});

  final List<String> tags;

  /// Au-delà, un compteur « +N » remplace les tags restants.
  final int? maxVisible;

  @override
  Widget build(BuildContext context) {
    final limit = maxVisible;
    final visible = limit == null || tags.length <= limit
        ? tags
        : tags.take(limit).toList();
    final hidden = tags.length - visible.length;
    return Wrap(
      spacing: AppSpacing.xs + 2,
      runSpacing: AppSpacing.xs + 2,
      children: [
        for (final tag in visible) TagChip(tag),
        if (hidden > 0) TagChip('+$hidden', muted: true),
      ],
    );
  }
}
