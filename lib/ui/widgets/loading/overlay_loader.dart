import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

// Enhanced enum to include shimmer and lottie options
enum LoaderType {
  circular,
  linear,
  custom,
  shimmer,
  lottie,
}

// Provider class for app-wide loading state management
class LoaderProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _loadingText;
  Widget? _customIndicator;
  LoaderType _loaderType = LoaderType.circular;

  bool get isLoading => _isLoading;
  String? get loadingText => _loadingText;
  Widget? get customIndicator => _customIndicator;
  LoaderType get loaderType => _loaderType;

  void showLoader({
    String? text,
    Widget? customIndicator,
    LoaderType? loaderType,
  }) {
    _isLoading = true;
    _loadingText = text;
    _customIndicator = customIndicator;
    if (loaderType != null) _loaderType = loaderType;
    notifyListeners();
  }

  void hideLoader() {
    _isLoading = false;
    notifyListeners();
  }

  void updateText(String? text) {
    _loadingText = text;
    notifyListeners();
  }
}

// Builder class for flexible indicator placement
class LoaderPositionBuilder {
  final BuildContext context;
  final Widget indicator;
  final Size screenSize;

  LoaderPositionBuilder(this.context, this.indicator)
      : screenSize = MediaQuery.of(context).size;

  Widget centered() {
    return Center(child: indicator);
  }

  Widget topLeft({double padding = 16.0}) {
    return Positioned(
      left: padding,
      top: padding,
      child: indicator,
    );
  }

  Widget topRight({double padding = 16.0}) {
    return Positioned(
      right: padding,
      top: padding,
      child: indicator,
    );
  }

  Widget bottomLeft({double padding = 16.0}) {
    return Positioned(
      left: padding,
      bottom: padding,
      child: indicator,
    );
  }

  Widget bottomRight({double padding = 16.0}) {
    return Positioned(
      right: padding,
      bottom: padding,
      child: indicator,
    );
  }

  Widget custom({required Offset position}) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: indicator,
    );
  }

  Widget relative({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: indicator,
    );
  }
}

class OverlayLoader extends StatefulWidget {
  /// Whether the loader is currently visible
  final bool isLoading;

  /// Opacity of the overlay backdrop (0.0 - 1.0)
  final double opacity;

  /// Color of the overlay backdrop
  final Color? color;

  /// Custom position of the progress indicator
  final Offset? offset;

  /// Whether tapping the overlay dismisses it
  final bool dismissible;

  /// The widget to display beneath the overlay
  final Widget child;

  /// The blur amount applied to the background when loading
  final double blur;

  /// Type of loader to display
  final LoaderType loaderType;

  /// Custom progress indicator widget
  final Widget? progressIndicator;

  /// Size of the default progress indicator
  final double? indicatorSize;

  /// Thickness of the default progress indicator
  final double? indicatorThickness;

  /// Color of the default progress indicator
  final Color? indicatorColor;

  /// Animation duration for showing/hiding the loader
  final Duration animationDuration;

  /// Text to display beneath the loader
  final String? loadingText;

  /// Text style for the loading text
  final TextStyle? loadingTextStyle;

  /// Callback when loading state changes
  final Function(bool)? onLoadingChanged;

  /// Callback when overlay is dismissed (if dismissible)
  final VoidCallback? onDismissed;

  /// Key for the overlay state
  final GlobalKey<OverlayLoaderState>? loaderKey;

  /// Z-index of the overlay (higher appears on top)
  final int zIndex;

  /// Whether to prevent user interaction with background widgets
  final bool blockInteraction;

  /// Whether to add padding around the indicator
  final EdgeInsets? indicatorPadding;

  /// Border radius for the loader container
  final BorderRadius? borderRadius;

  /// Accessibility label for screen readers
  final String? accessibilityLabel;

  /// Whether to announce loading status to screen readers
  final bool announceToScreenReader;

  /// Shimmer base color (when using shimmer type)
  final Color? shimmerBaseColor;

  /// Shimmer highlight color (when using shimmer type)
  final Color? shimmerHighlightColor;

  /// Child widget to apply shimmer effect to (when using shimmer type)
  final Widget? shimmerChild;

  /// Lottie animation asset path (when using lottie type)
  final String? lottieAsset;

  /// Lottie animation network URL (when using lottie type)
  final String? lottieUrl;

  /// Lottie animation controller
  final AnimationController? lottieController;

  /// Custom position builder function
  final Widget Function(LoaderPositionBuilder)? positionBuilder;

