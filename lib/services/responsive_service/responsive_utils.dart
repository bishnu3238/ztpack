import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pack/services/service.dart';

/// A utility class that provides responsive sizing and styling methods
/// to ensure consistent UI across different device sizes.
class ResponsiveUtils {
  late MediaQueryData _mediaQueryData;
  late double _screenWidth;
  late double _screenHeight;
  late double _safeAreaHeight;
  late double _blockSizeHorizontal;
  late double _blockSizeVertical;
  late Orientation _orientation;

  // Singleton instance
  static final ResponsiveUtils _instance = ResponsiveUtils._internal();

  // Figma design dimensions - can be customized based on your design
  static const num figmaDesignWidth = 360;
  static const num figmaDesignHeight = 640;
  static const num figmaDesignStatusBar = 0;

  // Screen size breakpoints for responsive design
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 900;

  // Accessibility factors
  double _textScaleFactor = 1.0;

  /// Factory constructor to return the singleton instance
  factory ResponsiveUtils() {
    return _instance;
  }

  /// Private constructor for singleton pattern
  ResponsiveUtils._internal();

  /// Initialize the utility with the BuildContext.
  /// This method should be called in the app's main widget.
  /// 
  /// Example usage:
  /// ```dart
  /// void main() {
  ///   runApp(MyApp());
  /// }
  /// 
  /// class MyApp extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return MaterialApp(
  ///       home: Builder(
  ///         builder: (context) {
  ///           ResponsiveUtils().initialize(context);
  ///           return MyHomePage();
  ///         },
  ///       ),
  ///     );
  ///   }
  /// }
  /// ```
  void initialize(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _textScaleFactor = _mediaQueryData.textScaleFactor;
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    _orientation = _mediaQueryData.orientation;

    // Calculate height excluding status bar and bottom navigation bar
    double statusBarHeight = _mediaQueryData.viewPadding.top;
    double bottomBarHeight = _mediaQueryData.viewPadding.bottom;
    _safeAreaHeight = _screenHeight - statusBarHeight - bottomBarHeight;

    // Calculate block sizes for responsive calculations
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _safeAreaHeight / 100;
  }

  /// Reinitializes the utility to handle orientation changes or window resizing
  void reinitialize(BuildContext context) {
    initialize(context);
  }

  /// Returns the current device orientation
  Orientation get orientation => _orientation;

  /// Returns the total screen width including unsafe areas
  double get screenWidth => _screenWidth;

  /// Returns the total screen height including unsafe areas
  double get screenHeight => _screenHeight;

  /// Returns the safe area height (excluding status bar and bottom navigation bar)
  double get safeAreaHeight => _safeAreaHeight;

  /// Determines if the current device is a phone based on width
  bool get isPhone => _screenWidth < phoneMaxWidth;

  /// Determines if the current device is a tablet based on width
  bool get isTablet => _screenWidth >= phoneMaxWidth && _screenWidth < tabletMaxWidth;

  /// Determines if the current device is a desktop or large tablet
  bool get isDesktop => _screenWidth >= tabletMaxWidth;

  /// Calculates horizontal size based on the design width
  /// 
  /// Example: `width: getHorizontalSize(120)`
  double getHorizontalSize(double px) {
    if (figmaDesignWidth == 0) return px;
    return ((px * _screenWidth) / figmaDesignWidth).clamp(0, double.infinity);
  }

  /// Calculates vertical size based on the design height
  /// 
  /// Example: `height: getVerticalSize(50)`
  double getVerticalSize(double px) {
    if ((figmaDesignHeight - figmaDesignStatusBar) == 0) return px;
    return ((px * _safeAreaHeight) / (figmaDesignHeight - figmaDesignStatusBar))
        .clamp(0, double.infinity);
  }

  /// Returns the smaller of horizontal and vertical size calculations
  /// Useful for elements that should be proportionally sized
  /// 
  /// Example: `size: getSize(24)`
  double getSize(double px) {
    double height = getVerticalSize(px);
    double width = getHorizontalSize(px);
    return (height < width ? height : width).toDoubleValue();
  }

