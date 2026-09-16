import 'package:flutter/material.dart';

/// Identité compacte d'un auteur (avatar + pseudo), affichée sur les
/// questions et réponses. Les couleurs suivent le thème de l'app.
class AuthorInfo extends StatelessWidget {
  const AuthorInfo({
    super.key,
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.avatarRadius = 14,
  });

  final String name;
  final String? subtitle;
  final String? avatarUrl;
  final double avatarRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: scheme.surfaceContainerHighest,
          backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
          child: hasAvatar
              ? null
              : Icon(
                  Icons.person,
                  color: scheme.onSurfaceVariant,
                  size: avatarRadius + 3,
                ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
