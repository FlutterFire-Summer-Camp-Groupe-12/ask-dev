import 'package:flutter/material.dart';

/// Action destructive rendue comme bouton (contour ou fond rouge doux),
/// jamais comme simple texte nu. Seul usage du rouge dans l'application.
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.logout,
    this.expanded = true,
  });

  final String label;
  final VoidCallback onPressed;
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
        side: BorderSide(color: colors.error.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
