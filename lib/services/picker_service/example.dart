import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'src/image_picker.dart';
import 'package:image_picker/image_picker.dart';
/// Usage example widget
class ImagePickerExample extends StatefulWidget {
  const ImagePickerExample({Key? key}) : super(key: key);

  @override
  State<ImagePickerExample> createState() => _ImagePickerExampleState();
}

class _ImagePickerExampleState extends State<ImagePickerExample> {
  XFile? _selectedImage;
  List<XFile>? _selectedImages;
  String? _errorMessage;

  Future<void> _pickSingleImage() async {
    final result = await ImagePickerUtils.pickSingleImage(
      context: context,
      title: 'Select Profile Picture',
      message: 'Choose an image from your gallery or take a new photo',
      enableCropping: true,
      cropAspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    result.fold(
          (failure) {
        setState(() {
          _errorMessage = failure.message;
          _selectedImage = null;
        });
      },
          (image) {
        setState(() {
          _selectedImage = image;
          _errorMessage = null;
        });
      },
    );
  }

  Future<void> _pickMultipleImages() async {
    final result = await ImagePickerUtils.pickMultipleImages(
      context: context,
      title: 'Select Gallery Images',
      message: 'Choose multiple images for your gallery',
    );

    result.fold(
          (failure) {
        setState(() {
          _errorMessage = failure.message;
          _selectedImages = null;
        });
      },
          (images) {
        setState(() {
          _selectedImages = images;
          _errorMessage = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Picker Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_errorMessage != null)
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _pickSingleImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Select Single Image'),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _pickMultipleImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Select Multiple Images'),
            ),

            const SizedBox(height: 24),

            if (_selectedImage != null) ...[
              const Text(
                'Selected Image:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(_selectedImage!.path),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            if (_selectedImages != null && _selectedImages!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Selected Images (${_selectedImages!.length}):',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages!.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImages![index].path),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
