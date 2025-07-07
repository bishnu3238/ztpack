import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import 'rating_summary.dart';
import 'review_card.dart';
import 'review_list.dart';
import 'review_form.dart';

/// Main widget that combines all review components into a complete system
class ReviewSystem extends StatefulWidget {
  /// The ID of the item being reviewed
  final String itemId;

  /// The review service to use
  final ReviewService reviewService;

  ///
  final String serviceName;

  ///
  final String serviceId;

  /// The current user's ID (required for submitting reviews)
  final String? currentUserId;

  /// The current user's name (required for submitting reviews)
  final String? currentUserName;

  /// The current user's profile image URL (optional)
  final String currentUserImageUrl;

  /// Whether the current user is an admin (can respond to reviews)
  final bool isAdmin;

  /// Whether to show the review form
  final bool showReviewForm;

  /// Whether to allow image uploads in reviews
  final bool allowImageUploads;

  /// Maximum number of images per review
  final int maxImagesPerReview;

  /// Number of reviews to show per page
  final int reviewsPerPage;

  /// Whether to show the rating summary
  final bool showRatingSummary;

  /// Whether to show filter options
  final bool showFilters;

  /// Whether to show sort options
  final bool showSorting;

  /// Whether to show the helpful button on reviews
  final bool showHelpfulButton;

  /// Whether to show the report button on reviews
  final bool showReportButton;

  /// Whether to show the respond button on reviews (for admins)
  final bool showRespondButton;

  /// Custom style for the review form
  final ReviewFormStyle? reviewFormStyle;

  /// Custom style for the review cards
  final ReviewCardStyle? reviewCardStyle;

  /// Custom style for the rating summary
  final RatingSummaryStyle? ratingSummaryStyle;

  /// Custom empty state widget when there are no reviews
  final Widget? emptyStateWidget;

  /// Custom error widget when there's an error loading reviews
  final Widget Function(String error)? errorWidget;

  /// Callback when a review is submitted
  final Function(Review review)? onReviewSubmitted;

  /// Callback when a review is updated
  final Function(Review review)? onReviewUpdated;

  /// Callback when a review is deleted
  final Function(String reviewId)? onReviewDeleted;

  /// Callback when a response is added to a review
  final Function(Review review, ReviewResponse response)? onResponseAdded;

  const ReviewSystem({
    super.key,
    required this.itemId,
    required this.reviewService,
    this.currentUserId,
    this.currentUserName,
    required this.currentUserImageUrl,
    required this.serviceName,
    required this.serviceId,
    this.isAdmin = false,
    this.showReviewForm = true,
    this.allowImageUploads = true,
    this.maxImagesPerReview = 5,
    this.reviewsPerPage = 10,
    this.showRatingSummary = true,
    this.showFilters = true,
    this.showSorting = true,
    this.showHelpfulButton = true,
    this.showReportButton = true,
    this.showRespondButton = false,
    this.reviewFormStyle,
    this.reviewCardStyle,
    this.ratingSummaryStyle,
    this.emptyStateWidget,
    this.errorWidget,
    this.onReviewSubmitted,
    this.onReviewUpdated,
    this.onReviewDeleted,
    this.onResponseAdded,
  });

  @override
  State<ReviewSystem> createState() => _ReviewSystemState();
}

