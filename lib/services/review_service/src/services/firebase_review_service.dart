// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:uuid/uuid.dart';
// import '../models/review.dart';
// import 'review_service.dart';
//
// /// Firebase implementation of the ReviewService
// class FirebaseReviewService implements ReviewService {
//   final FirebaseFirestore _firestore;
//   final FirebaseStorage _storage;
//   final String _collectionName;
//   final Uuid _uuid = const Uuid();
//
//   /// Create a new FirebaseReviewService
//   ///
//   /// [firestore] - Firestore instance
//   /// [storage] - Firebase Storage instance
//   /// [collectionName] - Name of the collection to store reviews in
//   FirebaseReviewService({
//     FirebaseFirestore? firestore,
//     FirebaseStorage? storage,
//     String collectionName = 'reviews',
//   })  : _firestore = firestore ?? FirebaseFirestore.instance,
//         _storage = storage ?? FirebaseStorage.instance,
//         _collectionName = collectionName;
//
//   @override
//   Future<ReviewsResult> getReviews({
//     required String itemId,
//     int page = 1,
//     int limit = 10,
//     String sortBy = 'createdAt',
//     String sortOrder = 'desc',
//     int? minRating,
//     int? maxRating,
//   }) async {
//     try {
//       // Start with a query for the item
//       Query query = _firestore.collection(_collectionName).where('itemId', isEqualTo: itemId);
//
//       // Apply rating filters if provided
//       if (minRating != null) {
//         query = query.where('rating', isGreaterThanOrEqualTo: minRating.toDouble());
//       }
//       if (maxRating != null) {
//         query = query.where('rating', isLessThanOrEqualTo: maxRating.toDouble());
//       }
//
//       // Get total count (for pagination)
//       final countSnapshot = await query.count().get();
//       final totalCount = countSnapshot.count;
//
//       // Apply sorting
//       query = query.orderBy(
//         sortBy,
//         descending: sortOrder.toLowerCase() == 'desc',
//       );
//
//       // Apply pagination
//       query = query.limit(limit).offset((page - 1) * limit);
//
//       // Execute the query
//       final querySnapshot = await query.get();
//
//       // Convert to Review objects
//       final reviews = querySnapshot.docs.map((doc) {
//         final data = doc.data() as Map<String, dynamic>;
//         return Review.fromJson({...data, 'id': doc.id});
//       }).toList();
//
//       // Calculate total pages
//       final totalPages = (totalCount / limit).ceil();
//
//       return ReviewsResult(
//         reviews: reviews,
//         totalCount: totalCount,
//         page: page,
//         limit: limit,
//         totalPages: totalPages,
//       );
//     } catch (e) {
//       throw Exception('Failed to get reviews: $e');
//     }
//   }
//
//   @override
//   Future<Review?> getReviewById(String reviewId) async {
//     try {
//       final docSnapshot = await _firestore.collection(_collectionName).doc(reviewId).get();
//
//       if (!docSnapshot.exists) {
//         return null;
//       }
//
//       final data = docSnapshot.data() as Map<String, dynamic>;
//       return Review.fromJson({...data, 'id': docSnapshot.id});
//     } catch (e) {
//       throw Exception('Failed to get review: $e');
//     }
//   }
//
//   @override
//   Future<Review> submitReview(ReviewData review, List<dynamic>? images) async {
//     try {
//       // Check if user has already reviewed this item
//       final existingReview = await _checkExistingReview(review.itemId, review.userId);
//       if (existingReview != null) {
//         throw Exception('User has already reviewed this item');
//       }
//
//       // Upload images if provided
//       List<String> imageUrls = [];
//       if (images != null && images.isNotEmpty) {
//         imageUrls = await _uploadImages(images, review.itemId, review.userId);
//       }
//
//       // Create review document
//       final reviewId = _uuid.v4();
//       final now = DateTime.now();
//
//       final newReview = Review(
//         id: reviewId,
//         userId: review.userId,
//         userName: review.userName,
//         userImageUrl: review.userImageUrl,
//         itemId: review.itemId,
//         rating: review.rating,
//         title: review.title,
//         content: review.content,
//         imageUrls: imageUrls,
//         createdAt: now,
//         updatedAt: now,
//         isVerified: false,
//         responses: [],
//         helpfulCount: 0,
//         metadata: review.metadata,
//       );
//
//       // Save to Firestore
//       await _firestore.collection(_collectionName).doc(reviewId).set(newReview.toJson());
//
//       // Update item rating summary
//       await _updateItemRatingSummary(review.itemId);
//
//       return newReview;
//     } catch (e) {
//       throw Exception('Failed to submit review: $e');
//     }
//   }
//
//   @override
//   Future<Review> updateReview(String reviewId, ReviewData review, List<dynamic>? images) async {
//     try {
//       // Get existing review
//       final existingReview = await getReviewById(reviewId);
//       if (existingReview == null) {
//         throw Exception('Review not found');
//       }
//
//       // Verify ownership
//       if (existingReview.userId != review.userId) {
//         throw Exception('User does not own this review');
//       }
//
//       // Handle images
//       List<String> imageUrls = existingReview.imageUrls;
//       if (images != null) {
//         // Delete existing images
//         for (final url in existingReview.imageUrls) {
//           await _deleteImage(url);
//         }
//         // Upload new images
//         imageUrls = await _uploadImages(images, review.itemId, review.userId);
//       }
//
//       // Update review
//       final now = DateTime.now();
//       final updatedReview = existingReview.copyWith(
//         userName: review.userName,
//         userImageUrl: review.userImageUrl,
//         rating: review.rating,
//         title: review.title,
//         content: review.content,
//         imageUrls: imageUrls,
//         updatedAt: now,
//         metadata: review.metadata,
//       );
//
//       // Save to Firestore
//       await _firestore.collection(_collectionName).doc(reviewId).update(updatedReview.toJson());
//
//       // Update item rating summary
//       await _updateItemRatingSummary(review.itemId);
//
//       return updatedReview;
//     } catch (e) {
//       throw Exception('Failed to update review: $e');
//     }
//   }
//
//   @override
//   Future<bool> deleteReview(String reviewId) async {
//     try {
//       // Get the review to get the item ID for updating summary
//       final review = await getReviewById(reviewId);
//       if (review == null) {
//         return false;
//       }
//
//       // Delete images
//       for (final url in review.imageUrls) {
//         await _deleteImage(url);
//       }
//
//       // Delete review document
//       await _firestore.collection(_collectionName).doc(reviewId).delete();
//
//       // Update item rating summary
//       await _updateItemRatingSummary(review.itemId);
//
//       return true;
//     } catch (e) {
//       throw Exception('Failed to delete review: $e');
//     }
//   }
//
//   @override
//   Future<Review> respondToReview(String reviewId, ReviewResponseData response) async {
//     try {
//       // Get existing review
//       final existingReview = await getReviewById(reviewId);
//       if (existingReview == null) {
//         throw Exception('Review not found');
//       }
//
//       // Create response
//       final responseId = _uuid.v4();
//       final now = DateTime.now();
//
//       final newResponse = ReviewResponse(
//         id: responseId,
//         userId: response.userId,
//         userName: response.userName,
//         userImageUrl: response.userImageUrl,
//         content: response.content,
//         createdAt: now,
//         isOfficial: response.isOfficial,
//       );
//
//       // Add response to review
//       final updatedResponses = [...existingReview.responses, newResponse];
//       final updatedReview = existingReview.copyWith(
//         responses: updatedResponses,
//         updatedAt: now,
//       );
//
//       // Save to Firestore
//       await _firestore.collection(_collectionName).doc(reviewId).update({
//         'responses': updatedResponses.map((r) => r.toJson()).toList(),
//         'updatedAt': now.toIso8601String(),
//       });
//
//       return updatedReview;
//     } catch (e) {
//       throw Exception('Failed to respond to review: $e');
//     }
//   }
//
//   @override
//   Future<bool> markReviewHelpful(String reviewId, bool isHelpful) async {
//     try {
//       // Get existing review
//       final existingReview = await getReviewById(reviewId);
//       if (existingReview == null) {
//         return false;
//       }
//
//       // Update helpful count
//       final helpfulCount = isHelpful
//           ? existingReview.helpfulCount + 1
//           : existingReview.helpfulCount - 1;
//
//       // Ensure count doesn't go below 0
//       final updatedCount = helpfulCount < 0 ? 0 : helpfulCount;
//
//       // Update in Firestore
//       await _firestore.collection(_collectionName).doc(reviewId).update({
//         'helpfulCount': updatedCount,
//       });
//
//       return true;
//     } catch (e) {
//       throw Exception('Failed to mark review as helpful: $e');
//     }
//   }
//
//   @override
//   Future<RatingSummary> getItemRatingSummary(String itemId) async {
//     try {
//       // Get all reviews for the item
//       final querySnapshot = await _firestore
//           .collection(_collectionName)
//           .where('itemId', isEqualTo: itemId)
//           .get();
//
//       if (querySnapshot.docs.isEmpty) {
//         // Return empty summary if no reviews
//         return RatingSummary(
//           itemId: itemId,
//           averageRating: 0,
//           totalReviews: 0,
//           ratingCounts: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
//         );
//       }
//
//       // Calculate summary
//       double sum = 0;
//       final ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
//
//       for (final doc in querySnapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         final rating = (data['rating'] as num).toDouble();
//         sum += rating;
//
//         // Increment count for this rating
//         final ratingKey = rating.round();
//         ratingCounts[ratingKey] = (ratingCounts[ratingKey] ?? 0) + 1;
//       }
//
//       final totalReviews = querySnapshot.docs.length;
//       final averageRating = sum / totalReviews;
//
//       return RatingSummary(
//         itemId: itemId,
//         averageRating: averageRating,
//         totalReviews: totalReviews,
//         ratingCounts: ratingCounts,
//       );
//     } catch (e) {
//       throw Exception('Failed to get item rating summary: $e');
//     }
//   }
//
//   @override
//   Future<bool> hasUserReviewedItem(String itemId, String userId) async {
//     final existingReview = await _checkExistingReview(itemId, userId);
//     return existingReview != null;
//   }
//
//   // Helper method to check if a user has already reviewed an item
//   Future<Review?> _checkExistingReview(String itemId, String userId) async {
//     final querySnapshot = await _firestore
//         .collection(_collectionName)
//         .where('itemId', isEqualTo: itemId)
//         .where('userId', isEqualTo: userId)
//         .limit(1)
//         .get();
//
//     if (querySnapshot.docs.isEmpty) {
//       return null;
//     }
//
//     final doc = querySnapshot.docs.first;
//     final data = doc.data() as Map<String, dynamic>;
//     return Review.fromJson({...data, 'id': doc.id});
//   }
//
//   // Helper method to upload images
//   Future<List<String>> _uploadImages(List<dynamic> images, String itemId, String userId) async {
//     final List<String> imageUrls = [];
//
//     for (final image in images) {
//       if (image is File) {
//         final fileName = '${_uuid.v4()}.jpg';
//         final path = 'reviews/$itemId/$userId/$fileName';
//
//         final ref = _storage.ref().child(path);
//         await ref.putFile(image);
//
//         final url = await ref.getDownloadURL();
//         imageUrls.add(url);
//       }
//     }
//
//     return imageUrls;
//   }
//
//   // Helper method to delete an image
//   Future<void> _deleteImage(String imageUrl) async {
//     try {
//       // Extract the path from the URL
//       final ref = _storage.refFromURL(imageUrl);
//       await ref.delete();
//     } catch (e) {
//       // Log error but don't fail the operation
//       print('Failed to delete image: $e');
//     }
//   }
//
//   // Helper method to update item rating summary
//   Future<void> _updateItemRatingSummary(String itemId) async {
//     try {
//       final summary = await getItemRatingSummary(itemId);
//
//       // Store summary in a separate collection for quick access
//       await _firestore.collection('rating_summaries').doc(itemId).set(summary.toJson());
//     } catch (e) {
//       // Log error but don't fail the operation
//       print('Failed to update item rating summary: $e');
//     }
//   }
// }