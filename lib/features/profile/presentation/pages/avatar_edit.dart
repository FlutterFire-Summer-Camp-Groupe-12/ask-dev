import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({
    super.key,
    this.initialImagePath,
    required this.onImageSelected,
    this.enabled = true,
  });

  final String? initialImagePath;
  final ValueChanged<XFile> onImageSelected;
  final bool enabled;

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();

    if (widget.initialImagePath != null &&
        widget.initialImagePath!.isNotEmpty) {
      _selectedImage = XFile(widget.initialImagePath!);
    }
  }

  Future<void> _selectImage() async {
    if (!widget.enabled) return;

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (image == null || !mounted) return;

    setState(() {
      _selectedImage = image;
    });

    widget.onImageSelected(image);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final imagePath = _selectedImage?.path;

    return Semantics(
      button: true,
      label: 'Changer l’avatar',
      child: InkWell(
        onTap: widget.enabled ? _selectImage : null,
        customBorder: const CircleBorder(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: scheme.surfaceContainerHighest,
              backgroundImage: imagePath != null
                  ? FileImage(File(imagePath))
                  : null,
              child: imagePath == null
                  ? Icon(Icons.person, size: 42, color: scheme.onSurfaceVariant)
                  : null,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.onSurface,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 17,
                  color: scheme.surface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
