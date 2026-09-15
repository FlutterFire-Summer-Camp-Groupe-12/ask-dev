import 'package:flutter/material.dart';

/// Avatar rond unique de l'app : photo si elle se charge, sinon initiales.
///
/// [image] couvre les deux sources (réseau ou fichier choisi dans la
/// galerie). Préférer [AppAvatar.url] pour une photo distante.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, this.image, this.name, this.size = 40});

  AppAvatar.url(String? url, {Key? key, String? name, double size = 40})
    : this(
        key: key,
        image: url != null && url.trim().isNotEmpty ? NetworkImage(url) : null,
        name: name,
        size: size,
      );

  final ImageProvider? image;

  /// Nom affiché, utilisé pour les initiales et l'accessibilité.
  final String? name;
  final double size;

  static String initialsOf(String? name) {
    final words = (name ?? '')
        .trim()
        .split(RegExp(r'[\s._-]+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallback = _Initials(name: name, size: size, colors: colors);

    return Semantics(
      label: name != null ? 'Avatar de $name' : 'Avatar',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: ClipOval(
          child: image == null
              ? fallback
              : Image(
                  image: image!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => fallback,
                  frameBuilder: (context, child, frame, synchronous) {
                    if (synchronous || frame != null) return child;
                    return fallback;
                  },
                ),
        ),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({
    required this.name,
    required this.size,
    required this.colors,
  });

  final String? name;
  final double size;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final initials = AppAvatar.initialsOf(name);
    return ColoredBox(
      color: colors.primaryContainer,
      child: Center(
        child: initials.isEmpty
            ? Icon(
                Icons.person_rounded,
                size: size * 0.55,
                color: colors.onPrimaryContainer,
              )
            : Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.38,
                  fontWeight: FontWeight.w600,
                  color: colors.onPrimaryContainer,
                  height: 1,
                ),
              ),
      ),
    );
  }
}
