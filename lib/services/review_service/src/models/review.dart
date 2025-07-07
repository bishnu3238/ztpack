import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:pack/pack.dart';

class Review {
  final String id;
  final String userId; // customer_id in DB
  final String userName;
  final String userImageUrl;
  final String itemId; // merchant_id in DB
  final String? serviceName; // service_name in DB
  final double rating;
  final String? title; // review_title in DB
  final String content; // review_content in DB
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final List<ReviewResponse> responses;
  final int helpfulCount;
  final Map<String, dynamic>? metadata;

  static Review empty = Review(
    id: 'id',
    userId: 'userId',
    userName: 'userName',
    userImageUrl: 'userImageUrl',
    itemId: 'itemId',
    rating: 0,
    content: 'content',
    createdAt: DateTime(2025),
  );

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.itemId,
    this.serviceName,
    required this.rating,
    this.title,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.responses = const [],
    this.helpfulCount = 0,
    this.metadata,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json.getString('id'),
      userId: json.getString('customer_id'),
      userName: json.getString('customer_name'), // PHP: user_name
      userImageUrl: json.getString('customer_image'),
      itemId: json.getString('merchant_id'),
      serviceName: json.getString('service_name'),
      rating: json.getDouble('rating'),
      title: json.getString('review_title'),
      content: json.getString('review_content'),
      imageUrls:
          (json['image_urls'] is List)
              ? List<String>.from(json['image_urls'])
              : (json['image_urls'] is String && json['image_urls'].isNotEmpty)
              ? List<String>.from(
                List<dynamic>.from(jsonDecode(json['image_urls'])),
              )
              : [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
      isVerified: json.getBool('is_verified'),
      responses:
          (json['responses'] is List)
              ? (json['responses'] as List)
                  .map(
                    (e) => ReviewResponse.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
              : (json['responses'] is String && json['responses'].isNotEmpty)
              ? (List<Map<String, dynamic>>.from(
                jsonDecode(json['responses']),
              ).map((e) => ReviewResponse.fromJson(e)).toList())
              : [],
      helpfulCount: json.getInt('helpful_count'),
      metadata: {'metadata': json['metadata']},
      // is Map<String, dynamic>
      //     ? json['metadata']
      //     : (json['metadata'] is String && json['metadata'].isNotEmpty)
      //     ? Map<String, dynamic>.from(jsonDecode(json['metadata']))
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'merchant_id': itemId,
      'service_name': serviceName,
      'rating': rating,
      'review_title': title,
      'review_content': content,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_verified': isVerified ? 1 : 0,
      'responses': responses.map((e) => e.toJson()).toList(),
      'helpful_count': helpfulCount,
      'metadata': metadata,
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImageUrl,
    String? itemId,
    String? serviceName,
    double? rating,
    String? title,
    String? content,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    List<ReviewResponse>? responses,
    int? helpfulCount,
    Map<String, dynamic>? metadata,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      itemId: itemId ?? this.itemId,
      serviceName: serviceName ?? this.serviceName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      responses: responses ?? this.responses,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'Review(id: $id, userId: $userId, userName: $userName, userImageUrl: $userImageUrl, itemId: $itemId, serviceName: $serviceName, rating: $rating, title: $title, content: $content, imageUrls: $imageUrls, createdAt: $createdAt, updatedAt: $updatedAt, isVerified: $isVerified, responses: $responses, helpfulCount: $helpfulCount, metadata: $metadata)';
  }
}

class ReviewResponse {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String content;
  final DateTime createdAt;
  final bool isOfficial;

  const ReviewResponse({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.content,
    required this.createdAt,
    this.isOfficial = false,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'] as String,
      userId: json['user_id'] ?? json['userId'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      userImageUrl: json['user_image_url'] ?? json['userImageUrl'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      isOfficial: json['is_official'] == 1 || json['is_official'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_official': isOfficial ? 1 : 0,
    };
  }

  ReviewResponse copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userImageUrl,
    String? content,
    DateTime? createdAt,
    bool? isOfficial,
  }) {
    return ReviewResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isOfficial: isOfficial ?? this.isOfficial,
    );
  }

  @override
  String toString() {
    return 'ReviewResponse(id: $id, userId: $userId, userName: $userName, userImageUrl: $userImageUrl, content: $content, createdAt: $createdAt, isOfficial: $isOfficial)';
  }
}
