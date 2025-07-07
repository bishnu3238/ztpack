import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// A comprehensive utility class that provides advanced responsive sizing and styling methods
/// to ensure consistent UI across different device sizes and orientations.
class ScreenUtils {
  late MediaQueryData _mediaQueryData;
  late double _screenWidth;
  late double _screenHeight;
  late double _safeAreaHeight;
  late double _safeAreaWidth;
  late double _blockSizeHorizontal;
  late double _blockSizeVertical;
  late Orientation _orientation;
  late DeviceType _deviceType;

  // Singleton instance
  static final ScreenUtils _instance = ScreenUtils._internal();

  // Figma design dimensions - can be customized based on your design
  static const num figmaDesignWidth = 360;
  static const num figmaDesignHeight = 640;
  static const num figmaDesignStatusBar = 0;

  // Screen size breakpoints for responsive design
  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1200;

  // Device pixel ratio
  late double _pixelRatio;

  // Accessibility factors
  double _textScaleFactor = 1.0;

  // Default scale factor for different device types
  final Map<DeviceType, double> _deviceScaleFactor = {
    DeviceType.phone: 1.0,
    DeviceType.tablet: 1.2,
    DeviceType.desktop: 1.5,
  };

  /// Factory constructor to return the singleton instance
  factory ScreenUtils() {
    return _instance;
  }

  /// Private constructor for singleton pattern
  ScreenUtils._internal();

  /// Initialize the utility with the BuildContext.
  /// This method should be called in the app's main widget or using a builder pattern.
  void initialize(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _pixelRatio = _mediaQueryData.devicePixelRatio;
    _textScaleFactor = _mediaQueryData.textScaleFactor;
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
    _orientation = _mediaQueryData.orientation;

    // Calculate safe area dimensions
    double statusBarHeight = _mediaQueryData.viewPadding.top;
    double bottomBarHeight = _mediaQueryData.viewPadding.bottom;
    double leftPadding = _mediaQueryData.viewPadding.left;
    double rightPadding = _mediaQueryData.viewPadding.right;

    _safeAreaHeight = _screenHeight - statusBarHeight - bottomBarHeight;
    _safeAreaWidth = _screenWidth - leftPadding - rightPadding;

    // Calculate block sizes for responsive calculations
    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _safeAreaHeight / 100;

    // Determine device type
    _deviceType = _determineDeviceType();
  }

  /// Determines the device type based on width, pixel ratio, and platform
  DeviceType _determineDeviceType() {
    // For desktop platforms
    if (isDesktopPlatform()) {
      return DeviceType.desktop;
    }

    // For mobile platforms
    if (_screenWidth < phoneMaxWidth) {
      return DeviceType.phone;
    } else if (_screenWidth < tabletMaxWidth) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Checks if the current platform is a desktop platform
  bool isDesktopPlatform() {
    return ui.PlatformDispatcher.instance.views.first.physicalSize.width > 1200;
  }

  /// Creates a widget that automatically initializes ResponsiveUtils and
  /// rebuilds children when screen size changes or device orientation changes
  static Widget builder({
    required Widget Function(BuildContext context) builder,
  }) {
    return Builder(
      builder: (context) {
        ScreenUtils().initialize(context);
        return builder(context);
      },
    );
  }

  /// Returns a LayoutBuilder that provides viewport constraints to the builder
  static Widget layoutBuilder({
    required Widget Function(BuildContext context, BoxConstraints constraints) builder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ScreenUtils().initialize(context);
        return builder(context, constraints);
      },
    );
  }

  /// Creates a responsive OrientationBuilder that handles orientation changes
  static Widget orientationBuilder({
    required Widget Function(BuildContext context, Orientation orientation) builder,
  }) {
    return OrientationBuilder(
      builder: (context, orientation) {
        ScreenUtils().initialize(context);
        return builder(context, orientation);
      },
    );
  }

  /// Returns the current device orientation
  Orientation get orientation => _orientation;

  /// Returns the current device type
  DeviceType get deviceType => _deviceType;

  /// Returns the total screen width including unsafe areas
  double get screenWidth => _screenWidth;

  /// Returns the total screen height including unsafe areas
  double get screenHeight => _screenHeight;

  /// Returns the safe area width
  double get safeAreaWidth => _safeAreaWidth;

  /// Returns the safe area height
  double get safeAreaHeight => _safeAreaHeight;

  /// Returns the device pixel ratio
  double get pixelRatio => _pixelRatio;

  /// Determines if the current device is a phone based on device type
  bool get isPhone => _deviceType == DeviceType.phone;

  /// Determines if the current device is a tablet based on device type
  bool get isTablet => _deviceType == DeviceType.tablet;

  /// Determines if the current device is a desktop or large tablet
  bool get isDesktop => _deviceType == DeviceType.desktop;

