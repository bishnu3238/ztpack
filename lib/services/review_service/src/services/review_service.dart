import 'package:pack/extensions/extensions.dart';
import 'package:pack/services/review_service/src/services/review_service.dart';
import 'dart:developer' as dev;
import '../models/review.dart';

/// Interface for review service implementations
abstract class ReviewService {
  /// Fetch reviews for a specific item
  ///
  /// [itemId] - ID of the item to get reviews for
  /// [page] - Page number for pagination (starts at 1)
  /// [limit] - Number of reviews per page
  /// [sortBy] - Field to sort by (e.g., 'createdAt', 'rating')
  /// [sortOrder] - Sort order ('asc' or 'desc')
  /// [minRating] - Minimum rating to filter by (1-5)
  /// [maxRating] - Maximum rating to filter by (1-5)
  Future<ReviewsResult> getReviews({required String itemId});

  /// Get a specific review by ID
  ///
  /// [reviewId] - ID of the review to fetch
  Future<Review?> getReviewById(String reviewId);

  /// Submit a new review
  ///
  /// [review] - Review data to submit
  /// [images] - Optional list of image files to upload
  Future<Review> submitReview(ReviewData review, List<dynamic>? images);

  /// Update an existing review
  ///
  /// [reviewId] - ID of the review to update
  /// [review] - Updated review data
  /// [images] - Optional list of image files to upload
  Future<Review> updateReview(
    String reviewId,
    ReviewData review,
    List<dynamic>? images,
  );

  /// Delete a review
  ///
  /// [reviewId] - ID of the review to delete
  Future<bool> deleteReview(String reviewId);

  /// Add a response to a review
  ///
  /// [reviewId] - ID of the review to respond to
  /// [response] - Response data
  Future<Review> respondToReview(String reviewId, ReviewResponseData response);

  /// Mark a review as helpful
  ///
  /// [reviewId] - ID of the review to mark as helpful
  /// [isHelpful] - Whether the review is helpful
  Future<bool> markReviewHelpful(String reviewId, bool isHelpful);

  /// Get the average rating for an item
  ///
  /// [itemId] - ID of the item to get the average rating for
  Future<RatingSummary> getItemRatingSummary(String itemId);

  /// Check if a user has already reviewed an item
  ///
  /// [itemId] - ID of the item
  /// [userId] - ID of the user
  Future<bool> hasUserReviewedItem(String itemId, String userId);
}

/// Data class for submitting a new review
class ReviewData {
  final String userId;
  final String userName;
  final String serviceName, serviceId;
  final String userImageUrl;
  final String itemId;
  final double rating;
  final String? title;
  final String content;
  final Map<String, dynamic>? metadata;

  const ReviewData({
    required this.userId,
    required this.userName,
    required this.serviceName,
    required this.serviceId,
    required this.userImageUrl,
    required this.itemId,
    required this.rating,
    this.title,
    required this.content,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'serviceName': serviceName,
      'serviceId': serviceId,
      'userImageUrl': userImageUrl,
      'itemId': itemId,
      'rating': rating,
      'title': title,
      'content': content,
      'metadata': metadata,
    };
  }
}

/// Data class for submitting a response to a review
class ReviewResponseData {
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String content;
  final bool isOfficial;

  const ReviewResponseData({
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.content,
    this.isOfficial = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'content': content,
      'isOfficial': isOfficial,
    };
  }
}

/// Result class for paginated reviews
class ReviewsResult {
  final List<Review> reviews;
  final int totalCount;
  final int page;
  final int limit;
  final int totalPages;

  const ReviewsResult({
    required this.reviews,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  static ReviewsResult empty() => ReviewsResult(
    reviews: [],
    totalCount: 0,
    page: 1,
    limit: 10,
    totalPages: 0,
  );

  factory ReviewsResult.fromJson(Map<String, dynamic> data) {
    dev.log(data.runtimeType.toString());
    final reviewsJson = data['data']['reviews'];
    dev.log(reviewsJson.runtimeType.toString());
    final reviews = reviewsJson.map<Review>((r) => Review.fromJson(r)).toList();
    final json = data['data']['pagination'] as Map<String, dynamic>;
    return ReviewsResult(
      reviews: reviews,
      totalCount: json.getInt('total'),
      page: json.getInt('page'),
      limit: json.getInt('limit'),
      totalPages: json.getInt('pages'),
    );
  }
}

/// Summary of ratings for an item
class RatingSummary {
  final String itemId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts;

  const RatingSummary({
    required this.itemId,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingCounts,
  });

  /// Get the percentage of reviews with a specific rating
  double getPercentageForRating(int rating) {
    if (totalReviews == 0) return 0;
    return (ratingCounts[rating] ?? 0) / totalReviews * 100;
  }

  /// Create a RatingSummary from JSON data
  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    final ratingCountsJson = json['ratingCounts'] as Map<String, dynamic>;
    final ratingCounts = ratingCountsJson.map(
      (key, value) => MapEntry(int.parse(key), value as int),
    );

    return RatingSummary(
      itemId: json['itemId'],
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'],
      ratingCounts: ratingCounts,
    );
  }

  /// Convert RatingSummary to JSON
  Map<String, dynamic> toJson() {
    final ratingCountsJson = ratingCounts.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    return {
      'itemId': itemId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingCounts': ratingCountsJson,
    };
  }
}
