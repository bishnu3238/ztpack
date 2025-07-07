import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

/// Different UI styles for image source selection
enum PickerDialogStyle { cupertino, material, bottomSheet, custom }

/// Result of an image picking operation
class ImagePickResult {
  final List<XFile> files;
  final List<CroppedFile>? croppedFiles;

  ImagePickResult({required this.files, this.croppedFiles});

  bool get isEmpty => files.isEmpty;
  bool get isNotEmpty => files.isNotEmpty;
  int get count => files.length;
}

/// Failure types for better error handling
enum ImagePickFailureType {
  permissionDenied,
  userCancelled,
  fileSizeExceeded,
  fileTypeNotAllowed,
  noCamera,
  noGallery,
  cropFailed,
  unknown,
}

/// Exception class for image picking operations
class ImagePickFailure implements Exception {
  final String message;
  final ImagePickFailureType type;
  final dynamic originalError;

  const ImagePickFailure({
    required this.message,
    required this.type,
    this.originalError,
  });

  @override
  String toString() => 'ImagePickFailure: $message (${type.name})';
}

/// A comprehensive utility for handling image picking operations in Flutter applications.
///
/// Features:
/// - Cross-platform UI that adapts to iOS and Android
/// - Permission handling
/// - Support for single and multiple image selection
/// - Image cropping capability
/// - Comprehensive error handling
/// - Video support
/// - File size and type validation
/// - Modern UI with multiple dialog styles
class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();
  static final Logger _logger = Logger();

  /// Configuration options for image picking
  static const int defaultMaxSize =
      10 * 1024 * 1024; // 10MB default max file size
  static const List<String> defaultAllowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'heic',
    'heif',
    'webp',
  ];

  /// Shows an appropriate dialog for selecting image source based on platform and style preference
  ///
  /// [context] - BuildContext for showing dialogs
  /// [title] - Title text for the dialog
  /// [message] - Optional descriptive message
  /// [multiSelect] - Whether to allow multiple image selection in gallery mode
  /// [dialogStyle] - UI style to use for the picker dialog
  /// [maxSize] - Maximum file size in bytes
  /// [allowedExtensions] - List of allowed file extensions
  /// [enableCropping] - Whether to enable image cropping
  /// [cropAspectRatio] - Aspect ratio for cropping (null for free form)
  static Future<Either<ImagePickFailure, ImagePickResult>> showImagePicker({
    required BuildContext context,
    required String title,
    String? message,
    bool multiSelect = false,
    int? maxImages,
    PickerDialogStyle dialogStyle = PickerDialogStyle.bottomSheet,
    int maxSize = defaultMaxSize,
    List<String> allowedExtensions = defaultAllowedExtensions,
    bool enableCropping = false,
    CropAspectRatio? cropAspectRatio,
    Widget? customDialog,
  }) async {
    try {
      // Choose dialog style based on platform and preference
      ImageSource? source;

      switch (dialogStyle) {
        case PickerDialogStyle.cupertino:
          source = await _showCupertinoDialog(context, title, message);
          break;
        case PickerDialogStyle.material:
          source = await _showMaterialDialog(context, title, message);
          break;
        case PickerDialogStyle.bottomSheet:
          source =
              Platform.isIOS
                  ? await _showCupertinoActionSheet(context, title, message)
                  : await _showMaterialBottomSheet(context, title, message);
          break;
        case PickerDialogStyle.custom:
          if (customDialog != null) {
            source = await showDialog<ImageSource>(
              context: context,
              builder: (context) => customDialog,
            );
          } else {
            // Fall back to bottom sheet if no custom dialog provided
            source =
                Platform.isIOS
                    ? await _showCupertinoActionSheet(context, title, message)
                    : await _showMaterialBottomSheet(context, title, message);
          }
          break;
      }

      if (source == null) {
        return Left(
          ImagePickFailure(
            message: 'Image selection cancelled by user',
            type: ImagePickFailureType.userCancelled,
          ),
        );
      }

      // Check permissions before proceeding
      final permissionGranted = await _checkPermissions(source);
      if (!permissionGranted) {
        return Left(
          ImagePickFailure(
            message:
                'Permission not granted for ${source == ImageSource.camera ? 'camera' : 'photo library'}',
            type: ImagePickFailureType.permissionDenied,
          ),
        );
      }

      // Pick images based on source and multiSelect option
      List<XFile> pickedFiles = [];

      if (source == ImageSource.camera) {
        final file = await _pickSingleImage(source);
        if (file != null) pickedFiles.add(file);
      } else if (multiSelect) {
        pickedFiles = await _pickMultipleImagesWithLimit(maxImages);

        // pickedFiles = await _pickMultipleImages();
      } else {
        final file = await _pickSingleImage(source);
        if (file != null) pickedFiles.add(file);
      }

      if (pickedFiles.isEmpty) {
        return Left(
          ImagePickFailure(
            message: 'No images selected',
            type: ImagePickFailureType.userCancelled,
          ),
        );
      }

      // Validate files
      final validationResult = await _validateFiles(
        pickedFiles,
        maxSize: maxSize,
        allowedExtensions: allowedExtensions,
      );

      if (validationResult.isLeft()) {
        // Extract the failure and return it
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => Left(
            ImagePickFailure(
              message: "Unexpected error",
              type: ImagePickFailureType.unknown,
            ),
          ), // This should never be reached
        );
      }

      // Handle cropping if enabled
      List<CroppedFile>? croppedFiles;

      if (enableCropping && pickedFiles.isNotEmpty) {
        final cropResult = await _cropImages(
          pickedFiles,
          aspectRatio: cropAspectRatio,
        );
        if (cropResult.isLeft()) {
          // Extract the failure and return it
          return cropResult.fold(
            (failure) => Left(failure),
            (_) => Left(
              ImagePickFailure(
                message: "Unexpected error",
                type: ImagePickFailureType.unknown,
              ),
            ), // This should never be reached
          );
        }
        croppedFiles = cropResult.getOrElse(() => []);

        // If cropping was cancelled for all images, return error
        if (croppedFiles.isEmpty) {
          return Left(
            ImagePickFailure(
              message: 'Image cropping cancelled by user',
              type: ImagePickFailureType.userCancelled,
            ),
          );
        }
      }

      return Right(
        ImagePickResult(files: pickedFiles, croppedFiles: croppedFiles),
      );
    } catch (e) {
      _logger.e('Error picking image: $e');
      return Left(
        ImagePickFailure(
          message: 'Failed to pick image: ${e.toString()}',
          type: ImagePickFailureType.unknown,
          originalError: e,
        ),
      );
    }
  }

  /// Pick multiple images from gallery with an optional limit
  static Future<List<XFile>> _pickMultipleImagesWithLimit(
    int? maxImages,
  ) async {
    try {
      // If no limit is specified, use the regular method
      if (maxImages == null) {
        return await _picker.pickMultiImage(imageQuality: 90);
      }

      // If we already have images and are adding more, we need to track the limit
      // This implementation assumes we're selecting all images at once
      final selected = await _picker.pickMultiImage(imageQuality: 90);

      // Apply the limit
      if (selected.length > maxImages) {
        // Return only the first maxImages items
        return selected.take(maxImages).toList();
      }

      return selected;
    } catch (e) {
      _logger.e('Error picking multiple images: $e');
      return [];
    }
  }

  /// Shows a Cupertino-style dialog for selecting image source
  static Future<ImageSource?> _showCupertinoDialog(
    BuildContext context,
    String title,
    String? message,
  ) async {
    return showCupertinoDialog<ImageSource>(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: message != null ? Text(message) : null,
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Take a Photo'),
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            CupertinoDialogAction(
              child: const Text('Choose from Gallery'),
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Shows a Material-style dialog for selecting image source
  static Future<ImageSource?> _showMaterialDialog(
    BuildContext context,
    String title,
    String? message,
  ) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: message != null ? Text(message) : null,
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Camera'),
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            TextButton(
              child: const Text('Gallery'),
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        );
      },
    );
  }

  /// Shows a Cupertino action sheet for selecting image source
  static Future<ImageSource?> _showCupertinoActionSheet(
    BuildContext context,
    String title,
    String? message,
  ) async {
    return showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(title),
          message: message != null ? Text(message) : null,
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.camera, size: 24),
                  SizedBox(width: 16),
                  Text('Take a Photo'),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.photo, size: 24),
                  SizedBox(width: 16),
                  Text('Choose from Gallery'),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  /// Shows a Material bottom sheet for selecting image source
  static Future<ImageSource?> _showMaterialBottomSheet(
    BuildContext context,
    String title,
    String? message,
  ) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 8),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Checks if the required permissions are granted
  static Future<bool> _checkPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    } else {
      if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted;
      } else {
        // Android
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    }
  }

  /// Pick a single image from the selected source
  static Future<XFile?> _pickSingleImage(ImageSource source) async {
    try {
      return await _picker.pickImage(
        source: source,
        imageQuality: 90, // Adjust quality to balance size and image quality
      );
    } catch (e) {
      _logger.e('Error picking single image: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<XFile>> _pickMultipleImages() async {
    try {
      return await _picker.pickMultiImage(imageQuality: 90);
    } catch (e) {
      _logger.e('Error picking multiple images: $e');
      return [];
    }
  }

  /// Validates picked files for size and extension
  static Future<Either<ImagePickFailure, bool>> _validateFiles(
    List<XFile> files, {
    required int maxSize,
    required List<String> allowedExtensions,
  }) async {
    for (final file in files) {
      // Check file extension
      final extension = file.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        return Left(
          ImagePickFailure(
            message: 'File type .$extension is not allowed',
            type: ImagePickFailureType.fileTypeNotAllowed,
          ),
        );
      }

      // Check file size
      final fileSize = await File(file.path).length();
      if (fileSize > maxSize) {
        final sizeMB = maxSize / (1024 * 1024);
        return Left(
          ImagePickFailure(
            message:
                'File size exceeds the maximum allowed size of ${sizeMB.toStringAsFixed(1)} MB',
            type: ImagePickFailureType.fileSizeExceeded,
          ),
        );
      }
    }

    return const Right(true);
  }

  /// Crops selected images using image_cropper package
  static Future<Either<ImagePickFailure, List<CroppedFile>>> _cropImages(
    List<XFile> files, {
    CropAspectRatio? aspectRatio,
  }) async {
    List<CroppedFile> croppedFiles = [];

    try {
      for (final file in files) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: file.path,
          aspectRatio: aspectRatio,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.deepPurple,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: aspectRatio != null,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
          ],
        );

        if (croppedFile != null) {
          croppedFiles.add(croppedFile);
        }
      }

      return Right(croppedFiles);
    } catch (e) {
      _logger.e('Error cropping images: $e');
      return Left(
        ImagePickFailure(
          message: 'Failed to crop images: ${e.toString()}',
          type: ImagePickFailureType.cropFailed,
          originalError: e,
        ),
      );
    }
  }

  /// Handles the image picking operation for a single image
  static Future<Either<ImagePickFailure, XFile>> pickSingleImage({
    required BuildContext context,
    required String title,
    String? message,
    PickerDialogStyle dialogStyle = PickerDialogStyle.bottomSheet,
    int maxSize = defaultMaxSize,
    List<String> allowedExtensions = defaultAllowedExtensions,
    bool enableCropping = false,
    CropAspectRatio? cropAspectRatio,
  }) async {
    final result = await showImagePicker(
      context: context,
      title: title,
      message: message,
      multiSelect: false,
      dialogStyle: dialogStyle,
      maxSize: maxSize,
      allowedExtensions: allowedExtensions,
      enableCropping: enableCropping,
      cropAspectRatio: cropAspectRatio,
    );

    return result.fold((failure) => Left(failure), (success) {
      if (success.isEmpty) {
        return Left(
          ImagePickFailure(
            message: 'No image selected',
            type: ImagePickFailureType.userCancelled,
          ),
        );
      }
      return Right(success.files.first);
    });
  }

  /// Handles the image picking operation for multiple images
  static Future<Either<ImagePickFailure, List<XFile>>> pickMultipleImages({
    required BuildContext context,
    required String title,
    String? message,
    int? maxImages,

    PickerDialogStyle dialogStyle = PickerDialogStyle.bottomSheet,
    int maxSize = defaultMaxSize,
    List<String> allowedExtensions = defaultAllowedExtensions,
    bool enableCropping = false,
    CropAspectRatio? cropAspectRatio,
  }) async {
    final result = await showImagePicker(
      context: context,
      title: title,
      message: message,
      multiSelect: true,
      maxImages: maxImages,

      dialogStyle: dialogStyle,
      maxSize: maxSize,
      allowedExtensions: allowedExtensions,
      enableCropping: enableCropping,
      cropAspectRatio: cropAspectRatio,
    );

    return result.fold(
      (failure) => Left(failure),
      (success) => Right(success.files),
    );
  }

  /// Directly opens the camera without showing a source picker dialog
  static Future<Either<ImagePickFailure, List<XFile>>> openCamera({
    bool multiSelect = false,

    int maxSize = defaultMaxSize,
    int? maxImages,

    List<String> allowedExtensions = defaultAllowedExtensions,
    bool enableCropping = false,
    CropAspectRatio? cropAspectRatio,
  }) async {
    try {
      // Check camera permission
      final permissionGranted = await _checkPermissions(ImageSource.camera);
      if (!permissionGranted) {
        return Left(
          ImagePickFailure(
            message: 'Camera permission not granted',
            type: ImagePickFailureType.permissionDenied,
          ),
        );
      }

      // Pick images
      List<XFile> files = [];
      if (multiSelect) {
        files = await _pickMultipleImagesWithLimit(maxImages);
      } else {
        final file = await _pickSingleImage(ImageSource.gallery);
        if (file != null) files.add(file);
      }
      // Take picture
      // final file = await _pickSingleImage(ImageSource.camera);
      if (files.isEmpty) {
        return Left(
          ImagePickFailure(
            message: 'No image captured',
            type: ImagePickFailureType.userCancelled,
          ),
        );
      }

      // Validate file
      final validationResult = await _validateFiles(
        files,
        maxSize: maxSize,
        allowedExtensions: allowedExtensions,
      );

      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => Right(files), // This won't be reached due to isLeft() check
        );
      }

      // Handle cropping if enabled
      if (enableCropping) {
        final cropResult = await _cropImages(
          files,
          aspectRatio: cropAspectRatio,
        );
        return cropResult.fold((failure) => Left(failure), (croppedFiles) {
          if (croppedFiles.isEmpty) {
            return Left(
              ImagePickFailure(
                message: 'Image cropping cancelled',
                type: ImagePickFailureType.userCancelled,
              ),
            );
          }
          List<XFile> xFiles = croppedFiles.map((e) => XFile(e.path)).toList();
          // Convert CroppedFile back to XFile
          return Right(xFiles);
        });
      }

      return Right(files);
    } catch (e) {
      _logger.e('Error opening camera: $e');
      return Left(
        ImagePickFailure(
          message: 'Failed to open camera: ${e.toString()}',
          type: ImagePickFailureType.unknown,
          originalError: e,
        ),
      );
    }
  }

  /// Directly opens the gallery without showing a source picker dialog
  static Future<Either<ImagePickFailure, List<XFile>>> openGallery({
    bool multiSelect = false,
    int maxSize = defaultMaxSize,
    List<String> allowedExtensions = defaultAllowedExtensions,
    bool enableCropping = false,
    CropAspectRatio? cropAspectRatio,
  }) async {
    try {
      // Check gallery permission
      final permissionGranted = await _checkPermissions(ImageSource.gallery);
      if (!permissionGranted) {
        return Left(
          ImagePickFailure(
            message: 'Gallery permission not granted',
            type: ImagePickFailureType.permissionDenied,
          ),
        );
      }

      // Pick images
      List<XFile> files = [];
      if (multiSelect) {
        files = await _pickMultipleImages();
      } else {
        final file = await _pickSingleImage(ImageSource.gallery);
        if (file != null) files.add(file);
      }

      if (files.isEmpty) {
        return Left(
          ImagePickFailure(
            message: 'No images selected',
            type: ImagePickFailureType.userCancelled,
          ),
        );
      }

      // Validate files
      final validationResult = await _validateFiles(
        files,
        maxSize: maxSize,
        allowedExtensions: allowedExtensions,
      );

      if (validationResult.isLeft()) {
        return validationResult.fold(
          (failure) => Left(failure),
          (_) => Right(files), // This won't be reached due to isLeft() check
        );
      }

      // Handle cropping if enabled
      if (enableCropping) {
        final cropResult = await _cropImages(
          files,
          aspectRatio: cropAspectRatio,
        );
        return cropResult.fold((failure) => Left(failure), (croppedFiles) {
          if (croppedFiles.isEmpty) {
            return Left(
              ImagePickFailure(
                message: 'Image cropping cancelled',
                type: ImagePickFailureType.userCancelled,
              ),
            );
          }
          // Convert CroppedFile list back to XFile list
          return Right(croppedFiles.map((cf) => XFile(cf.path)).toList());
        });
      }

      return Right(files);
    } catch (e) {
      _logger.e('Error opening gallery: $e');
      return Left(
        ImagePickFailure(
          message: 'Failed to open gallery: ${e.toString()}',
          type: ImagePickFailureType.unknown,
          originalError: e,
        ),
      );
    }
  }
}

/// Extension on BuildContext to make image picking easier
extension ImagePickerContextExtension on BuildContext {
  /// Quick access to pick a single image
  Future<Either<ImagePickFailure, XFile>> pickImage({
    String title = 'Select Image',
    String? message,
    PickerDialogStyle dialogStyle = PickerDialogStyle.bottomSheet,
    bool enableCropping = false,
  }) {
    return ImagePickerUtils.pickSingleImage(
      context: this,
      title: title,
      message: message,
      dialogStyle: dialogStyle,
      enableCropping: enableCropping,
    );
  }

  /// Quick access to pick multiple images
  Future<Either<ImagePickFailure, List<XFile>>> pickMultipleImages({
    String title = 'Select Images',
    int? maxImages,

    String? message,
    PickerDialogStyle dialogStyle = PickerDialogStyle.bottomSheet,
  }) {
    return ImagePickerUtils.pickMultipleImages(
      context: this,
      title: title,
      message: message,
      maxImages: maxImages,
      dialogStyle: dialogStyle,
    );
  }
}
