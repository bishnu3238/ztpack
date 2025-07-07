import 'package:flutter/material.dart';

/// A utility class for responsive design in Flutter applications.
/// Handles screen size detection and responsive rendering.
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  /// Determines if the current device is a mobile device based on screen width.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  /// Determines if the current device is a tablet based on screen width.
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
          MediaQuery.of(context).size.width >= 850;

  /// Determines if the current device is a desktop based on screen width.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // If our width is more than 1100 then we consider it a desktop
    if (size.width >= 1100) {
      return desktop;
    }
    // If width it less then 1100 and more then 850 we consider it as tablet
    else if (size.width >= 850 && tablet != null) {
      return tablet!;
    }
    // Or less then that we called it mobile
    else {
      return mobile;
    }
  }
}

/// Core class providing responsive sizing and styling utilities.
class AppThemeConfig {
  /// Singleton instance
  static final AppThemeConfig _instance = AppThemeConfig._internal();

  /// Factory constructor to return the singleton instance
  factory AppThemeConfig() => _instance;

  /// Internal constructor
  AppThemeConfig._internal();

  /// Theme data for the application
  late ThemeData _themeData;

  /// Current device type
  late DeviceType _deviceType;

  /// Screen size
  late Size _screenSize;

  /// Text scale factor
  late double _textScaleFactor;

  /// Initialize the theme configuration with the build context
  void init(BuildContext context) {
    _themeData = Theme.of(context);
    _screenSize = MediaQuery.of(context).size;
    _textScaleFactor = MediaQuery.of(context).textScaleFactor;

    if (Responsive.isMobile(context)) {
      _deviceType = DeviceType.mobile;
    } else if (Responsive.isTablet(context)) {
      _deviceType = DeviceType.tablet;
    } else {
      _deviceType = DeviceType.desktop;
    }
  }

  /// Get the current device type
  DeviceType get deviceType => _deviceType;

  /// Get the current screen size
  Size get screenSize => _screenSize;

  /// Get the text scale factor
  double get textScaleFactor => _textScaleFactor;

  /// Get the theme data
  ThemeData get theme => _themeData;

  /// Calculate font size based on device type and scale factor
  double fontSize(FontSize size) {
    double baseSize;

    switch (size) {
      case FontSize.tiny:
        baseSize = 10;
        break;
      case FontSize.small:
        baseSize = 12;
        break;
      case FontSize.regular:
        baseSize = 14;
        break;
      case FontSize.medium:
        baseSize = 16;
        break;
      case FontSize.large:
        baseSize = 18;
        break;
      case FontSize.xLarge:
        baseSize = 20;
        break;
      case FontSize.xxLarge:
        baseSize = 24;
        break;
      case FontSize.heading:
        baseSize = 28;
        break;
      case FontSize.title:
        baseSize = 32;
        break;
    }

    // Adjust size based on device type
    switch (_deviceType) {
      case DeviceType.mobile:
        return baseSize * 0.9 * _textScaleFactor;
      case DeviceType.tablet:
        return baseSize * 1.0 * _textScaleFactor;
      case DeviceType.desktop:
        return baseSize * 1.1 * _textScaleFactor;
    }
  }

  /// Calculate spacing/margin/padding based on device type
  double spacing(SpacingSize size) {
    double baseSize;

    switch (size) {
      case SpacingSize.tiny:
        baseSize = 4;
        break;
      case SpacingSize.small:
        baseSize = 8;
        break;
      case SpacingSize.regular:
        baseSize = 12;
        break;
      case SpacingSize.medium:
        baseSize = 16;
        break;
      case SpacingSize.large:
        baseSize = 24;
        break;
      case SpacingSize.xLarge:
        baseSize = 32;
        break;
      case SpacingSize.xxLarge:
        baseSize = 48;
        break;
    }

    // Adjust size based on device type
    switch (_deviceType) {
      case DeviceType.mobile:
        return baseSize * 0.9;
      case DeviceType.tablet:
        return baseSize * 1.0;
      case DeviceType.desktop:
        return baseSize * 1.2;
    }
  }

  /// Get app bar height based on device type
  double get appBarHeight {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 56.0;
      case DeviceType.tablet:
        return 64.0;
      case DeviceType.desktop:
        return 72.0;
    }
  }

  /// Get bottom bar height based on device type
  double get bottomBarHeight {
    switch (_deviceType) {
      case DeviceType.mobile:
        return 56.0;
      case DeviceType.tablet:
        return 60.0;
      case DeviceType.desktop:
        return 64.0;
    }
  }

  /// Get icon size based on device type
  double iconSize(IconSize size) {
    double baseSize;

    switch (size) {
      case IconSize.small:
        baseSize = 16;
        break;
      case IconSize.regular:
        baseSize = 24;
        break;
      case IconSize.medium:
        baseSize = 32;
        break;
      case IconSize.large:
        baseSize = 48;
        break;
    }

    // Adjust size based on device type
    switch (_deviceType) {
      case DeviceType.mobile:
        return baseSize * 0.9;
      case DeviceType.tablet:
        return baseSize * 1.0;
      case DeviceType.desktop:
        return baseSize * 1.1;
    }
  }
}