  const OverlayLoader({
    Key? key,
    required this.isLoading,
    this.opacity = 0.3,
    this.color,
    this.offset,
    this.dismissible = false,
    required this.child,
    this.progressIndicator,
    this.blur = 0.0,
    this.loaderType = LoaderType.circular,
    this.indicatorSize,
    this.indicatorThickness,
    this.indicatorColor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.loadingText,
    this.loadingTextStyle,
    this.onLoadingChanged,
    this.onDismissed,
    this.loaderKey,
    this.zIndex = 999,
    this.blockInteraction = true,
    this.indicatorPadding,
    this.borderRadius,
    this.accessibilityLabel,
    this.announceToScreenReader = true,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
    this.shimmerChild,
    this.lottieAsset,
    this.lottieUrl,
    this.lottieController,
    this.positionBuilder,
  }) : super(key: key);

  @override
  OverlayLoaderState createState() => OverlayLoaderState();

  /// Static method to show a global loader
  static OverlayEntry? _globalOverlayEntry;
  static bool _isGlobalLoaderVisible = false;

  static Future<void> showGlobalLoader(
      BuildContext context, {
        Color? color,
        double opacity = 0.3,
        double blur = 0.0,
        Widget? progressIndicator,
        String? loadingText,
        TextStyle? loadingTextStyle,
        bool dismissible = false,
        VoidCallback? onDismissed,
        Duration? timeout,
        LoaderType loaderType = LoaderType.circular,
        String? accessibilityLabel,
        bool announceToScreenReader = true,
        Color? shimmerBaseColor,
        Color? shimmerHighlightColor,
        Widget? shimmerChild,
        String? lottieAsset,
        String? lottieUrl,
        AnimationController? lottieController,
        Widget Function(LoaderPositionBuilder)? positionBuilder,
      }) async {
    if (_isGlobalLoaderVisible) {
      hideGlobalLoader();
    }

    _isGlobalLoaderVisible = true;
    final ThemeData theme = Theme.of(context);

    // Announce to screen reader if needed
    if (announceToScreenReader) {
      final String announcement = accessibilityLabel ?? loadingText ?? 'Loading';
      SemanticsService.announce(announcement, TextDirection.ltr);
    }

    _globalOverlayEntry = OverlayEntry(
      builder: (context) {
        Widget progressWidget;

        // Create the appropriate progress indicator
        switch (loaderType) {
          case LoaderType.circular:
            progressWidget = progressIndicator ?? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            );
            break;
          case LoaderType.linear:
            progressWidget = progressIndicator ?? SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                backgroundColor: theme.colorScheme.primary.withValues(alpha:0.3),
              ),
            );
            break;
          case LoaderType.shimmer:
            if (shimmerChild != null) {
              progressWidget = Shimmer.fromColors(
                baseColor: shimmerBaseColor ?? theme.colorScheme.surface.withValues(alpha:0.4),
                highlightColor: shimmerHighlightColor ?? theme.colorScheme.surface,
                child: shimmerChild,
              );
            } else {
              progressWidget = Shimmer.fromColors(
                baseColor: shimmerBaseColor ?? theme.colorScheme.surface.withValues(alpha:0.4),
                highlightColor: shimmerHighlightColor ?? theme.colorScheme.surface,
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
            break;
          case LoaderType.lottie:
            if (lottieAsset != null) {
              progressWidget = Lottie.asset(
                lottieAsset,
                width: 200,
                height: 200,
                controller: lottieController,
              );
            } else if (lottieUrl != null) {
              progressWidget = Lottie.network(
                lottieUrl,
                width: 200,
                height: 200,
                controller: lottieController,
              );
            } else {
              progressWidget = CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              );
            }
            break;
          case LoaderType.custom:
          default:
            progressWidget = progressIndicator ?? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            );
        }

