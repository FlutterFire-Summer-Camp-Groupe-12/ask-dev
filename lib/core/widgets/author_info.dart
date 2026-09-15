import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/widgets/app_avatar.dart';
import 'package:flutter/material.dart';

/// Identité compacte d'un auteur : avatar, pseudo et sous-titre optionnel
/// (« a demandé il y a 2 h »).
class AuthorInfo extends StatelessWidget {
  const AuthorInfo({
    super.key,
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.avatarSize = 28,
  });

  final String name;
  final String? subtitle;
  final String? avatarUrl;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAvatar.url(avatarUrl, name: name, size: avatarSize),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.labelMedium,
              ),
              if (hasSubtitle)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(letterSpacing: 0),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