  /// Determines if the device is in landscape orientation
  bool get isLandscape => _orientation == Orientation.landscape;

  /// Determines if the device is in portrait orientation
  bool get isPortrait => _orientation == Orientation.portrait;

  /// Calculates horizontal size based on the design width
  double getHorizontalSize(double px) {
    if (figmaDesignWidth == 0) return px;
    double calculatedSize = ((px * _screenWidth) / figmaDesignWidth).clamp(0, double.infinity);
    return _applyDeviceScaleFactor(calculatedSize);
  }

  /// Calculates vertical size based on the design height
  double getVerticalSize(double px) {
    if ((figmaDesignHeight - figmaDesignStatusBar) == 0) return px;
    double calculatedSize = ((px * _safeAreaHeight) / (figmaDesignHeight - figmaDesignStatusBar))
        .clamp(0, double.infinity);
    return _applyDeviceScaleFactor(calculatedSize);
  }

  /// Returns the smaller of horizontal and vertical size calculations
  double getSize(double px) {
    double height = getVerticalSize(px);
    double width = getHorizontalSize(px);
    return (height < width ? height : width).toDoubleValue();
  }

  /// Calculates font size considering both design specifications and device accessibility settings
  double getFontSize(double px, {
    bool considerAccessibility = true,
    bool applyDeviceSpecificScaling = true,
  }) {
    double calculatedSize = getSize(px);

    if (applyDeviceSpecificScaling) {
      calculatedSize = _applyDeviceScaleFactor(calculatedSize);
    }

    if (considerAccessibility) {
      calculatedSize = (calculatedSize * _textScaleFactor).clamp(px * 0.7, px * 1.5);
    }

    return calculatedSize;
  }

  /// Applies device-specific scaling factor
  double _applyDeviceScaleFactor(double value) {
    return value * (_deviceScaleFactor[_deviceType] ?? 1.0);
  }

