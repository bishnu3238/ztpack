import 'package:flutter/material.dart';
import '../services/review_service.dart';
import 'rating_bar.dart';

/// A widget that displays a summary of ratings for an item
class RatingSummaryWidget extends StatelessWidget {
  /// The rating summary data to display
  final RatingSummary summary;
  
  /// Custom style for the rating summary
  final RatingSummaryStyle? style;
  
  /// Callback when a rating filter is selected
  final Function(int? rating)? onRatingFilterSelected;

  const RatingSummaryWidget({
    Key? key,
    required this.summary,
    this.style,
    this.onRatingFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summaryStyle = style ?? RatingSummaryStyle.fromTheme(theme);
    
    return Container(
      padding: summaryStyle.padding,
      decoration: BoxDecoration(
        color: summaryStyle.backgroundColor,
        borderRadius: BorderRadius.circular(summaryStyle.borderRadius),
        border: summaryStyle.showBorder 
            ? Border.all(color: theme.dividerColor) 
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average rating and total reviews
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Average rating number
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: summaryStyle.averageRatingStyle,
              ),
              const SizedBox(width: 8),
              
              // Star rating
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: RatingBar(
                  rating: summary.averageRating,
                  size: 20,
                  color: summaryStyle.ratingColor,
                ),
              ),
              
              const Spacer(),
              
              // Total reviews
              Text(
                '${summary.totalReviews} ${summary.totalReviews == 1 ? 'review' : 'reviews'}',
                style: summaryStyle.totalReviewsStyle,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Rating distribution
          ...List.generate(5, (index) {
            final rating = 5 - index;
            final count = summary.ratingCounts[rating] ?? 0;
            final percentage = summary.getPercentageForRating(rating);
            
            return GestureDetector(
              onTap: onRatingFilterSelected != null 
                  ? () => onRatingFilterSelected!(rating) 
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    // Rating label
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$rating',
                        style: summaryStyle.ratingLabelStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    // Star icon
                    Icon(
                      Icons.star,
                      size: 16,
                      color: summaryStyle.ratingColor,
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Progress bar
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: summaryStyle.progressBackgroundColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            summaryStyle.progressValueColor,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Count and percentage
                    SizedBox(
                      width: 80,
                      child: Text(
                        '$count (${percentage.toStringAsFixed(0)}%)',
                        style: summaryStyle.countStyle,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          
          // Filter hint
          if (onRatingFilterSelected != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Tap on a row to filter by that rating',
                style: summaryStyle.hintStyle,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

/// Style configuration for the RatingSummary widget
class RatingSummaryStyle {
  final EdgeInsets padding;
  final double borderRadius;
  final Color backgroundColor;
  final bool showBorder;
  final TextStyle averageRatingStyle;
  final TextStyle totalReviewsStyle;
  final TextStyle ratingLabelStyle;
  final TextStyle countStyle;
  final TextStyle hintStyle;
  final Color ratingColor;
  final Color progressBackgroundColor;
  final Color progressValueColor;

  const RatingSummaryStyle({
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 8.0,
    required this.backgroundColor,
    this.showBorder = true,
    required this.averageRatingStyle,
    required this.totalReviewsStyle,
    required this.ratingLabelStyle,
    required this.countStyle,
    required this.hintStyle,
    required this.ratingColor,
    required this.progressBackgroundColor,
    required this.progressValueColor,
  });

  /// Create a RatingSummaryStyle from the current theme
  factory RatingSummaryStyle.fromTheme(ThemeData theme) {
    return RatingSummaryStyle(
      backgroundColor: theme.colorScheme.surface,
      averageRatingStyle: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.titleLarge?.color,
      ),
      totalReviewsStyle: TextStyle(
        fontSize: 14,
        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
      ),
      ratingLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.bodyMedium?.color,
      ),
      countStyle: TextStyle(
        fontSize: 12,
        color: theme.textTheme.bodySmall?.color,
      ),
      hintStyle: TextStyle(
        fontSize: 12,
        fontStyle: FontStyle.italic,
        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
      ),
      ratingColor: Colors.amber,
      progressBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
      progressValueColor: theme.colorScheme.primary,
    );
  }

  /// Create a copy of this style with the given fields replaced
  RatingSummaryStyle copyWith({
    EdgeInsets? padding,
    double? borderRadius,
    Color? backgroundColor,
    bool? showBorder,
    TextStyle? averageRatingStyle,
    TextStyle? totalReviewsStyle,
    TextStyle? ratingLabelStyle,
    TextStyle? countStyle,
    TextStyle? hintStyle,
    Color? ratingColor,
    Color? progressBackgroundColor,
    Color? progressValueColor,
  }) {
    return RatingSummaryStyle(
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showBorder: showBorder ?? this.showBorder,
      averageRatingStyle: averageRatingStyle ?? this.averageRatingStyle,
      totalReviewsStyle: totalReviewsStyle ?? this.totalReviewsStyle,
      ratingLabelStyle: ratingLabelStyle ?? this.ratingLabelStyle,
      countStyle: countStyle ?? this.countStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      ratingColor: ratingColor ?? this.ratingColor,
      progressBackgroundColor: progressBackgroundColor ?? this.progressBackgroundColor,
      progressValueColor: progressValueColor ?? this.progressValueColor,
    );
  }
}
