import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImageSource { network, asset, file, memory, svg }

enum ImageShape { normal, circle, rounded, star, custom }

class ImageView extends StatelessWidget {
  /// The source of the image
  final ImageSource source;

  /// Image path, URL, or data depending on the source
  final String? path;

  /// Raw image data for memory images
  final Uint8List? memoryData;

  /// Width of the image
  final double? width;

  /// Height of the image
  final double? height;

  /// How to fit the image in its container
  final BoxFit fit;

  /// Color to apply over the image
  final Color? color;

  /// Color filter to apply to the image
  final ColorFilter? colorFilter;

  /// Border radius for rounded images
  final BorderRadius? borderRadius;

  /// Border for the image container
  final BoxBorder? border;

  /// Background color for the image container
  final Color? backgroundColor;

  /// Shape of the image
  final ImageShape shape;

  /// Radius for circle and rounded shapes
  final double radius;

  /// Custom shape for the image
  final ShapeBorder? customShape;

  /// Placeholder widget to show while loading
  final Widget? placeholder;

  /// Error widget to show if image fails to load
  final Widget? errorWidget;

  /// Default placeholder asset path
  final String placeholderAssetPath;

  /// Callback when image is tapped
  final VoidCallback? onTap;

  /// Margin around the image
  final EdgeInsetsGeometry? margin;

  /// Alignment of the image
  final Alignment? alignment;

  /// Points for star shape
  final int starPoints;

  /// Inner radius ratio for star shape
  final double starInnerRadiusRatio;

  /// Shadow for the image container
  final List<BoxShadow>? shadows;

  /// Whether to cache the network image
  final bool cacheNetworkImage;

  /// Whether to use old image on URL change for network images
  final bool useOldImageOnUrlChange;

  /// Duration of fade transition for network images
  final Duration fadeInDuration;

  /// Package name
  final String? package;

  /// Creates an advanced image widget
  const ImageView({
    super.key,
    required this.source,
    this.path,
    this.memoryData,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.colorFilter,
    this.borderRadius,
    this.border,
    this.backgroundColor,
    this.shape = ImageShape.normal,
    this.radius = 8,
    this.customShape,
    this.placeholder,
    this.errorWidget,
    this.placeholderAssetPath = 'assets/images/placeholder.png',
    this.onTap,
    this.margin,
    this.alignment,
    this.starPoints = 5,
    this.starInnerRadiusRatio = 0.5,
    this.shadows,
    this.cacheNetworkImage = true,
    this.useOldImageOnUrlChange = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.package,
  });

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(alignment: alignment!, child: _buildWrappedWidget())
        : _buildWrappedWidget();
  }

  Widget _buildWrappedWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(onTap: onTap, child: _buildShapedWidget()),
    );
  }

  Widget _buildShapedWidget() {
    switch (shape) {
      case ImageShape.circle:
        return _buildCircleImage();
      case ImageShape.rounded:
        return _buildRoundedImage();
      case ImageShape.star:
        return _buildStarImage();
      case ImageShape.custom:
        return _buildCustomShapeImage();
      case ImageShape.normal:
      default:
        return _buildBorderedImage();
    }
  }

  Widget _buildCircleImage() {
    return ClipOval(child: _buildBorderedImage());
  }

  Widget _buildRoundedImage() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      child: _buildBorderedImage(),
    );
  }

  Widget _buildStarImage() {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: StarBorder(
          points: starPoints,
          innerRadiusRatio: starInnerRadiusRatio,
          pointRounding: 0.2,
        ),
        image: DecorationImage(
          image: _getImageProvider(),
          fit: fit,
          colorFilter: colorFilter,
        ),
        shadows: shadows,
      ),
    );
  }

  Widget _buildCustomShapeImage() {
    if (customShape == null) {
      return _buildRoundedImage();
    }

    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: customShape!,
        image: DecorationImage(
          image: _getImageProvider(),
          fit: fit,
          colorFilter: colorFilter,
        ),
        shadows: shadows,
      ),
    );
  }

  Widget _buildBorderedImage() {
    if (border != null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius:
              shape == ImageShape.rounded
                  ? borderRadius ?? BorderRadius.circular(radius)
                  : null,
          boxShadow: shadows,
        ),
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  ImageProvider _getImageProvider() {
    switch (source) {
      case ImageSource.network:
        return CachedNetworkImageProvider(path!);
      case ImageSource.asset:
        return AssetImage(path!, package: package);
      case ImageSource.file:
        return FileImage(File(path!));
      case ImageSource.memory:
        return MemoryImage(memoryData!);
      case ImageSource.svg:
        // SVG can't be used with ImageProvider directly
        return AssetImage(placeholderAssetPath);
    }
  }

  Widget _buildImageView() {
    switch (source) {
      case ImageSource.network:
        return _buildNetworkImage();
      case ImageSource.asset:
        return Image.asset(
          path!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          alignment: alignment ?? Alignment.center,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
          package: package,
        );
      case ImageSource.file:
        return Image.file(
          File(path!),
          width: width,
          height: height,
          fit: fit,
          color: color,
          alignment: alignment ?? Alignment.center,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      case ImageSource.memory:
        return Image.memory(
          memoryData!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          alignment: alignment ?? Alignment.center,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      case ImageSource.svg:
        return path!.startsWith('http')
            ? SvgPicture.network(
              path!,
              width: width,
              height: height,
              fit: fit,
              color: color,
              alignment: alignment ?? Alignment.center,
              placeholderBuilder: (context) => _buildPlaceholder(),
            )
            : SvgPicture.asset(
              path!,
              width: width,
              height: height,
              fit: fit,
              color: color,
              alignment: alignment ?? Alignment.center,
            );
    }
  }

  Widget _buildNetworkImage() {
    if (!cacheNetworkImage) {
      return Image.network(
        path!,
        width: width,
        height: height,
        fit: fit,
        color: color,
        alignment: alignment ?? Alignment.center,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    return CachedNetworkImage(
      imageUrl: path!,
      width: width,
      height: height,
      fit: fit,
      color: color,
      alignment: alignment ?? Alignment.center,
      fadeInDuration: fadeInDuration,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      imageBuilder:
          (context, imageProvider) => Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              image: DecorationImage(
                image: imageProvider,
                fit: fit,
                colorFilter: colorFilter,
              ),
            ),
          ),
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: backgroundColor ?? Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.grey.shade400,
              strokeWidth: 2,
            ),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: backgroundColor ?? Colors.grey.shade200,
          child: Center(
            child: ClipRRect(
              // borderRadius: BorderRadius.circular(radius)
              child: Image.asset(
                placeholderAssetPath,
                width: width != null ? width! * 0.5 : 50,
                height: height != null ? height! * 0.5 : 50,
                fit: BoxFit.contain,
                package: package ?? 'pack',
              ),
            ),
          ),
        );
  }
}

// Star border shape for star-shaped images
class StarBorder extends ShapeBorder {
  final int points;
  final double innerRadiusRatio;
  final double pointRounding;

  const StarBorder({
    this.points = 5,
    this.innerRadiusRatio = 0.5,
    this.pointRounding = 0.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final center = rect.center;
    final outerRadius =
        rect.width < rect.height ? rect.width / 2 : rect.height / 2;
    final innerRadius = outerRadius * innerRadiusRatio;

    final path = Path();
    final startAngle = -math.pi / 2;
    final angleIncrement = 2 * math.pi / (points * 2);

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = startAngle + (i * angleIncrement);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) {
    return StarBorder(
      points: points,
      innerRadiusRatio: innerRadiusRatio,
      pointRounding: pointRounding * t,
    );
  }
}