class _ReviewSystemState extends State<ReviewSystem>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Review? _reviewToEdit;
  Review? _reviewToRespond;
  bool _userHasReviewed = false;
  bool _isCheckingUserReview = false;

  final _responseController = TextEditingController();
  bool _isSubmittingResponse = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Check if user has already reviewed this item
    _checkUserReview();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  Future<void> _checkUserReview() async {
    if (widget.currentUserId != null) {
      setState(() {
        _isCheckingUserReview = true;
      });

      try {
        final hasReviewed = await widget.reviewService.hasUserReviewedItem(
          widget.itemId,
          widget.currentUserId!,
        );

        dev.log("hasReviewed: Function Result : $hasReviewed");

        setState(() {
          _userHasReviewed = hasReviewed;
          _isCheckingUserReview = false;
        });
      } catch (e) {
        print('Error checking if user has reviewed: $e');
        setState(() {
          _isCheckingUserReview = false;
        });
      }
    }
  }

  void _handleReviewSubmitted(bool isEdit) {
    // Reset state and refresh
    setState(() {
      _reviewToEdit = null;
      _userHasReviewed = true;
    });

    // Switch to reviews tab
    _tabController.animateTo(0);
  }

  void _handleEditReview(Review review) {
    setState(() {
      _reviewToEdit = review;
    });

    // Switch to write tab
    _tabController.animateTo(1);
  }

  void _handleRespondToReview(Review review) {
    setState(() {
      _reviewToRespond = review;
    });

    // Show response dialog
    _showResponseDialog(review);
  }

  void _showResponseDialog(Review review) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Respond to ${review.userName}\'s Review'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _responseController,
                  decoration: const InputDecoration(
                    labelText: 'Your response',
                    hintText: 'Write your response here...',
                  ),
                  maxLines: 5,
                ),
                if (_isSubmittingResponse)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _responseController.clear();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    _isSubmittingResponse
                        ? null
                        : () => _submitResponse(review),
                child: const Text('Submit Response'),
              ),
            ],
          ),
    );
  }

  Future<void> _submitResponse(Review review) async {
    final responseText = _responseController.text.trim();
    if (responseText.isEmpty) {
      return;
    }

    setState(() {
      _isSubmittingResponse = true;
    });

    try {
      final responseData = ReviewResponseData(
        userId: widget.currentUserId!,
        userName: widget.currentUserName!,
        userImageUrl: widget.currentUserImageUrl,
        content: responseText,
        isOfficial: widget.isAdmin,
      );

      final updatedReview = await widget.reviewService.respondToReview(
        review.id,
        responseData,
      );

      // Find the new response
      final newResponse = updatedReview.responses.last;

      // Call callback if provided
      widget.onResponseAdded?.call(updatedReview, newResponse);

      // Close dialog and reset
      if (mounted) {
        Navigator.of(context).pop();
        _responseController.clear();
        setState(() {
          _reviewToRespond = null;
          _isSubmittingResponse = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit response: $e')),
        );
        setState(() {
          _isSubmittingResponse = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if user can submit a review
    final canSubmitReview =
        widget.currentUserId != null &&
        widget.currentUserName != null &&
        (!_userHasReviewed || _reviewToEdit != null);

    return Column(
      mainAxisSize: MainAxisSize.min,

      children: [
        // Tab bar
        TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Reviews'),
            Tab(text: _reviewToEdit != null ? 'Edit Review' : 'Write a Review'),
          ],
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Reviews tab
              ReviewList(
                itemId: widget.itemId,
                reviewService: widget.reviewService,
                pageSize: widget.reviewsPerPage,
                showRatingSummary: widget.showRatingSummary,
                showFilters: widget.showFilters,
                showSorting: widget.showSorting,
                showHelpfulButton: widget.showHelpfulButton,
                showReportButton: widget.showReportButton,
                showRespondButton: widget.showRespondButton || widget.isAdmin,
                onRespondToReview:
                    (widget.currentUserId != null &&
                            widget.currentUserName != null)
                        ? _handleRespondToReview
                        : null,
                onMarkHelpful: (review, isHelpful) {
                  // Handle marking review as helpful
                },
                onReportReview: (review) {
                  // Handle reporting review
                },
                reviewCardStyle: widget.reviewCardStyle,
                ratingSummaryStyle: widget.ratingSummaryStyle,
                emptyStateWidget: widget.emptyStateWidget,
                errorWidget: widget.errorWidget,
                currentUserId: widget.currentUserId,
                isAdmin: widget.isAdmin,
              ),

              // Write/Edit review tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child:
                    _isCheckingUserReview
                        ? const Center(child: CircularProgressIndicator())
                        : canSubmitReview
                        ? ReviewForm(
                          itemId: widget.itemId,
                          reviewService: widget.reviewService,
                          userId: widget.currentUserId!,
                          userName: widget.currentUserName!,
                          serviceName: widget.serviceName,
                          serviceId: widget.serviceId,
                          userImageUrl: widget.currentUserImageUrl,
                          existingReview:
                              _reviewToEdit != null
                                  ? ReviewData(
                                    userId: _reviewToEdit!.userId,
                                    userName: _reviewToEdit!.userName,
                                    serviceId: '',
                                    serviceName: '',
                                    userImageUrl: _reviewToEdit!.userImageUrl,
                                    itemId: _reviewToEdit!.itemId,
                                    rating: _reviewToEdit!.rating,
                                    title: _reviewToEdit!.title,
                                    content: _reviewToEdit!.content,
                                  )
                                  : null,
                          onReviewSubmitted: _handleReviewSubmitted,
                          allowImageUploads: widget.allowImageUploads,
                          maxImages: widget.maxImagesPerReview,
                          style: widget.reviewFormStyle,
                        )
                        : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                widget.currentUserId == null
                                    ? 'Please sign in to write a review'
                                    : 'You have already reviewed this item',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_userHasReviewed)
                                TextButton(
                                  onPressed: () {
                                    // Find user's review to edit
                                    // This would typically be done by fetching the user's review
                                  },
                                  child: const Text('Edit your review'),
                                ),
                            ],
                          ),
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
