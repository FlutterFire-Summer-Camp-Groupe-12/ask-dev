import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({
    super.key,
    this.initialImagePath,
    this.initialImageUrl,
    required this.onImageSelected,
    this.enabled = true,
  });

  final String? initialImagePath;
  final String? initialImageUrl;
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
    _syncInitialImage();
  }

  @override
  void didUpdateWidget(covariant AvatarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImagePath != widget.initialImagePath ||
        oldWidget.initialImageUrl != widget.initialImageUrl) {
      setState(_syncInitialImage);
    }
  }

  void _syncInitialImage() {
    if (widget.initialImagePath != null && widget.initialImagePath!.isNotEmpty) {
      _selectedImage = XFile(widget.initialImagePath!);
      return;
    }

    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      _selectedImage = XFile(widget.initialImageUrl!);
      return;
    }

    _selectedImage = null;
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
    final imagePath = _selectedImage?.path;
    final ImageProvider<Object>? imageProvider = imagePath == null
        ? null
        : (imagePath.startsWith('http://') || imagePath.startsWith('https://'))
            ? NetworkImage(imagePath)
            : FileImage(File(imagePath));

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
              backgroundColor: const Color(0xFF17181B),
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(
                      Icons.person,
                      size: 42,
                      color: Colors.white70,
                    )
                  : null,
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 17,
                  color: Color(0xFF0D0D0F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}