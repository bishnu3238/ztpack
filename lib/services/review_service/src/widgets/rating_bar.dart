import 'package:flutter/material.dart';

/// A widget that displays a star rating
class RatingBar extends StatelessWidget {
  /// The rating value (0.0 to 5.0)
  final double rating;
  
  /// The size of each star
  final double size;
  
  /// The color of the filled stars
  final Color color;
  
  /// The color of the empty stars
  final Color? emptyColor;
  
  /// The icon to use for the stars
  final IconData filledIcon;
  
  /// The icon to use for the empty stars
  final IconData emptyIcon;
  
  /// Whether to allow half stars
  final bool allowHalfRating;
  
  /// The spacing between stars
  final double spacing;

  const RatingBar({
    super.key,
    required this.rating,
    this.size = 24,
    this.color = Colors.amber,
    this.emptyColor,
    this.filledIcon = Icons.star,
    this.emptyIcon = Icons.star_border,
    this.allowHalfRating = true,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actualEmptyColor = emptyColor ?? theme.colorScheme.onSurface.withOpacity(0.3);
    final roundedRating = allowHalfRating 
        ? (rating * 2).round() / 2 
        : rating.round().toDouble();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        
        // Determine which icon to show
        Widget starIcon;
        if (roundedRating >= starValue) {
          // Full star
          starIcon = Icon(
            filledIcon,
            color: color,
            size: size,
          );
        } else if (allowHalfRating && roundedRating == starValue - 0.5) {
          // Half star
          starIcon = Stack(
            children: [
              Icon(
                emptyIcon,
                color: actualEmptyColor,
                size: size,
              ),
              ClipRect(
                clipper: _HalfClipper(),
                child: Icon(
                  filledIcon,
                  color: color,
                  size: size,
                ),
              ),
            ],
          );
        } else {
          // Empty star
          starIcon = Icon(
            emptyIcon,
            color: actualEmptyColor,
            size: size,
          );
        }
        
        return Padding(
          padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
          child: starIcon,
        );
      }),
    );
  }
}

/// A clipper that clips the right half of a widget
class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return false;
  }
}

/// A widget that allows users to select a rating
class RatingBarSelector extends StatelessWidget {
  /// The initial rating value
  final double initialRating;
  
  /// Callback when the rating changes
  final ValueChanged<double> onRatingChanged;
  
  /// The size of each star
  final double size;
  
  /// The color of the filled stars
  final Color color;
  
  /// The color of the empty stars
  final Color? emptyColor;
  
  /// The icon to use for the stars
  final IconData filledIcon;
  
  /// The icon to use for the empty stars
  final IconData emptyIcon;
  
  /// Whether to allow half stars
  final bool allowHalfRating;
  
  /// The spacing between stars
  final double spacing;

  const RatingBarSelector({
    Key? key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.size = 40,
    this.color = Colors.amber,
    this.emptyColor,
    this.filledIcon = Icons.star,
    this.emptyIcon = Icons.star_border,
    this.allowHalfRating = true,
    this.spacing = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actualEmptyColor = emptyColor ?? theme.colorScheme.onSurface.withOpacity(0.3);
    
    return StatefulBuilder(
      builder: (context, setState) {
        double currentRating = initialRating;
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = index + 1.0;
            
            return GestureDetector(
              onTap: () {
                currentRating = starValue;
                onRatingChanged(currentRating);
                setState(() {});
              },
              onHorizontalDragUpdate: allowHalfRating ? (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final starWidth = box.size.width / 5;
                final starIndex = (localPosition.dx / starWidth).floor();
                final starCenterX = (starIndex * starWidth) + (starWidth / 2);
                
                double newRating;
                if (localPosition.dx < starCenterX && allowHalfRating) {
                  newRating = starIndex + 0.5;
                } else {
                  newRating = starIndex + 1.0;
                }
                
                newRating = newRating.clamp(0.5, 5.0);
                if (newRating != currentRating) {
                  currentRating = newRating;
                  onRatingChanged(currentRating);
                  setState(() {});
                }
              } : null,
              child: Padding(
                padding: EdgeInsets.only(right: index < 4 ? spacing : 0),
                child: Icon(
                  currentRating >= starValue 
                      ? filledIcon 
                      : (allowHalfRating && currentRating == starValue - 0.5) 
                          ? Icons.star_half
                          : emptyIcon,
                  color: currentRating >= starValue 
                      ? color 
                      : (allowHalfRating && currentRating == starValue - 0.5)
                          ? color
                          : actualEmptyColor,
                  size: size,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}