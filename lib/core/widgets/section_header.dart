import 'package:flutter/material.dart';

/// Libellé de section atténué (ex. « Votre compte », « Apparence »),
/// conforme à l'échelle typographique : 13sp, graisse moyenne, léger
/// letter-spacing, couleur secondaire. À utiliser en tête de chaque bloc,
/// jamais pour les titres de contenu (qui restent en 16–17sp semi-bold).
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key, this.action});

  final String label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
