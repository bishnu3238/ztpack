import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import 'review_card.dart';
import 'rating_summary.dart';

/// A widget that displays a list of reviews with filtering and sorting options
class ReviewList extends StatefulWidget {
  /// The ID of the item to show reviews for
  final String itemId;

  /// The review service to use for fetching reviews
  final ReviewService reviewService;

  /// The number of reviews to show per page
  final int pageSize;

  /// Whether to show the rating summary at the top
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

  /// Callback when a user wants to respond to a review
  final Function(Review review)? onRespondToReview;

  /// Callback when a user marks a review as helpful
  final Function(Review review, bool isHelpful)? onMarkHelpful;

  /// Callback when a user reports a review
  final Function(Review review)? onReportReview;

  /// Custom style for the review cards
  final ReviewCardStyle? reviewCardStyle;

  /// Custom style for the rating summary
  final RatingSummaryStyle? ratingSummaryStyle;

  /// Custom empty state widget when there are no reviews
  final Widget? emptyStateWidget;

  /// Custom error widget when there's an error loading reviews
  final Widget Function(String error)? errorWidget;

  /// Current user ID (to check if they can respond to reviews)
  final String? currentUserId;

  /// Whether the current user is an admin (can respond to any review)
  final bool isAdmin;

  const ReviewList({
    super.key,
    required this.itemId,
    required this.reviewService,
    this.pageSize = 10,
    this.showRatingSummary = true,
    this.showFilters = true,
    this.showSorting = true,
    this.showHelpfulButton = true,
    this.showReportButton = true,
    this.showRespondButton = false,
    this.onRespondToReview,
    this.onMarkHelpful,
    this.onReportReview,
    this.reviewCardStyle,
    this.ratingSummaryStyle,
    this.emptyStateWidget,
    this.errorWidget,
    this.currentUserId,
    this.isAdmin = false,
  });

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  late int _currentPage;
  late String _sortBy;
  late String _sortOrder;
  int? _filterRating;

  bool _isLoading = false;
  String? _error;

  ReviewsResult? _reviewsResult;
  RatingSummary? _ratingSummary;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    _sortBy = 'createdAt';
    _sortOrder = 'desc';

    _loadReviews();
    if (widget.showRatingSummary) {
      _loadRatingSummary();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadReviews() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await widget.reviewService.getReviews(
        itemId: widget.itemId,

      );

      setState(() {
        _reviewsResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRatingSummary() async {
    try {
      final summary = await widget.reviewService.getItemRatingSummary(
        widget.itemId,
      );

      setState(() {
        _ratingSummary = summary;
      });
    } catch (e) {
      // Just log the error, don't show it to the user
      print('Failed to load rating summary: $e');
    }
  }

  Future<void> _refreshReviews() async {
    _currentPage = 1;
    await _loadReviews();
    if (widget.showRatingSummary) {
      await _loadRatingSummary();
    }
  }

  void _loadNextPage() {
    if (_reviewsResult != null && _currentPage < _reviewsResult!.totalPages) {
      _currentPage++;
      _loadReviews();
    }
  }

  void _applyFilter(int? rating) {
    setState(() {
      _filterRating = rating;
      _currentPage = 1;
    });
    _loadReviews();
  }

  void _applySorting(String sortBy, String sortOrder) {
    setState(() {
      _sortBy = sortBy;
      _sortOrder = sortOrder;
      _currentPage = 1;
    });
    _loadReviews();
  }

  Future<void> _handleMarkHelpful(Review review, bool isHelpful) async {
    try {
      await widget.reviewService.markReviewHelpful(review.id, isHelpful);
      widget.onMarkHelpful?.call(review, isHelpful);

      // Refresh the current page to show the updated helpful count
      _loadReviews();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark review as helpful: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshReviews,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rating summary
          if (widget.showRatingSummary && _ratingSummary != null)
            RatingSummaryWidget(
              summary: _ratingSummary!,
              style: widget.ratingSummaryStyle,
              onRatingFilterSelected: widget.showFilters ? _applyFilter : null,
            ),

          // Filter and sort options
          if (widget.showFilters || widget.showSorting)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  // Filter dropdown
                  if (widget.showFilters)
                    Expanded(child: _buildFilterDropdown()),

                  // Sort dropdown
                  if (widget.showSorting) Expanded(child: _buildSortDropdown()),
                ],
              ),
            ),

          // Reviews list
          Expanded(child: _buildReviewsList()),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<int?>(
      value: _filterRating,
      hint: const Text('Filter by rating'),
      isExpanded: true,
      underline: Container(height: 1, color: Colors.grey.shade300),
      onChanged: (value) {
        _applyFilter(value);
      },
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('All ratings')),
        ...List.generate(5, (index) {
          final rating = 5 - index;
          return DropdownMenuItem<int?>(
            value: rating,
            child: Row(
              children: [
                Text('$rating'),
                const SizedBox(width: 4),
                Icon(Icons.star, size: 16, color: Colors.amber),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: '$_sortBy:$_sortOrder',
      hint: const Text('Sort by'),
      isExpanded: true,
      underline: Container(height: 1, color: Colors.grey.shade300),
      onChanged: (value) {
        if (value != null) {
          final parts = value.split(':');
          if (parts.length == 2) {
            _applySorting(parts[0], parts[1]);
          }
        }
      },
      items: [
        DropdownMenuItem<String>(
          value: 'createdAt:desc',
          child: Text('Newest first'),
        ),
        DropdownMenuItem<String>(
          value: 'createdAt:asc',
          child: Text('Oldest first'),
        ),
        DropdownMenuItem<String>(
          value: 'rating:desc',
          child: Text('Highest rating'),
        ),
        DropdownMenuItem<String>(
          value: 'rating:asc',
          child: Text('Lowest rating'),
        ),
        DropdownMenuItem<String>(
          value: 'helpfulCount:desc',
          child: Text('Most helpful'),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    if (_error != null) {
      return widget.errorWidget != null
          ? widget.errorWidget!(_error!)
          : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading reviews: $_error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshReviews,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
    }

    if (_reviewsResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviewsResult!.reviews.isEmpty) {
      return widget.emptyStateWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.rate_review_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No reviews yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Be the first to review this item!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
            _reviewsResult != null &&
            _currentPage < _reviewsResult!.totalPages) {
          _loadNextPage();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount:
            _reviewsResult!.reviews.length +
            (_currentPage < _reviewsResult!.totalPages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _reviewsResult!.reviews.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final review = _reviewsResult!.reviews[index];

          // Determine if the current user can respond to this review
          final canRespond =
              widget.showRespondButton &&
              (widget.isAdmin ||
                  (widget.currentUserId != null &&
                      review.userId != widget.currentUserId));

          return ReviewCard(
            review: review,
            style: widget.reviewCardStyle,
            showHelpfulButton: widget.showHelpfulButton,
            showReportButton: widget.showReportButton,
            showRespondButton: canRespond,
            onHelpfulPressed:
                widget.onMarkHelpful != null
                    ? (isHelpful) => _handleMarkHelpful(review, isHelpful)
                    : null,
            onReportPressed:
                widget.onReportReview != null
                    ? () => widget.onReportReview!(review)
                    : null,
            onRespondPressed:
                widget.onRespondToReview != null && canRespond
                    ? () => widget.onRespondToReview!(review)
                    : null,
          );
        },
      ),
    );
  }
}
