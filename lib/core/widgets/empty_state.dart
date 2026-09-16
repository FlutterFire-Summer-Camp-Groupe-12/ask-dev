import 'package:askdev/core/themes/app_tokens.dart';
import 'package:flutter/material.dart';

/// État vide réutilisable : icône sur pastille, titre, message et action
/// optionnelle. À utiliser dès qu'une liste ou une valeur peut être vide.
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final badge = compact ? 48.0 : 72.0;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
        horizontal: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: badge,
              height: badge,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: compact ? 22 : 32,
                color: colors.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (title != null)
              Text(
                title!,
                textAlign: TextAlign.center,
                style: compact
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.titleMedium,
              ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.xs + 2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
