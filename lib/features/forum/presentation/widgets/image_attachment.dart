import 'dart:io';

import 'package:askdev/core/themes/app_tokens.dart';
import 'package:askdev/core/utils/extensions_context.dart';
import 'package:askdev/dependency_injection/injection.dart';
import 'package:askdev/features/forum/domain/usecases/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Propose la galerie ou l'appareil photo, envoie l'image choisie et
/// retourne son URL.
///
/// Retourne `null` si l'utilisateur annule ou si l'envoi échoue ; dans ce
/// dernier cas le message d'erreur est déjà affiché.
Future<String?> pickAndUploadImage(BuildContext context) async {
  final source = await _askSource(context);
  if (source == null || !context.mounted) return null;

  final picked = await ImagePicker().pickImage(
    source: source,
    // L'image est réduite avant l'envoi : suffisant pour une capture d'écran
    // ou une photo de code, et rapide à téléverser.
    maxWidth: 1600,
    imageQuality: 85,
  );
  if (picked == null || !context.mounted) return null;

  final result = await sl<UploadImage>()(File(picked.path));
  if (!context.mounted) return null;

  return result.fold((failure) {
    context.showError(failure.message);
    return null;
  }, (url) => url);
}

Future<ImageSource?> _askSource(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Text(
              'Ajouter une image',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Depuis la galerie'),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Prendre une photo'),
            onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );
}
