import 'package:flutter/material.dart';

/// État vide réutilisable : icône sur disque de fond + titre/message +
/// action optionnelle. À utiliser dès qu'une liste ou une valeur peut être
/// vide (aucune question, aucun résultat, aucune bio, stats à zéro…).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    this.title,
    this.message,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String? title;
  final String? message;
  final Widget? action;

  /// Variante réduite pour les sous-sections (ex. « Questions récentes »).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconBox = compact ? 48.0 : 72.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 20 : 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconBox,
            height: iconBox,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: compact ? 22 : 32,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 15 : 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
