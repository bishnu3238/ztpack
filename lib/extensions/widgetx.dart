
import 'package:flutter/material.dart';
/// Widget extensions for common operations
extension WidgetX on Widget {
  // Padding
  Widget paddingAll(double value) => Padding(
    padding: EdgeInsets.all(value),
    child: this,
  );

  Widget paddingSymmetric({double horizontal = 0.0, double vertical = 0.0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  Widget paddingOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left, top: top, right: right, bottom: bottom,
    ),
    child: this,
  );

  // Margin using Container
  Widget marginAll(double value) => Container(
    margin: EdgeInsets.all(value),
    child: this,
  );

  Widget marginSymmetric({double horizontal = 0.0, double vertical = 0.0}) => Container(
    margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
    child: this,
  );

  Widget marginOnly({
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) => Container(
    margin: EdgeInsets.only(
      left: left, top: top, right: right, bottom: bottom,
    ),
    child: this,
  );

  // Alignment
  Widget center() => Center(child: this);
  Widget alignAtStart() => Align(alignment: Alignment.centerLeft, child: this);
  Widget alignAtEnd() => Align(alignment: Alignment.centerRight, child: this);
  Widget alignAtTop() => Align(alignment: Alignment.topCenter, child: this);
  Widget alignAtBottom() => Align(alignment: Alignment.bottomCenter, child: this);
  Widget align(Alignment alignment) => Align(alignment: alignment, child: this);

  // Decoration
  Widget decorated({
    Color? color,
    BorderRadius? borderRadius,
    BoxBorder? border,
    List<BoxShadow>? boxShadow,
    Gradient? gradient,
    DecorationImage? image,
    BoxShape shape = BoxShape.rectangle,
  }) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      border: border,
      boxShadow: boxShadow,
      gradient: gradient,
      image: image,
      shape: shape,
    ),
    child: this,
  );

  // Size constraints
  Widget constrained({
   
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) => ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: minWidth ?? 0.0,
      maxWidth: maxWidth ?? double.infinity,
      minHeight: minHeight ?? 0.0,
      maxHeight: maxHeight ?? double.infinity,

    ).copyWith(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,

    ),
    child: this,
  );

  Widget width(double width) => SizedBox(width: width, child: this);
  Widget height(double height) => SizedBox(height: height, child: this);
  Widget size({required double width, required double height}) =>
      SizedBox(width: width, height: height, child: this);

  // Gesture handling
  Widget onTap(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: this,
  );

  Widget onDoubleTap(VoidCallback onDoubleTap) => GestureDetector(
    onDoubleTap: onDoubleTap,
    child: this,
  );

  Widget onLongPress(VoidCallback onLongPress) => GestureDetector(
    onLongPress: onLongPress,
    child: this,
  );

  // Tooltip
  Widget withTooltip(String message) => Tooltip(
    message: message,
    child: this,
  );

  // Visibility
  Widget visible(bool visible) => Visibility(
    visible: visible,
    child: this,
  );

  Widget visibleOrSpace(bool visible) => Visibility(
    visible: visible,
    child: this,
    replacement: const SizedBox.shrink(),
  );

  // Hero animation
  Widget hero(String tag) => Hero(
    tag: tag,
    child: this,
  );

  // Clipper utilities
  Widget clipRRect(BorderRadius borderRadius) => ClipRRect(
    borderRadius: borderRadius,
    child: this,
  );

  Widget clipOval() => ClipOval(child: this);
  Widget clipCircle() => ClipOval(child: this);

  // Expanded and Flexible
  Widget expanded({int flex = 1}) => Expanded(
    flex: flex,
    child: this,
  );

  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) => Flexible(
    flex: flex,
    fit: fit,
    child: this,
  );

  // Opacity
  Widget opacity(double opacity) => Opacity(
    opacity: opacity,
    child: this,
  );

  // Rotation and transformation
  Widget rotate(double angle) => Transform.rotate(
    angle: angle,
    child: this,
  );

  Widget scale(double scale) => Transform.scale(
    scale: scale,
    child: this,
  );

  Widget translate({required Offset offset}) => Transform.translate(
    offset: offset,
    child: this,
  );

  // Material elevation
  Widget material({
    double elevation = 1.0,
    Color? color,
    Color? shadowColor,
    BorderRadius? borderRadius,
  }) => Material(
    elevation: elevation,
    color: color ?? Colors.transparent,
    shadowColor: shadowColor,
    borderRadius: borderRadius,
    child: this,
  );

  // Card wrapper
  Widget card({
    double elevation = 1.0,
    Color? color,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
  }) => Card(
    elevation: elevation,
    color: color,
    margin: margin ?? EdgeInsets.zero,
    shape: borderRadius != null
        ? RoundedRectangleBorder(borderRadius: borderRadius)
        : null,
    child: this,
  );

  // Ink well for splash effect
  Widget inkWell({
    VoidCallback? onTap,
    VoidCallback? onDoubleTap,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
  }) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      borderRadius: borderRadius,
      splashColor: splashColor,
      highlightColor: highlightColor,
      child: this,
    ),
  );
}
