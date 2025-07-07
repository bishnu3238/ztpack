import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Base Shimmer configuration class to customize the shimmer effect
class ShimmerConfig {
  final Color baseColor;
  final Color highlightColor;
  final Duration period;
  final ShimmerDirection direction;
  final bool enabled;

  const ShimmerConfig({
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.period = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
    this.enabled = true,
  });
}

/// Base class for all shimmer widgets
abstract class BaseShimmerWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  const BaseShimmerWidget({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.borderRadius,
  });
}

/// Rectangular shimmer widget
class RectangleShimmer extends BaseShimmerWidget {
  const RectangleShimmer({
    super.key,
    super.width,
    super.height = 20,
    super.margin,
    super.padding,
    super.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// Square shimmer widget
class SquareShimmer extends BaseShimmerWidget {
  final double size;

  const SquareShimmer({
    super.key,
    this.size = 50,
    super.margin,
    super.padding,
    super.borderRadius,
  }) : super(width: size, height: size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// Circle shimmer widget
class CircleShimmer extends BaseShimmerWidget {
  final double radius;

  const CircleShimmer({
    super.key,
    this.radius = 25,
    super.margin,
    super.padding,
  }) : super(width: radius * 2, height: radius * 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      margin: margin,
      padding: padding,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Triangle shimmer widget
class TriangleShimmer extends BaseShimmerWidget {
  const TriangleShimmer({
    super.key,
    super.width = 50,
    super.height = 50,
    super.margin,
    super.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: CustomPaint(
        painter: _TrianglePainter(),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white;
    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Text line shimmer widget
class TextLineShimmer extends BaseShimmerWidget {
  final double height;
  final double? width;
  final double? widthFactor;

  const TextLineShimmer({
    super.key,
    this.height = 14,
    this.width,
    this.widthFactor,
    super.margin,
    super.padding,
    super.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? (widthFactor != null ? MediaQuery.of(context).size.width * widthFactor! : double.infinity),
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

/// Avatar shimmer widget
class AvatarShimmer extends CircleShimmer {
  const AvatarShimmer({
    super.key,
    super.radius = 25,
    super.margin,
    super.padding,
  });
}

/// Card shimmer widget
class CardShimmer extends BaseShimmerWidget {
  final Widget? child;
  final double? elevation;

  const CardShimmer({
    super.key,
    super.width,
    super.height = 100,
    super.margin,
    super.padding,
    super.borderRadius,
    this.child,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        boxShadow: elevation != null
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation!,
            spreadRadius: elevation! / 2,
          ),
        ]
            : null,
      ),
      child: child,
    );
  }
}

/// List item shimmer widget
class ListItemShimmer extends BaseShimmerWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  const ListItemShimmer({
    super.key,
    super.width,
    super.height = 70,
    super.margin,
    super.padding,
    super.borderRadius,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                title ?? const TextLineShimmer(height: 16, widthFactor: 0.7),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Horizontal list shimmer
class HorizontalListShimmer extends BaseShimmerWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;
  final double spacing;
  final Widget Function(int index)? itemBuilder;
  final EdgeInsetsGeometry? itemMargin;
  final BorderRadiusGeometry? itemBorderRadius;

  const HorizontalListShimmer({
    super.key,
    super.width,
    super.height = 120,
    super.margin,
    super.padding,
    this.itemCount = 5,
    this.itemWidth = 80,
    this.itemHeight = 100,
    this.spacing = 12,
    this.itemBuilder,
    this.itemMargin,
    this.itemBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (itemBuilder != null) {
            return itemBuilder!(index);
          }
          return Container(
            margin: itemMargin ?? EdgeInsets.only(
              left: index == 0 ? 16 : spacing / 2,
              right: index == itemCount - 1 ? 16 : spacing / 2,
            ),
            width: itemWidth,
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: itemBorderRadius ?? BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}

/// Vertical list shimmer
class VerticalListShimmer extends BaseShimmerWidget {
  final int itemCount;
  final double itemHeight;
  final double spacing;
  final Widget Function(int index)? itemBuilder;
  final EdgeInsetsGeometry? itemMargin;
  final BorderRadiusGeometry? itemBorderRadius;

  const VerticalListShimmer({
    super.key,
    super.width,
    super.height,
    super.margin,
    super.padding,
    this.itemCount = 4,
    this.itemHeight = 70,
    this.spacing = 12,
    this.itemBuilder,
    this.itemMargin,
    this.itemBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      padding: padding,
      height: height,
      child: ListView.builder(
        shrinkWrap: height == null,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (itemBuilder != null) {
            return itemBuilder!(index);
          }
          return Container(
            margin: itemMargin ?? EdgeInsets.symmetric(
              horizontal: 16,
              vertical: spacing / 2,
            ),
            height: itemHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: itemBorderRadius ?? BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}

/// Grid shimmer
class GridShimmer extends BaseShimmerWidget {
  final int itemCount;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final Widget Function(int index)? itemBuilder;
  final BorderRadiusGeometry? itemBorderRadius;
  final Axis scrollDirection;

  const GridShimmer({
    super.key,
    super.width,
    super.height,
    super.margin,
    super.padding,
    this.itemCount = 8,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.childAspectRatio = 1.0,
    this.itemBuilder,
    this.itemBorderRadius,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      child: GridView.builder(
        scrollDirection: scrollDirection,
        shrinkWrap: height == null,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) {
          if (itemBuilder != null) {
            return itemBuilder!(index);
          }
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: itemBorderRadius ?? BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}

/// Social media profile shimmer
class ProfileShimmer extends BaseShimmerWidget {
  const ProfileShimmer({
    super.key,
    super.width,
    super.height,
    super.margin,
    super.padding,
    super.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AvatarShimmer(radius: 50),
          const SizedBox(height: 16),
          const TextLineShimmer(width: 150, height: 20),
          const SizedBox(height: 8),
          const TextLineShimmer(width: 100, height: 14),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  TextLineShimmer(width: 50, height: 18),
                  SizedBox(height: 4),
                  TextLineShimmer(width: 70, height: 14),
                ],
              ),
              Column(
                children: [
                  TextLineShimmer(width: 50, height: 18),
                  SizedBox(height: 4),
                  TextLineShimmer(width: 70, height: 14),
                ],
              ),
              Column(
                children: [
                  TextLineShimmer(width: 50, height: 18),
                  SizedBox(height: 4),
                  TextLineShimmer(width: 70, height: 14),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const TextLineShimmer(widthFactor: 0.9),
          const SizedBox(height: 8),
          const TextLineShimmer(widthFactor: 0.7),
        ],
      ),
    );
  }
}

/// Product card shimmer
class ProductCardShimmer extends BaseShimmerWidget {
  const ProductCardShimmer({
    super.key,
    super.width = 160,
    super.height = 220,
    super.margin,
    super.padding,
    super.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: (borderRadius as BorderRadius?)?.topLeft ?? const Radius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const TextLineShimmer(widthFactor: 0.9),
                  const SizedBox(height: 4),
                  const TextLineShimmer(widthFactor: 0.7),
                  const SizedBox(height: 8),
                  const TextLineShimmer(widthFactor: 0.5, height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Main shimmer wrapper
class ShimmerLoading extends StatelessWidget {
  final ShimmerConfig config;
  final Widget child;

  const ShimmerLoading({
    super.key,
    this.config = const ShimmerConfig(),
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: config.baseColor,
      highlightColor: config.highlightColor,
      period: config.period,
      direction: config.direction,
      enabled: config.enabled,
      child: child,
    );
  }
}

/// Pre-built home page shimmer
class HomePageShimmer extends StatelessWidget {
  final ShimmerConfig? config;

  const HomePageShimmer({
    super.key,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      config: config ?? const ShimmerConfig(),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            const CardShimmer(
              height: 150,
              margin: EdgeInsets.all(16),
            ),

            // Categories
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: TextLineShimmer(width: 100, height: 18),
            ),
            const HorizontalListShimmer(
              itemCount: 5,
              itemWidth: 80,
              itemHeight: 80,
            ),

            // Featured items
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: TextLineShimmer(width: 120, height: 18),
            ),
            const HorizontalListShimmer(
              itemCount: 3,
              itemWidth: 240,
              itemHeight: 120,
            ),

            // Product grid
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: TextLineShimmer(width: 150, height: 18),
            ),
            GridShimmer(
              margin: const EdgeInsets.all(16),
              itemCount: 4,
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              itemBuilder: (index) => const ProductCardShimmer(
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Recent items
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: TextLineShimmer(width: 120, height: 18),
            ),
            const VerticalListShimmer(
              itemCount: 3,
              itemHeight: 80,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-built profile page shimmer
class ProfilePageShimmer extends StatelessWidget {
  final ShimmerConfig? config;

  const ProfilePageShimmer({
    super.key,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      config: config ?? const ShimmerConfig(),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const ProfileShimmer(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RectangleShimmer(width: 120, height: 40),
                RectangleShimmer(width: 120, height: 40),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: TextLineShimmer(width: 120, height: 18),
          ),
          const Expanded(
            child: GridShimmer(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              childAspectRatio: 1.0,
              itemCount: 9,
              padding: EdgeInsets.zero,
              itemBorderRadius: BorderRadius.zero,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pre-built detail page shimmer
class DetailPageShimmer extends StatelessWidget {
  final ShimmerConfig? config;

  const DetailPageShimmer({
    super.key,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      config: config ?? const ShimmerConfig(),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            const RectangleShimmer(
              height: 250,
              borderRadius: BorderRadius.zero,
            ),

            // Title and rating
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextLineShimmer(widthFactor: 0.7, height: 24),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const TextLineShimmer(width: 120, height: 16),
                      const SizedBox(width: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: RectangleShimmer(width: 16, height: 16),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TextLineShimmer(widthFactor: 0.9),
                  const SizedBox(height: 8),
                  const TextLineShimmer(widthFactor: 0.8),
                  const SizedBox(height: 8),
                  const TextLineShimmer(widthFactor: 0.7),
                ],
              ),
            ),

            // Price section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const TextLineShimmer(width: 80, height: 24),
                  const RectangleShimmer(width: 120, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
                ],
              ),
            ),

            // Description header
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: TextLineShimmer(width: 120, height: 18),
            ),

            // Description content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  TextLineShimmer(widthFactor: 0.9),
                  SizedBox(height: 8),
                  TextLineShimmer(widthFactor: 1.0),
                  SizedBox(height: 8),
                  TextLineShimmer(widthFactor: 0.95),
                  SizedBox(height: 8),
                  TextLineShimmer(widthFactor: 0.9),
                  SizedBox(height: 8),
                  TextLineShimmer(widthFactor: 0.7),
                ],
              ),
            ),

            // Similar items
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
              child: TextLineShimmer(width: 150, height: 18),
            ),
            const HorizontalListShimmer(
              itemCount: 4,
              itemWidth: 140,
              itemHeight: 180,
              itemBuilder: null,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Chat/message shimmer component
class ChatShimmer extends StatelessWidget {
  final ShimmerConfig? config;
  final int messageCount;
  final bool showOwnMessages;

  const ChatShimmer({
    super.key,
    this.config,
    this.messageCount = 6,
    this.showOwnMessages = true,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      config: config ?? const ShimmerConfig(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: messageCount,
        itemBuilder: (context, index) {
          final bool isOwnMessage = showOwnMessages && index % 2 == 0;

          return Align(
            alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextLineShimmer(widthFactor: (index % 3 + 1) / 4 + 0.3),
                  if (index % 2 == 0) ...[
                    const SizedBox(height: 6),
                    TextLineShimmer(widthFactor: (index % 5 + 1) / 6 + 0.2),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Factory class to easily create different shimmer components
class ShimmerFactory {
  static Widget createHomeShimmer({ShimmerConfig? config}) {
    return HomePageShimmer(config: config);
  }

  static Widget createProfileShimmer({ShimmerConfig? config}) {
    return ProfilePageShimmer(config: config);
  }

  static Widget createDetailShimmer({ShimmerConfig? config}) {
    return DetailPageShimmer(config: config);
  }

  static Widget createChatShimmer({
    ShimmerConfig? config,
    int messageCount = 6,
    bool showOwnMessages = true,
  }) {
    return ChatShimmer(
      config: config,
      messageCount: messageCount,
      showOwnMessages: showOwnMessages,
    );
  }

  static Widget createCustomShimmer({
    required Widget child,
    ShimmerConfig? config,
  }) {
    return ShimmerLoading(
      config: config ?? const ShimmerConfig(),
      child: child,
    );
  }
}