import 'dart:developer' as dev;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/review_service.dart';
import 'rating_bar.dart';

/// A form for submitting or editing a review
class ReviewForm extends StatefulWidget {
  /// The ID of the item being reviewed
  final String itemId;

  /// The review service to use for submitting the review
  final ReviewService reviewService;

  /// The current user's ID
  final String userId;

  /// The current user's name
  final String userName;

  /// The current user's profile image URL (optional)
  final String userImageUrl;

  /// The existing review to edit (null for new reviews)
  final ReviewData? existingReview;

  /// Service Name
  final String serviceName;

  /// service Id
  final String serviceId;

  /// Callback when the review is submitted successfully
  final Function(bool isEdit)? onReviewSubmitted;

  /// Whether to allow image uploads
  final bool allowImageUploads;

  /// Maximum number of images that can be uploaded
  final int maxImages;

  /// Custom style for the form
  final ReviewFormStyle? style;

  const ReviewForm({
    super.key,
    required this.itemId,
    required this.reviewService,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.serviceName,
    required this.serviceId,
    this.existingReview,
    this.onReviewSubmitted,
    this.allowImageUploads = true,
    this.maxImages = 5,
    this.style,
  });

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  double _rating = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Pre-fill form if editing an existing review
    if (widget.existingReview != null) {
      _titleController.text = widget.existingReview!.title ?? '';
      _contentController.text = widget.existingReview!.content;
      _rating = widget.existingReview!.rating;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remainingSlots = widget.maxImages - _selectedImages.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum ${widget.maxImages} images allowed')),
      );
      return;
    }

    final pickedImages = await _imagePicker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        for (final image in pickedImages) {
          if (_selectedImages.length < widget.maxImages) {
            _selectedImages.add(File(image.path));
          } else {
            break;
          }
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      if (_rating == 0) {
        setState(() {
          _errorMessage = 'Please select a rating';
        });
        return;
      }

      setState(() {
        _isSubmitting = true;
        _errorMessage = null;
      });

      try {
        final reviewData = ReviewData(
          userId: widget.userId,
          userName: widget.userName,
          userImageUrl: widget.userImageUrl,
          serviceName: widget.serviceName,
          serviceId: widget.serviceId,
          itemId: widget.itemId,
          rating: _rating,
          title:
              _titleController.text.isNotEmpty ? _titleController.text : null,
          content: _contentController.text,
        );

        if (widget.existingReview != null) {
          // Update existing review
          await widget.reviewService.updateReview(
            widget.existingReview!.itemId,
            reviewData,
            _selectedImages.isNotEmpty ? _selectedImages : null,
          );
          widget.onReviewSubmitted?.call(true);
        } else {
          // Submit new review
          var review = await widget.reviewService.submitReview(
            reviewData,
            _selectedImages.isNotEmpty ? _selectedImages : null,
          );
          dev.log('helllo $review');
          widget.onReviewSubmitted?.call(false);
        }

        // Clear form after successful submission
        if (mounted) {
          _formKey.currentState!.reset();
          _titleController.clear();
          _contentController.clear();
          setState(() {
            _rating = 0;
            _selectedImages.clear();
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to submit review: $e';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formStyle = widget.style ?? ReviewFormStyle.fromTheme(theme);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form title
          Text(
            widget.existingReview != null
                ? 'Edit Your Review'
                : 'Write a Review',
            style: formStyle.titleStyle,
          ),

          const SizedBox(height: 16),

          // Rating selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rating', style: formStyle.labelStyle),
              const SizedBox(height: 8),
              RatingBarSelector(
                initialRating: _rating,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating;
                    _errorMessage = null;
                  });
                },
                size: 36,
                color: formStyle.ratingColor,
              ),
              if (_errorMessage != null && _rating == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Review title field (optional)
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title (optional)',
              hintText: 'Summarize your experience',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  formStyle.inputBorderRadius,
                ),
              ),
              filled: formStyle.filledInputs,
              fillColor: formStyle.inputFillColor,
            ),
            maxLength: 100,
          ),

          const SizedBox(height: 16),

          // Review content field
          TextFormField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: 'Review',
              hintText: 'Share your experience with this item',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  formStyle.inputBorderRadius,
                ),
              ),
              filled: formStyle.filledInputs,
              fillColor: formStyle.inputFillColor,
            ),
            maxLines: 5,
            maxLength: 1000,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your review';
              }
              if (value.trim().length < 5) {
                return 'Review must be at least 5 characters';
              }
              return null;
            },
          ),

          // Image upload section
          if (widget.allowImageUploads)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Text('Add Photos (optional)', style: formStyle.labelStyle),

                const SizedBox(height: 8),

                Text(
                  'You can add up to ${widget.maxImages} images',
                  style: formStyle.hintStyle,
                ),

                const SizedBox(height: 8),

                // Selected images preview
                if (_selectedImages.isNotEmpty)
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                // Add image button
                if (_selectedImages.length < widget.maxImages)
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Photos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: formStyle.buttonColor,
                      foregroundColor: formStyle.buttonTextColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          formStyle.buttonBorderRadius,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 24),

          // Error message
          if (_errorMessage != null && _rating > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 14),
              ),
            ),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: formStyle.submitButtonColor,
                foregroundColor: formStyle.submitButtonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    formStyle.buttonBorderRadius,
                  ),
                ),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Text(
                        widget.existingReview != null
                            ? 'Update Review'
                            : 'Submit Review',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Style configuration for the ReviewForm
class ReviewFormStyle {
  final TextStyle titleStyle;
  final TextStyle labelStyle;
  final TextStyle hintStyle;
  final Color ratingColor;
  final double inputBorderRadius;
  final bool filledInputs;
  final Color? inputFillColor;
  final double buttonBorderRadius;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color submitButtonColor;
  final Color submitButtonTextColor;

  const ReviewFormStyle({
    required this.titleStyle,
    required this.labelStyle,
    required this.hintStyle,
    required this.ratingColor,
    this.inputBorderRadius = 8.0,
    this.filledInputs = true,
    this.inputFillColor,
    this.buttonBorderRadius = 8.0,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.submitButtonColor,
    required this.submitButtonTextColor,
  });

  /// Create a ReviewFormStyle from the current theme
  factory ReviewFormStyle.fromTheme(ThemeData theme) {
    return ReviewFormStyle(
      titleStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.titleLarge?.color,
      ),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.titleMedium?.color,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        color: theme.textTheme.bodySmall?.color,
      ),
      ratingColor: Colors.amber,
      inputFillColor: theme.colorScheme.surface,
      buttonColor: theme.colorScheme.primary.withOpacity(0.1),
      buttonTextColor: theme.colorScheme.primary,
      submitButtonColor: theme.colorScheme.primary,
      submitButtonTextColor: theme.colorScheme.onPrimary,
    );
  }

  /// Create a copy of this style with the given fields replaced
  ReviewFormStyle copyWith({
    TextStyle? titleStyle,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    Color? ratingColor,
    double? inputBorderRadius,
    bool? filledInputs,
    Color? inputFillColor,
    double? buttonBorderRadius,
    Color? buttonColor,
    Color? buttonTextColor,
    Color? submitButtonColor,
    Color? submitButtonTextColor,
  }) {
    return ReviewFormStyle(
      titleStyle: titleStyle ?? this.titleStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      ratingColor: ratingColor ?? this.ratingColor,
      inputBorderRadius: inputBorderRadius ?? this.inputBorderRadius,
      filledInputs: filledInputs ?? this.filledInputs,
      inputFillColor: inputFillColor ?? this.inputFillColor,
      buttonBorderRadius: buttonBorderRadius ?? this.buttonBorderRadius,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      submitButtonColor: submitButtonColor ?? this.submitButtonColor,
      submitButtonTextColor:
          submitButtonTextColor ?? this.submitButtonTextColor,
    );
  }
}
