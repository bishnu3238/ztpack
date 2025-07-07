import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/review.dart';

/// A widget that displays a response to a review
class ReviewResponseCard extends StatelessWidget {
  /// The response to display
  final ReviewResponse response;
  
  /// Custom style for the card
  final ReviewResponseCardStyle? style;

  const ReviewResponseCard({
    Key? key,
    required this.response,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardStyle = style ?? ReviewResponseCardStyle.fromTheme(theme);
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Container(
      padding: cardStyle.padding,
      decoration: BoxDecoration(
        color: cardStyle.backgroundColor,
        borderRadius: BorderRadius.circular(cardStyle.borderRadius),
        border: cardStyle.showBorder 
            ? Border.all(color: theme.dividerColor.withOpacity(0.3)) 
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User avatar
              if (response.userImageUrl != null)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(response.userImageUrl!),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    response.userName.isNotEmpty ? response.userName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              
              // User name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          response.userName,
                          style: cardStyle.userNameStyle,
                        ),
                        if (response.isOfficial)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Official',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      dateFormat.format(response.createdAt),
                      style: cardStyle.dateStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Response content
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 40.0),
            child: Text(
              response.content,
              style: cardStyle.contentStyle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Style configuration for the ReviewResponseCard
class ReviewResponseCardStyle {
  final EdgeInsets padding;
  final double borderRadius;
  final Color backgroundColor;
  final bool showBorder;
  final TextStyle userNameStyle;
  final TextStyle dateStyle;
  final TextStyle contentStyle;

  const ReviewResponseCardStyle({
    this.padding = const EdgeInsets.all(12.0),
    this.borderRadius = 8.0,
    required this.backgroundColor,
    this.showBorder = true,
    required this.userNameStyle,
    required this.dateStyle,
    required this.contentStyle,
  });

  /// Create a ReviewResponseCardStyle from the current theme
  factory ReviewResponseCardStyle.fromTheme(ThemeData theme) {
    return ReviewResponseCardStyle(
      backgroundColor: theme.colorScheme.surface,
      userNameStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: theme.textTheme.bodyLarge?.color,
      ),
      dateStyle: TextStyle(
        fontSize: 12,
        color: theme.textTheme.bodySmall?.color,
      ),
      contentStyle: TextStyle(
        fontSize: 14,
        color: theme.textTheme.bodyMedium?.color,
      ),
    );
  }

  /// Create a copy of this style with the given fields replaced
  ReviewResponseCardStyle copyWith({
    EdgeInsets? padding,
    double? borderRadius,
    Color? backgroundColor,
    bool? showBorder,
    TextStyle? userNameStyle,
    TextStyle? dateStyle,
    TextStyle? contentStyle,
  }) {
    return ReviewResponseCardStyle(
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showBorder: showBorder ?? this.showBorder,
      userNameStyle: userNameStyle ?? this.userNameStyle,
      dateStyle: dateStyle ?? this.dateStyle,
      contentStyle: contentStyle ?? this.contentStyle,
    );
  }
}