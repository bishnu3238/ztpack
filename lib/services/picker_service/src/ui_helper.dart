import 'package:flutter/material.dart';
import 'image_picker.dart';

/// Pre-built dialogs and UI components for quick implementation

/// A customizable widget for showing image source options with icons
class ImageSourceOptionsWidget extends StatelessWidget {
  final String title;
  final String? message;
  final Function() onCameraTap;
  final Function() onGalleryTap;
  final Function()? onCancel;
  final Color? primaryColor;
  final Color? secondaryColor;
  final IconData? cameraIcon;
  final IconData? galleryIcon;
  final bool showIcons;

  const ImageSourceOptionsWidget({
    Key? key,
    required this.title,
    this.message,
    required this.onCameraTap,
    required this.onGalleryTap,
    this.onCancel,
    this.primaryColor,
    this.secondaryColor,
    this.cameraIcon,
    this.galleryIcon,
    this.showIcons = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = primaryColor ?? theme.primaryColor;
    final secondary = secondaryColor ?? theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ImageSourceOption(
                label: 'Camera',
                icon: cameraIcon ?? Icons.camera_alt,
                color: color,
                onTap: onCameraTap,
                showIcon: showIcons,
              ),
              _ImageSourceOption(
                label: 'Gallery',
                icon: galleryIcon ?? Icons.photo_library,
                color: secondary,
                onTap: onGalleryTap,
                showIcon: showIcons,
              ),
            ],
          ),
          if (onCancel != null) ...[
            const SizedBox(height: 24),
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
          ],
        ],
      ),
    );
  }
}

/// Helper widget for image source options
class _ImageSourceOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Function() onTap;
  final bool showIcon;

  const _ImageSourceOption({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          if (showIcon) ...[
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
