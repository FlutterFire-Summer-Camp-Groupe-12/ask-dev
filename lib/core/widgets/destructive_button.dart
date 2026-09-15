import 'package:flutter/material.dart';

/// Action destructive rendue comme bouton à contour rouge, jamais comme
/// simple texte. Seul usage du rouge hors erreurs.
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.logout_rounded,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  /// Pleine largeur (par défaut), ou contenu au plus juste.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final button = OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error.withValues(alpha: 0.45)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