        // Add loading text if provided
        if (loadingText != null) {
          progressWidget = Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              progressWidget,
              const SizedBox(height: 16),
              Text(
                loadingText,
                style: loadingTextStyle ?? theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        // Wrap in semantic container for accessibility
        progressWidget = Semantics(
          label: accessibilityLabel ?? loadingText ?? 'Loading in progress',
          container: true,
          liveRegion: true,
          child: progressWidget,
        );

        // Create position builder
        final positionBuilderInstance = LoaderPositionBuilder(context, Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: progressWidget,
        ));

        Widget positioned;
        if (positionBuilder != null) {
          positioned = positionBuilder(positionBuilderInstance);
        } else {
          positioned = positionBuilderInstance.centered();
        }

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Opacity(
                  opacity: opacity,
                  child: ModalBarrier(
                    dismissible: dismissible,
                    color: color ?? theme.colorScheme.outline,
                    onDismiss: onDismissed,
                  ),
                ),
              ),
              positioned,
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_globalOverlayEntry!);

    if (timeout != null) {
      await Future.delayed(timeout);
      hideGlobalLoader();
    }
  }

  static void hideGlobalLoader() {
    if (_isGlobalLoaderVisible && _globalOverlayEntry != null) {
      _globalOverlayEntry!.remove();
      _globalOverlayEntry = null;
      _isGlobalLoaderVisible = false;
    }
  }

  /// Factory constructor for creating an OverlayLoader with the provider
// Instead of a factory constructor, we should create a static method
// that returns a Consumer widget wrapping the OverlayLoader
  static Widget withProvider({
    Key? key,
    required Widget child,
    double opacity = 0.3,
    Color? color,
    double blur = 0.0,
    bool dismissible = false,
    BorderRadius? borderRadius,
    EdgeInsets? indicatorPadding,
    bool blockInteraction = true,
    String? accessibilityLabel,
    bool announceToScreenReader = true,
    Duration animationDuration = const Duration(milliseconds: 300),
    Widget Function(LoaderPositionBuilder)? positionBuilder,
  }) {
    return Consumer<LoaderProvider>(
      builder: (context, provider, _) {
        return OverlayLoader(
          key: key,
          isLoading: provider.isLoading,
          loadingText: provider.loadingText,
          progressIndicator: provider.customIndicator,
          loaderType: provider.loaderType,
          child: child,
          opacity: opacity,
          color: color,
          blur: blur,
          dismissible: dismissible,
          borderRadius: borderRadius,
          indicatorPadding: indicatorPadding,
          blockInteraction: blockInteraction,
          accessibilityLabel: accessibilityLabel,
          announceToScreenReader: announceToScreenReader,
          animationDuration: animationDuration,
          positionBuilder: positionBuilder,
        );
      },
    );
  }
}

