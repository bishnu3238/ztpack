import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';
import '../../../service.dart';
import '../models/review.dart';
import 'review_service.dart';

/// HTTP implementation of the ReviewService for custom API backends
class HttpReviewService implements ReviewService {
  /// Base URL of the API
  final String baseUrl;

  /// Authentication token for API requests (optional)
  final String? authToken;

  /// HTTP client for making requests
  final http.Client _client;

  /// API call service for custom API calls (optional)
  final ApiCallService _apiService;

  /// UUID generator for client-side IDs
  final Uuid _uuid = const Uuid();

  /// Create a new HttpReviewService
  ///
  /// [baseUrl] - Base URL of the API (e.g., 'https://api.example.com/v1')
  /// [authToken] - Authentication token for API requests (optional)
  /// [client] - HTTP client for making requests (optional)
  HttpReviewService({
    required this.baseUrl,
    ApiCallService? apiService,
    this.authToken,
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _apiService = apiService ?? ApiCallService(baseUrl: baseUrl);

  /// Get the headers for API requests
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  @override
  Future<ReviewsResult> getReviews({
    required String itemId,
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    int? minRating,
    int? maxRating,
  }) async {
    try {
      // Build query parameters
      final queryParams = {
        'itemId': itemId,
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };
      dev.log(":REVIEWS: $queryParams");
      if (minRating != null) {
        queryParams['minRating'] = minRating.toString();
      }

      if (maxRating != null) {
        queryParams['maxRating'] = maxRating.toString();
      }
      final endPoint =
          '/merchant/merchant_reviews.php/api/reviews?merchant_id=$itemId';
      final config = RequestConfig(
        baseUrl: baseUrl,
        endpoint: endPoint,
        method: RequestMethod.get,
      );
      _apiService.request(
        config: config,
        responseConverter: (data) {
          dev.log("REVIEW DATA:  $data");
        },
      );

      // Make API request
      final uri = Uri.parse(
        '$baseUrl/reviews',
      ).replace(queryParameters: queryParams);
      final response = await _client.get(uri, headers: _headers);

      // Handle response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Parse reviews
        final reviews =
            (data['reviews'] as List)
                .map((reviewJson) => Review.fromJson(reviewJson))
                .toList();

        return ReviewsResult(
          reviews: reviews,
          totalCount: data['totalCount'],
          page: data['page'],
          limit: data['limit'],
          totalPages: data['totalPages'],
        );
      } else {
        throw Exception(
          'Failed to get reviews: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to get reviews: $e');
    }
  }

  @override

  Future<Review?> getReviewById(String reviewId) async {
    try {
      // Make API request
      final uri = Uri.parse('$baseUrl/reviews/$reviewId');
      final response = await _client.get(uri, headers: _headers);

      // Handle response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Review.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to get review: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to get review: $e');
    }
  }

  @override
  Future<Review> submitReview(ReviewData review, List<dynamic>? images) async {
    try {
      // Check if user has already reviewed this item
      final hasReviewed = await hasUserReviewedItem(
        review.itemId,
        review.userId,
      );
      if (hasReviewed) {
        throw Exception('User has already reviewed this item');
      }

      // Prepare review data
      final reviewId = _uuid.v4();
      final now = DateTime.now();

      final reviewData = {
        'id': reviewId,
        'userId': review.userId,
        'userName': review.userName,
        'userImageUrl': review.userImageUrl,
        'itemId': review.itemId,
        'rating': review.rating,
        'title': review.title,
        'content': review.content,
        'createdAt': now.toIso8601String(),
        'metadata': review.metadata,
      };

      // Handle image uploads
      if (images != null && images.isNotEmpty) {
        // Use multipart request for image uploads
        final uri = Uri.parse('$baseUrl/reviews');
        final request = http.MultipartRequest('POST', uri);

        // Add auth headers
        if (authToken != null) {
          request.headers['Authorization'] = 'Bearer $authToken';
        }

        // Add review data as a field
        request.fields['review'] = json.encode(reviewData);

        // Add image files
        for (int i = 0; i < images.length; i++) {
          if (images[i] is File) {
            final file = images[i] as File;
            final fileName = 'image_${i + 1}.jpg';

            request.files.add(
              await http.MultipartFile.fromPath(
                'images',
                file.path,
                contentType: MediaType('image', 'jpeg'),
                filename: fileName,
              ),
            );
          }
        }

        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          return Review.fromJson(data);
        } else {
          throw Exception(
            'Failed to submit review: ${response.statusCode} ${response.body}',
          );
        }
      } else {
        // Simple JSON request without images
        final uri = Uri.parse('$baseUrl/reviews');
        final response = await _client.post(
          uri,
          headers: _headers,
          body: json.encode(reviewData),
        );

        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          return Review.fromJson(data);
        } else {
          throw Exception(
            'Failed to submit review: ${response.statusCode} ${response.body}',
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  @override
  Future<Review> updateReview(
    String reviewId,
    ReviewData review,
    List<dynamic>? images,
  ) async {
    try {
      // Get existing review
      final existingReview = await getReviewById(reviewId);
      if (existingReview == null) {
        throw Exception('Review not found');
      }

      // Verify ownership
      if (existingReview.userId != review.userId) {
        throw Exception('User does not own this review');
      }

      // Prepare review data
      final now = DateTime.now();

      final reviewData = {
        'userId': review.userId,
        'userName': review.userName,
        'userImageUrl': review.userImageUrl,
        'rating': review.rating,
        'title': review.title,
        'content': review.content,
        'updatedAt': now.toIso8601String(),
        'metadata': review.metadata,
      };

      // Handle image uploads
      if (images != null) {
        // Use multipart request for image uploads
        final uri = Uri.parse('$baseUrl/reviews/$reviewId');
        final request = http.MultipartRequest('PUT', uri);

        // Add auth headers
        if (authToken != null) {
          request.headers['Authorization'] = 'Bearer $authToken';
        }

        // Add review data as a field
        request.fields['review'] = json.encode(reviewData);

        // Add image files
        for (int i = 0; i < images.length; i++) {
          if (images[i] is File) {
            final file = images[i] as File;
            final fileName = 'image_${i + 1}.jpg';

            request.files.add(
              await http.MultipartFile.fromPath(
                'images',
                file.path,
                contentType: MediaType('image', 'jpeg'),
                filename: fileName,
              ),
            );
          }
        }

        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return Review.fromJson(data);
        } else {
          throw Exception(
            'Failed to update review: ${response.statusCode} ${response.body}',
          );
        }
      } else {
        // Simple JSON request without images
        final uri = Uri.parse('$baseUrl/reviews/$reviewId');
        final response = await _client.put(
          uri,
          headers: _headers,
          body: json.encode(reviewData),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return Review.fromJson(data);
        } else {
          throw Exception(
            'Failed to update review: ${response.statusCode} ${response.body}',
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  @override
  Future<bool> deleteReview(String reviewId) async {
    try {
      // Make API request
      final uri = Uri.parse('$baseUrl/reviews/$reviewId');
      final response = await _client.delete(uri, headers: _headers);

      // Handle response
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  @override
  Future<Review> respondToReview(
    String reviewId,
    ReviewResponseData response,
  ) async {
    try {
      // Prepare response data
      final responseId = _uuid.v4();
      final now = DateTime.now();

      final responseData = {
        'id': responseId,
        'userId': response.userId,
        'userName': response.userName,
        'userImageUrl': response.userImageUrl,
        'content': response.content,
        'createdAt': now.toIso8601String(),
        'isOfficial': response.isOfficial,
      };

      // Make API request
      final uri = Uri.parse('$baseUrl/reviews/$reviewId/responses');
      final apiResponse = await _client.post(
        uri,
        headers: _headers,
        body: json.encode(responseData),
      );

      // Handle response
      if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
        final data = json.decode(apiResponse.body);
        return Review.fromJson(data);
      } else {
        throw Exception(
          'Failed to respond to review: ${apiResponse.statusCode} ${apiResponse.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to respond to review: $e');
    }
  }

  @override
  Future<bool> markReviewHelpful(String reviewId, bool isHelpful) async {
    try {
      // Prepare data
      final data = {'isHelpful': isHelpful};

      // Make API request
      final uri = Uri.parse('$baseUrl/reviews/$reviewId/helpful');
      final response = await _client.post(
        uri,
        headers: _headers,
        body: json.encode(data),
      );

      // Handle response
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to mark review as helpful: $e');
    }
  }

  @override
  Future<RatingSummary> getItemRatingSummary(String itemId) async {
    try {
      // Make API request
      final uri = Uri.parse('$baseUrl/items/$itemId/rating-summary');
      final response = await _client.get(uri, headers: _headers);

      // Handle response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RatingSummary.fromJson(data);
      } else {
        throw Exception(
          'Failed to get item rating summary: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to get item rating summary: $e');
    }
  }

  @override
  Future<bool> hasUserReviewedItem(String itemId, String userId) async {
    try {
      // Make API request
      final uri = Uri.parse(
        '$baseUrl/reviews/check',
      ).replace(queryParameters: {'itemId': itemId, 'userId': userId});
      final response = await _client.get(uri, headers: _headers);

      // Handle response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['hasReviewed'] == true;
      } else {
        throw Exception(
          'Failed to check if user has reviewed item: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to check if user has reviewed item: $e');
    }
  }

  /// Close the HTTP client when done
  void dispose() {
    _client.close();
  }
}
