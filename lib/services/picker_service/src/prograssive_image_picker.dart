import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'image_picker.dart';

/// Advanced implementation for progressive image selection with limit
/// This allows users to select images in batches while tracking the total count
/// Advanced Progressive Selection
/// If you need to let users add images incrementally
/// (like in a form where they might add images in batches),
/// I've created a [ProgressiveImagePicker] class:
class ProgressiveImagePicker {
  final int maxImages;
  final List<XFile> _selectedImages = [];

  ProgressiveImagePicker({required this.maxImages});

  int get remainingCount => maxImages - _selectedImages.length;
  List<XFile> get selectedImages => List.unmodifiable(_selectedImages);
  bool get isFull => _selectedImages.length >= maxImages;

  /// Add more images while respecting the maximum limit
  Future<Either<ImagePickFailure, List<XFile>>> addMoreImages({
    required BuildContext context,
    String? title,
    String? message,
  }) async {
    if (isFull) {
      return Left(ImagePickFailure(
        message: 'Maximum number of images ($maxImages) already selected',
        type: ImagePickFailureType.unknown,
      ));
    }

    // Customize messages based on remaining count
    final customTitle = title ?? 'Select Images';
    final customMessage = message ?? 'You can select up to $remainingCount more image${remainingCount > 1 ? 's' : ''}';

    final result = await ImagePickerUtils.pickMultipleImages(
      context: context,
      title: customTitle,
      message: customMessage,
      maxImages: remainingCount,
    );

    return result.fold(
          (failure) => Left(failure),
          (newImages) {
        _selectedImages.addAll(newImages);
        return Right(newImages);
      },
    );
  }

  /// Remove an image from the selection
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
    }
  }

  /// Clear all selected images
  void clearAll() {
    _selectedImages.clear();
  }

  /// Check if more images can be added
  bool canAddMore() {
    return _selectedImages.length < maxImages;
  }
}


///
/// final picker = ProgressiveImagePicker(maxImages: 10);
///
/// // First selection
/// await picker.addMoreImages(context: context);
///
/// // Later, add more images
/// if (picker.canAddMore()) {
///   await picker.addMoreImages(context: context);
/// }
///
/// // Get the final selection
/// final allSelectedImages = picker.selectedImages;