class OverlayLoaderState extends State<OverlayLoader> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool _previousLoadingState = false;

  @override
  void initState() {
    super.initState();
    _previousLoadingState = widget.isLoading;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isLoading) {
      _animationController.value = 1.0;

      // Announce to screen reader when initially loading
      if (widget.announceToScreenReader) {
        _announceLoadingState(true);
      }
    }
  }

  @override
  void didUpdateWidget(OverlayLoader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading != oldWidget.isLoading) {
      _previousLoadingState = oldWidget.isLoading;

      if (widget.isLoading) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }

      // Announce loading state change to screen reader
      if (widget.announceToScreenReader) {
        _announceLoadingState(widget.isLoading);
      }

      if (widget.onLoadingChanged != null) {
        widget.onLoadingChanged!(widget.isLoading);
      }
    }
  }

  void _announceLoadingState(bool isLoading) {
    final String message = isLoading
        ? widget.accessibilityLabel ?? widget.loadingText ?? 'Loading in progress'
        : 'Loading complete';
    SemanticsService.announce(message, TextDirection.ltr);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Public method to manually show the loader
  void show() {
    if (!_previousLoadingState) {
      _previousLoadingState = true;
      _animationController.forward();

      // Announce to screen reader
      if (widget.announceToScreenReader) {
        _announceLoadingState(true);
      }

      if (widget.onLoadingChanged != null) {
        widget.onLoadingChanged!(true);
      }
    }
  }

  /// Public method to manually hide the loader
  void hide() {
    if (_previousLoadingState) {
      _previousLoadingState = false;
      _animationController.reverse();

      // Announce to screen reader
      if (widget.announceToScreenReader) {
        _announceLoadingState(false);
      }

      if (widget.onLoadingChanged != null) {
        widget.onLoadingChanged!(false);
      }
    }
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color indicatorColor = widget.indicatorColor ?? theme.colorScheme.primary;

    switch (widget.loaderType) {
      case LoaderType.circular:
        return widget.progressIndicator ?? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          strokeWidth: widget.indicatorThickness ?? 4.0,
        );
      case LoaderType.linear:
        return widget.progressIndicator ?? SizedBox(
          width: widget.indicatorSize ?? 100,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            backgroundColor: indicatorColor.withValues(alpha:0.3),
            minHeight: widget.indicatorThickness ?? 4.0,
          ),
        );
      case LoaderType.shimmer:
        final shimmerBaseColor = widget.shimmerBaseColor ?? theme.colorScheme.surface.withValues(alpha:0.4);
        final shimmerHighlightColor = widget.shimmerHighlightColor ?? theme.colorScheme.surface;

        if (widget.shimmerChild != null) {
          return Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: shimmerHighlightColor,
            child: widget.shimmerChild!,
          );
        } else {
          return Shimmer.fromColors(
            baseColor: shimmerBaseColor,
            highlightColor: shimmerHighlightColor,
            child: Container(
              width: widget.indicatorSize ?? 200,
              height: (widget.indicatorSize ?? 200) / 2,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      case LoaderType.lottie:
        if (widget.lottieAsset != null) {
          return Lottie.asset(
            widget.lottieAsset!,
            width: widget.indicatorSize,
            height: widget.indicatorSize,
            controller: widget.lottieController,
          );
        } else if (widget.lottieUrl != null) {
          return Lottie.network(
            widget.lottieUrl!,
            width: widget.indicatorSize,
            height: widget.indicatorSize,
            controller: widget.lottieController,
          );
        } else {
          return widget.progressIndicator ?? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: widget.indicatorThickness ?? 4.0,
          );
        }
      case LoaderType.custom:
      default:
        return widget.progressIndicator ?? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          strokeWidth: widget.indicatorThickness ?? 4.0,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color loaderColor = widget.color ?? theme.colorScheme.outline;

    Widget progressWidget = _buildProgressIndicator(context);
    Widget layOutProgressIndicator;

    // Add loading text if provided
    if (widget.loadingText != null) {
      progressWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: widget.borderRadius != null
                ? BoxDecoration(
              borderRadius: widget.borderRadius,
              color: theme.colorScheme.surface.withValues(alpha:0.7),
            )
                : null,
            padding: widget.indicatorPadding ?? const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                progressWidget,
                const SizedBox(height: 16),
                Text(
                  widget.loadingText!,
                  style: widget.loadingTextStyle ?? theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    } else if (widget.indicatorPadding != null || widget.borderRadius != null) {
      progressWidget = Container(
        decoration: widget.borderRadius != null
            ? BoxDecoration(
          borderRadius: widget.borderRadius,
          color: theme.colorScheme.surface.withValues(alpha:0.7),
        )
            : null,
        padding: widget.indicatorPadding ?? const EdgeInsets.all(12),
        child: progressWidget,
      );
    }

    // Wrap in semantics for accessibility
    progressWidget = Semantics(
      label: widget.accessibilityLabel ?? widget.loadingText ?? 'Loading in progress',
      container: true,
      liveRegion: true,
      child: progressWidget,
    );

    // Use position builder if provided, otherwise use legacy positioning logic
    if (widget.positionBuilder != null) {
      final builder = LoaderPositionBuilder(context, progressWidget);
      layOutProgressIndicator = widget.positionBuilder!(builder);
    } else if (widget.offset == null) {
      layOutProgressIndicator = Center(child: progressWidget);
    } else {
      layOutProgressIndicator = Positioned(
        left: widget.offset!.dx,
        top: widget.offset!.dy,
        child: progressWidget,
      );
    }

    return Stack(
      children: [
        // Always allow child to be accessible for layout purposes
        widget.child,

        // Only create overlay when loading
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            if (_animationController.value == 0) {
              return const SizedBox.shrink();
            }

            return Positioned.fill(
              child: IgnorePointer(
                // Only ignore pointer events when overlay is visible and should block interaction
                ignoring: !(_animationController.value > 0 && widget.blockInteraction),
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: Stack(
                    children: [
                      // Blur and overlay
                      BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: widget.blur * _animationController.value,
                          sigmaY: widget.blur * _animationController.value,
                        ),
                        child: Opacity(
                          opacity: widget.opacity * _animationController.value,
                          child: ModalBarrier(
                            dismissible: widget.dismissible,
                            color: loaderColor,
                            onDismiss: widget.onDismissed,
                          ),
                        ),
                      ),
                      // Loader indicator
                      layOutProgressIndicator,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}



// class ProviderOverlayLoader extends OverlayLoader {
//   const ProviderOverlayLoader({
//     super.key,
//     required super.isLoading,
//     required super.child,
//   });
//
//   Widget build(BuildContext context) {
//     return Consumer<LoaderProvider>(
//         builder: (context, provider, _) {
//           return super.build(context);
//         }
//     );
//   }
// }