  /// Creates responsive padding based on the design specifications
  EdgeInsets getPadding({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    bool? symmetric,
    double? horizontal,
    double? vertical,
  }) {
    return _getInsets(
      all: all,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  /// Creates responsive margin based on the design specifications
  EdgeInsets getMargin({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) {
    return _getInsets(
      all: all,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  /// Internal method to calculate EdgeInsets for both margin and padding
  EdgeInsets _getInsets({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
  }) {
    if (all != null) {
      left = all;
      top = all;
      right = all;
      bottom = all;
    }

    if (horizontal != null) {
      left = horizontal;
      right = horizontal;
    }

    if (vertical != null) {
      top = vertical;
      bottom = vertical;
    }

    return EdgeInsets.only(
      left: getHorizontalSize(left ?? 0),
      top: getVerticalSize(top ?? 0),
      right: getHorizontalSize(right ?? 0),
      bottom: getVerticalSize(bottom ?? 0),
    );
  }

  /// Creates responsive border radius
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
  double widthPercent(double percent) {
    return (percent * _blockSizeHorizontal).clamp(0, _screenWidth);
  }

  /// Calculate responsive height as percentage of safe area height
  double heightPercent(double percent) {
    return (percent * _blockSizeVertical).clamp(0, _safeAreaHeight);
  }

  /// Calculate a responsive value that adapts between given minimum and maximum values
  /// based on screen size, useful for creating fluid designs
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
  T valueByDeviceType<T>({
    required T phone,
    required T tablet,
    required T desktop,
  }) {
    if (isPhone) return phone;
    if (isTablet) return tablet;
    return desktop;
  }

  /// Get a value based on orientation (portrait, landscape)
  T valueByOrientation<T>({
    required T portrait,
    required T landscape,
  }) {
    return isPortrait ? portrait : landscape;
  }

  /// Get a value from a map based on screen width
  /// The keys in the map should be the minimum width thresholds
  T valueByBreakpoint<T>(Map<double, T> breakpoints) {
    // Sort breakpoints by width (ascending)
    List<double> sortedBreakpoints = breakpoints.keys.toList()..sort();

    // Find the appropriate breakpoint
    for (int i = sortedBreakpoints.length - 1; i >= 0; i--) {
      if (_screenWidth >= sortedBreakpoints[i]) {
        return breakpoints[sortedBreakpoints[i]]!;
      }
    }

    // Return the smallest breakpoint if none found
    return breakpoints[sortedBreakpoints.first]!;
  }

  /// Returns a size constraint that respects min and max boundaries
  /// while scaling proportionally to screen size
  SizeConstraint getResponsiveConstraint({
    required double idealWidth,
    required double idealHeight,
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    double width = getHorizontalSize(idealWidth);
    double height = getVerticalSize(idealHeight);

    return SizeConstraint(
      width: width,
      height: height,
      minWidth: minWidth != null ? getHorizontalSize(minWidth) : null,
      maxWidth: maxWidth != null ? getHorizontalSize(maxWidth) : null,
      minHeight: minHeight != null ? getVerticalSize(minHeight) : null,
      maxHeight: maxHeight != null ? getVerticalSize(maxHeight) : null,
    );
  }

  /// Creates a BoxConstraints object with responsive dimensions
  BoxConstraints getBoxConstraints({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    return BoxConstraints(
      minWidth: minWidth != null ? getHorizontalSize(minWidth) : 0.0,
      maxWidth: maxWidth != null ? getHorizontalSize(maxWidth) : double.infinity,
      minHeight: minHeight != null ? getVerticalSize(minHeight) : 0.0,
      maxHeight: maxHeight != null ? getVerticalSize(maxHeight) : double.infinity,
    );
  }

  /// Calculate responsive spacing for grid or list items
  double getGridSpacing(double baseSpacing) {
    return valueByDeviceType(
      phone: getSize(baseSpacing),
      tablet: getSize(baseSpacing * 1.5),
      desktop: getSize(baseSpacing * 2),
    );
  }

  /// Calculate optimal number of grid columns based on screen size
  int getOptimalGridColumns(double minItemWidth) {
    double calculatedItemWidth = getHorizontalSize(minItemWidth);
    int columns = (_screenWidth / calculatedItemWidth).floor();
    return columns > 0 ? columns : 1;
  }

  /// Creates a responsive SliverGridDelegateWithFixedCrossAxisCount
  SliverGridDelegateWithFixedCrossAxisCount getResponsiveGridDelegate({
    required double itemWidth,
    required double itemHeight,
    double spacing = 8.0,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
  }) {
    mainAxisSpacing = mainAxisSpacing ?? spacing;
    crossAxisSpacing = crossAxisSpacing ?? spacing;

    int crossAxisCount = getOptimalGridColumns(itemWidth);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: getSize(mainAxisSpacing),
      crossAxisSpacing: getSize(crossAxisSpacing),
      childAspectRatio: itemWidth / itemHeight,
    );
  }

  /// Returns a scale transform based on device type and screen size
  Matrix4 getScaleTransform({double baseScale = 1.0}) {
    double scaleValue = baseScale * (_deviceScaleFactor[_deviceType] ?? 1.0);
    return Matrix4.diagonal3Values(scaleValue, scaleValue, 1.0);
  }

  /// Returns responsive TextStyle with adaptive sizing
  TextStyle getResponsiveTextStyle({
    required double fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? height,
    TextDecoration? decoration,
    bool adaptToDeviceType = true,
    bool considerAccessibility = true,
  }) {
    return TextStyle(
      fontSize: getFontSize(
        fontSize,
        considerAccessibility: considerAccessibility,
        applyDeviceSpecificScaling: adaptToDeviceType,
      ),
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: height,
      decoration: decoration,
    );
  }

  /// Returns a Map of TextStyles for different device types
  Map<DeviceType, TextStyle> getTextStylesByDevice({
    required TextStyle baseStyle,
    TextStyle? tabletStyle,
    TextStyle? desktopStyle,
  }) {
    return {
      DeviceType.phone: baseStyle,
      DeviceType.tablet: tabletStyle ?? baseStyle.copyWith(
        fontSize: baseStyle.fontSize != null ? baseStyle.fontSize! * 1.2 : null,
      ),
      DeviceType.desktop: desktopStyle ?? baseStyle.copyWith(
        fontSize: baseStyle.fontSize != null ? baseStyle.fontSize! * 1.5 : null,
      ),
    };
  }

  /// Get a TextStyle based on current device type
  TextStyle getAdaptiveTextStyle({
    required TextStyle baseStyle,
    TextStyle? tabletStyle,
    TextStyle? desktopStyle,
  }) {
    final styles = getTextStylesByDevice(
      baseStyle: baseStyle,
      tabletStyle: tabletStyle,
      desktopStyle: desktopStyle,
    );

    return styles[_deviceType] ?? baseStyle;
  }
}

/// Extension to format double values
extension FormatExtension on double {
  /// Returns a [double] value formatted to the specified number of decimal places
  double toDoubleValue({int fractionDigits = 2}) {
    return double.parse(toStringAsFixed(fractionDigits));
  }
}


/// Class to define size constraints for responsive elements
class SizeConstraint {
  final double width;
  final double height;
  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;

  SizeConstraint({
    required this.width,
    required this.height,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
  });

  /// Convert to BoxConstraints
  BoxConstraints toBoxConstraints() {
    return BoxConstraints(
      minWidth: minWidth ?? 0.0,
      maxWidth: maxWidth ?? double.infinity,
      minHeight: minHeight ?? 0.0,
      maxHeight: maxHeight ?? double.infinity,
    );
  }
}

/// Enum for device types
enum DeviceType {
  phone,
  tablet,
  desktop,
}