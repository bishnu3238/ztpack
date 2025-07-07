import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'prograssive_image_picker.dart';
/// A reusable widget for displaying selected images with add/remove functionality
/// ImageSelectionGrid(
///   maxImages: 10,
///   initialImages: existingImages,
///   onImagesChanged: (updatedImages) {
///     // Handle updated image list
///     setState(() => selectedImages = updatedImages);
///   },
/// )
class ImageSelectionGrid extends StatefulWidget {
  final int maxImages;
  final List<XFile> initialImages;
  final Function(List<XFile>) onImagesChanged;
  final double spacing;
  final int crossAxisCount;

  const ImageSelectionGrid({
    super.key,
    required this.maxImages,
    this.initialImages = const [],
    required this.onImagesChanged,
    this.spacing = 8.0,
    this.crossAxisCount = 3,
  });

  @override
  State<ImageSelectionGrid> createState() => _ImageSelectionGridState();
}

class _ImageSelectionGridState extends State<ImageSelectionGrid> {
  late ProgressiveImagePicker _picker;

  @override
  void initState() {
    super.initState();
    _picker = ProgressiveImagePicker(maxImages: widget.maxImages);

    // Add initial images if any
    for (var image in widget.initialImages) {
      if (_picker.selectedImages.length < widget.maxImages) {
        _picker.selectedImages.add(image);
      }
    }
  }

  Future<void> _addImages() async {
    final result = await _picker.addMoreImages(
      context: context,
      title: 'Add Images',
      message: 'You can select up to ${_picker.remainingCount} more image${_picker.remainingCount > 1 ? 's' : ''}',
    );

    result.fold(
          (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      },
          (newImages) {
        if (newImages.isNotEmpty) {
          setState(() {
            // Already added to picker internally
          });
          widget.onImagesChanged(_picker.selectedImages);
        }
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _picker.removeImage(index);
      widget.onImagesChanged(_picker.selectedImages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images (${_picker.selectedImages.length}/${widget.maxImages})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: widget.spacing,
            mainAxisSpacing: widget.spacing,
          ),
          itemCount: _picker.selectedImages.length + (_picker.isFull ? 0 : 1),
          itemBuilder: (context, index) {
            if (index == _picker.selectedImages.length) {
              // This is the "add more" button
              return InkWell(
                onTap: _addImages,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_photo_alternate,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }

            // Display selected image with remove button
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_picker.selectedImages[index].path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}