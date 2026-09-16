import 'dart:io';

import 'package:askdev/core/widgets/app_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Avatar cliquable qui ouvre la galerie. Affiche la photo actuelle (une URL
/// distante) tant que l'utilisateur n'en a pas choisi une nouvelle.
class AvatarPicker extends StatefulWidget {
  const AvatarPicker({
    super.key,
    this.currentAvatarUrl,
    this.name,
    required this.onImageSelected,
    this.enabled = true,
  });

  final String? currentAvatarUrl;
  final String? name;
  final ValueChanged<XFile> onImageSelected;
  final bool enabled;

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _selectImage() async {
    if (!widget.enabled) return;

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (image == null || !mounted) return;

    setState(() => _selectedImage = image);
    widget.onImageSelected(image);
  }

  ImageProvider? get _image {
    final picked = _selectedImage;
    if (picked != null) return FileImage(File(picked.path));
    final url = widget.currentAvatarUrl;
    if (url != null && url.trim().isNotEmpty) return NetworkImage(url);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Changer la photo de profil',
      child: InkWell(
        onTap: widget.enabled ? _selectImage : null,
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppAvatar(image: _image, name: widget.name, size: 96),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                  border: Border.all(color: colors.surface, width: 2),
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 16,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