/// A responsive app bar that adapts to the device type
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final bool centerTitle;
  final double? elevation;

  const ResponsiveAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.centerTitle = true,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = AppThemeConfig();
    appTheme.init(context);

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: appTheme.fontSize(FontSize.large),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor ?? appTheme.theme.primaryColor,
      elevation: elevation ?? 4.0,
      toolbarHeight: appTheme.appBarHeight,
    );
  }

  @override
  Size get preferredSize {
    final appTheme = AppThemeConfig();
    return Size.fromHeight(appTheme.appBarHeight);
  }
}

/// A responsive bottom navigation bar that adapts to the device type
class ResponsiveBottomBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;

  const ResponsiveBottomBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = AppThemeConfig();
    appTheme.init(context);

    return Container(
      height: appTheme.bottomBarHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? appTheme.theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedFontSize: appTheme.fontSize(FontSize.small),
        unselectedFontSize: appTheme.fontSize(FontSize.tiny),
        selectedItemColor: appTheme.theme.primaryColor,
        unselectedItemColor: appTheme.theme.disabledColor,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}

/// A responsive text widget that adapts its size based on device type
class ResponsiveText extends StatelessWidget {
  final String text;
  final FontSize fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText({
    Key? key,
    required this.text,
    this.fontSize = FontSize.regular,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = AppThemeConfig();
    appTheme.init(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: appTheme.fontSize(fontSize),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A responsive padding widget that adapts its size based on device type
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final SpacingSize all;
  final EdgeInsetsGeometry? padding;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.all = SpacingSize.regular,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = AppThemeConfig();
    appTheme.init(context);

    return Padding(
      padding: padding ?? EdgeInsets.all(appTheme.spacing(all)),
      child: child,
    );
  }
}

/// A responsive margin widget that adapts its size based on device type
class ResponsiveMargin extends StatelessWidget {
  final Widget child;
  final SpacingSize all;
  final EdgeInsetsGeometry? margin;

  const ResponsiveMargin({
    Key? key,
    required this.child,
    this.all = SpacingSize.regular,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = AppThemeConfig();
    appTheme.init(context);

    return Container(
      margin: margin ?? EdgeInsets.all(appTheme.spacing(all)),
      child: child,
    );
  }
}

/// A responsive icon that adapts its size based on device type
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final IconSize size;
  final Color? color;

  const ResponsiveIcon({
    Key? key,
    required this.icon,
    this.size = IconSize.regular,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = AppThemeConfig();
    appTheme.init(context);

    return Icon(
      icon,
      size: appTheme.iconSize(size),
      color: color,
    );
  }
}

/// A responsive scaffold that includes responsive app bar and bottom bar
class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final List<BottomNavigationBarItem>? bottomBarItems;
  final int currentIndex;
  final ValueChanged<int>? onBottomBarTap;

  const ResponsiveScaffold({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.drawer,
    this.floatingActionButton,
    this.bottomBarItems,
    this.currentIndex = 0,
    this.onBottomBarTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: title,
        actions: actions,
      ),
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBarItems != null && onBottomBarTap != null
          ? ResponsiveBottomBar(
        items: bottomBarItems!,
        currentIndex: currentIndex,
        onTap: onBottomBarTap!,
      )
          : null,
    );
  }
}

/// A responsive screen wrapper that handles orientation and device type
class ResponsiveScreen extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType, Orientation orientation) builder;

  const ResponsiveScreen({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = AppThemeConfig();
    appTheme.init(context);

    return OrientationBuilder(
      builder: (context, orientation) {
        return builder(context, appTheme.deviceType, orientation);
      },
    );
  }
}

/// Utility class to manage error handling and exceptions
class ResponsiveErrorHandler {
  static Widget handleError({
    required BuildContext context,
    required Widget Function() builder,
    required Widget Function(Object error) errorBuilder,
  }) {
    try {
      return builder();
    } catch (e) {
      debugPrint('ResponsiveErrorHandler: $e');
      return errorBuilder(e);
    }
  }

  static Widget defaultErrorWidget(BuildContext context, Object error) {
    final appTheme = AppThemeConfig();
    appTheme.init(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(appTheme.spacing(SpacingSize.large)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: appTheme.iconSize(IconSize.large),
            ),
            SizedBox(height: appTheme.spacing(SpacingSize.medium)),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: appTheme.fontSize(FontSize.large),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: appTheme.spacing(SpacingSize.small)),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: appTheme.fontSize(FontSize.regular),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Enum for defining device types
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Enum for defining font sizes
enum FontSize {
  tiny,
  small,
  regular,
  medium,
  large,
  xLarge,
  xxLarge,
  heading,
  title,
}

/// Enum for defining spacing sizes
enum SpacingSize {
  tiny,
  small,
  regular,
  medium,
  large,
  xLarge,
  xxLarge,
}

/// Enum for defining icon sizes
enum IconSize {
  small,
  regular,
  medium,
  large,
}