  /// Calculates font size considering both design specifications and device accessibility settings
  /// 
  /// Example: `fontSize: getFontSize(16)`
  double getFontSize(double px, {bool considerAccessibility = true}) {
    double calculatedSize = getSize(px);
    return considerAccessibility
        ? (calculatedSize * _textScaleFactor).clamp(px * 0.7, px * 1.5)
        : calculatedSize;
  }

  /// Creates responsive padding based on the design specifications
  /// 
  /// Example: `padding: getPadding(left: 16, top: 8, right: 16, bottom: 20)`
  EdgeInsets getPadding({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return _getInsets(all: all, left: left, top: top, right: right, bottom: bottom);
  }

  /// Creates responsive margin based on the design specifications
  /// 
  /// Example: `margin: getMargin(all: 16)`
  EdgeInsets getMargin({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return _getInsets(all: all, left: left, top: top, right: right, bottom: bottom);
  }

  /// Internal method to calculate EdgeInsets for both margin and padding
  EdgeInsets _getInsets({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      left = all;
      top = all;
      right = all;
      bottom = all;
    }
    return EdgeInsets.only(
      left: getHorizontalSize(left ?? 0),
      top: getVerticalSize(top ?? 0),
      right: getHorizontalSize(right ?? 0),
      bottom: getVerticalSize(bottom ?? 0),
    );
  }

  /// Creates responsive border radius
  /// 
  /// Example: `borderRadius: getBorderRadius(all: 8)`
  BorderRadius getBorderRadius({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomRight,
    double? bottomLeft,
  }) {
    if (all != null) {
      topLeft = all;
      topRight = all;
      bottomRight = all;
      bottomLeft = all;
    }
    return BorderRadius.only(
      topLeft: Radius.circular(getSize(topLeft ?? 0)),
      topRight: Radius.circular(getSize(topRight ?? 0)),
      bottomRight: Radius.circular(getSize(bottomRight ?? 0)),
      bottomLeft: Radius.circular(getSize(bottomLeft ?? 0)),
    );
  }

  /// Creates a responsive RoundedRectangleBorder
  /// 
  /// Example: `shape: getRoundedRectangleBorder(all: 12)`
  RoundedRectangleBorder getRoundedRectangleBorder({
    double? all,
    double? topLeft,
    double? topRight,
    double? bottomRight,
    double? bottomLeft,
    Color borderColor = Colors.transparent,
    double borderWidth = 0,
  }) {
    return RoundedRectangleBorder(
      borderRadius: getBorderRadius(
        all: all,
        topLeft: topLeft,
        topRight: topRight,
        bottomRight: bottomRight,
        bottomLeft: bottomLeft,
      ),
      side: BorderSide(
        color: borderColor,
        width: getSize(borderWidth),
      ),
    );
  }

  /// Calculate responsive width as percentage of screen width
  /// 
  /// Example: `width: widthPercent(50)` for 50% of screen width
  double widthPercent(double percent) {
    return (percent * _blockSizeHorizontal).clamp(0, _screenWidth);
  }

  /// Calculate responsive height as percentage of safe area height
  /// 
  /// Example: `height: heightPercent(30)` for 30% of safe area height
  double heightPercent(double percent) {
    return (percent * _blockSizeVertical).clamp(0, _safeAreaHeight);
  }

  /// Calculate a responsive value that adapts between given minimum and maximum values
  /// based on screen size, useful for creating fluid designs
  /// 
  /// Example: `fontSize: adaptiveSizeValue(12, 24, 375, 900)`
  double adaptiveSizeValue(
      double minValue,
      double maxValue,
      double minScreenSize,
      double maxScreenSize
      ) {
    if (_screenWidth <= minScreenSize) return minValue;
    if (_screenWidth >= maxScreenSize) return maxValue;

    // Calculate how far between the min and max screen sizes we are
    double screenRatio = (_screenWidth - minScreenSize) / (maxScreenSize - minScreenSize);

    // Return a proportional value between minValue and maxValue
    return minValue + (maxValue - minValue) * screenRatio;
  }

  /// Get a value based on device type (phone, tablet, desktop)
  /// 
  /// Example: `padding: valueByDeviceType(phone: 8, tablet: 16, desktop: 24)`
  T valueByDeviceType<T>({
    required T phone,
    required T tablet,
    required T desktop,
  }) {
    if (isPhone) return phone;
    if (isTablet) return tablet;
    return desktop;
  }
}

