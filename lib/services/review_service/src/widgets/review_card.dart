import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';
import 'rating_bar.dart';
import 'review_image_gallery.dart';
import 'review_response_card.dart';

/// A widget that displays a single review
class ReviewCard extends StatelessWidget {
  /// The review to display
  final Review review;

  /// Callback when the helpful button is pressed
  final Function(bool isHelpful)? onHelpfulPressed;

  /// Callback when the report button is pressed
  final VoidCallback? onReportPressed;

  /// Callback when the respond button is pressed
  final VoidCallback? onRespondPressed;

  /// Whether to show the respond button
  final bool showRespondButton;

  /// Whether to show the helpful button
  final bool showHelpfulButton;

  /// Whether to show the report button
  final bool showReportButton;

  /// Custom style for the card
  final ReviewCardStyle? style;

  const ReviewCard({
    Key? key,
    required this.review,
    this.onHelpfulPressed,
    this.onReportPressed,
    this.onRespondPressed,
    this.showRespondButton = false,
    this.showHelpfulButton = true,
    this.showReportButton = true,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardStyle = style ?? ReviewCardStyle.fromTheme(theme);
    final dateFormat = DateFormat('MMM d, yyyy');
    dev.log("dfsdfdsfsd${review.userName}");
    return Card(
      margin: cardStyle.margin,
      elevation: cardStyle.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardStyle.borderRadius),
      ),
      child: Padding(
        padding: cardStyle.padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User avatar
                if (review.userImageUrl.isNotEmpty)
                  CircleAvatar(
                    radius: 20,
                    child: Text(review.userName.substring(1, 2)),
                    // backgroundImage: NetworkImage(review.userImageUrl),
                  )
                else
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      review.userName.isNotEmpty
                          ? review.userName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),

                // User name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName, style: cardStyle.userNameStyle),
                      Text(
                        dateFormat.format(review.createdAt),
                        style: cardStyle.dateStyle,
                      ),
                    ],
                  ),
                ),

                // Rating
                RatingBar(
                  rating: review.rating,
                  size: 18,
                  color: cardStyle.ratingColor,
                ),
              ],
            ),

            // Verified badge
            if (review.isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified Purchase',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Review title
            if (review.title != null && review.title!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(review.title!, style: cardStyle.titleStyle),
              ),

            // Review content
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(review.content, style: cardStyle.contentStyle),
            ),

            // Review images
            if (review.imageUrls.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ReviewImageGallery(
                  imageUrls: review.imageUrls,
                  height: 120,
                ),
              ),

            // Action buttons
            if (showHelpfulButton || showReportButton || showRespondButton)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Helpful button
                    if (showHelpfulButton)
                      TextButton.icon(
                        onPressed: () => onHelpfulPressed?.call(true),
                        icon: const Icon(Icons.thumb_up_outlined, size: 16),
                        label: Text('Helpful (${review.helpfulCount})'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface
                              .withOpacity(0.7),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 36),
                        ),
                      ),

                    Row(
                      children: [
                        // Report button
                        if (showReportButton)
                          TextButton(
                            onPressed: onReportPressed,
                            child: const Text('Report'),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.onSurface
                                  .withOpacity(0.7),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                          ),

                        // Respond button
                        if (showRespondButton)
                          TextButton.icon(
                            onPressed: onRespondPressed,
                            icon: const Icon(Icons.reply, size: 16),
                            label: const Text('Respond'),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            // Responses
            if (review.responses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    ...review.responses.map(
                      (response) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ReviewResponseCard(
                          response: response,
                          style: cardStyle.responseCardStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Style configuration for the ReviewCard
class ReviewCardStyle {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final double borderRadius;
  final TextStyle userNameStyle;
  final TextStyle dateStyle;
  final TextStyle titleStyle;
  final TextStyle contentStyle;
  final Color ratingColor;
  final ReviewResponseCardStyle responseCardStyle;

  const ReviewCardStyle({
    this.margin = const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 1.0,
    this.borderRadius = 8.0,
    required this.userNameStyle,
    required this.dateStyle,
    required this.titleStyle,
    required this.contentStyle,
    required this.ratingColor,
    required this.responseCardStyle,
  });

  /// Create a ReviewCardStyle from the current theme
  factory ReviewCardStyle.fromTheme(ThemeData theme) {
    return ReviewCardStyle(
      userNameStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: theme.textTheme.bodyLarge?.color,
      ),
      dateStyle: TextStyle(
        fontSize: 12,
        color: theme.textTheme.bodySmall?.color,
      ),
      titleStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: theme.textTheme.titleMedium?.color,
      ),
      contentStyle: TextStyle(
        fontSize: 14,
        color: theme.textTheme.bodyMedium?.color,
      ),
      ratingColor: theme.colorScheme.primary,
      responseCardStyle: ReviewResponseCardStyle.fromTheme(theme),
    );
  }

  /// Create a copy of this style with the given fields replaced
  ReviewCardStyle copyWith({
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? elevation,
    double? borderRadius,
    TextStyle? userNameStyle,
    TextStyle? dateStyle,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
    Color? ratingColor,
    ReviewResponseCardStyle? responseCardStyle,
  }) {
    return ReviewCardStyle(
      margin: margin ?? this.margin,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
      userNameStyle: userNameStyle ?? this.userNameStyle,
      dateStyle: dateStyle ?? this.dateStyle,
      titleStyle: titleStyle ?? this.titleStyle,
      contentStyle: contentStyle ?? this.contentStyle,
      ratingColor: ratingColor ?? this.ratingColor,
      responseCardStyle: responseCardStyle ?? this.responseCardStyle,
    );
  }
}
