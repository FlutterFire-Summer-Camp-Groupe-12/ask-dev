import 'package:flutter/material.dart';

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
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: const Color(0xFF17181B),
          backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
          child: hasAvatar
              ? null
              : Icon(
                  Icons.person,
                  color: Colors.white70,
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
                style: const TextStyle(
                  color: Colors.white,
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
                  style: const TextStyle(
                    color: Colors.white54,
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