import 'package:flutter/material.dart';

/// An extended collection of beautiful, reusable error screens for Flutter applications.
/// This widget library provides customizable error screens for common error scenarios:
/// - Network errors
/// - Unimplemented pages
/// - Server errors
/// - Widget errors
/// - Internet connection issues
/// - Work in progress pages
/// - Empty states
/// - Route errors
/// - Permission denied errors
/// - Timeout errors
/// - Maintenance screens
/// - Search empty screens
/// - Retry handlers
///
/// Each error screen is fully customizable and designed with clean aesthetics.

class ErrorScreenType {
  static const String network = 'network';
  static const String unimplemented = 'unimplemented';
  static const String server = 'server';
  static const String widget = 'widget';
  static const String connection = 'connection';
  static const String workInProgress = 'wip';
  static const String empty = 'empty';
  static const String route = 'route';
  static const String permission = 'permission';
  static const String timeout = 'timeout';
  static const String maintenance = 'maintenance';
  static const String searchEmpty = 'search_empty';
  static const String custom = 'custom';
}

class ErrorScreen extends StatelessWidget {
  final String type;
  final String? title;
  final String? message;
  final String? imageAsset;
  final IconData? icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final VoidCallback? onSecondaryActionPressed;
  final String? secondaryActionText;
  final bool showDismiss;
  final Widget? customContent;

  const ErrorScreen({
    Key? key,
    required this.type,
    this.title,
    this.message,
    this.imageAsset,
    this.icon,
    this.iconColor,
    this.backgroundColor,
    this.textColor,
    this.onActionPressed,
    this.actionText,
    this.onSecondaryActionPressed,
    this.secondaryActionText,
    this.showDismiss = false,
    this.customContent,
  }) : super(key: key);

  // Factory constructors for specific error types
  factory ErrorScreen.network({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onRetry,
    String? retryText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.network,
      title: title ?? 'Network Error',
      message:
          message ??
          'Unable to connect to the server. Please check your network connection and try again.',
      imageAsset: imageAsset,
      icon: Icons.cloud_off_rounded,
      iconColor: Colors.blueGrey[600],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onRetry,
      actionText: retryText ?? 'Retry',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.unimplemented({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onGoBack,
    String? goBackText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.unimplemented,
      title: title ?? 'Coming Soon',
      message:
          message ?? 'This feature is not yet implemented. Check back later!',
      imageAsset: imageAsset,
      icon: Icons.engineering_rounded,
      iconColor: Colors.amber[700],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onGoBack,
      actionText: goBackText ?? 'Go Back',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.server({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onRetry,
    String? retryText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.server,
      title: title ?? 'Server Error',
      message:
          message ??
          'Something went wrong on our end. We\'re working to fix it as soon as possible.',
      imageAsset: imageAsset,
      icon: Icons.dns_rounded,
      iconColor: Colors.red[400],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onRetry,
      actionText: retryText ?? 'Try Again',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.widget({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onRefresh,
    String? refreshText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.widget,
      title: title ?? 'Widget Error',
      message: message ?? 'Something went wrong while displaying this content.',
      imageAsset: imageAsset,
      icon: Icons.broken_image_rounded,
      iconColor: Colors.purple[400],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onRefresh,
      actionText: refreshText ?? 'Refresh',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.connection({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onCheckConnection,
    String? checkConnectionText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.connection,
      title: title ?? 'No Internet Connection',
      message:
          message ?? 'Please check your internet connection and try again.',
      imageAsset: imageAsset,
      icon: Icons.wifi_off_rounded,
      iconColor: Colors.indigo[400],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onCheckConnection,
      actionText: checkConnectionText ?? 'Check Connection',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.workInProgress({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onNotifyMe,
    String? notifyMeText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.workInProgress,
      title: title ?? 'Work In Progress',
      message:
          message ??
          'We\'re currently building this feature. Stay tuned for updates!',
      imageAsset: imageAsset,
      icon: Icons.construction_rounded,
      iconColor: Colors.orange[400],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onNotifyMe,
      actionText: notifyMeText ?? 'Notify Me When Ready',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.empty({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onActionPressed,
    String? actionText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.empty,
      title: title ?? 'No Items Found',
      message: message ?? 'There are no items to display right now.',
      imageAsset: imageAsset,
      icon: Icons.inbox_rounded,
      iconColor: Colors.blueGrey[300],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onActionPressed,
      actionText: actionText ?? 'Refresh',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.route({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onGoHome,
    String? goHomeText,
    VoidCallback? onGoBack,
    String? goBackText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.route,
      title: title ?? 'Page Not Found',
      message:
          message ??
          'The page you\'re looking for doesn\'t exist or has been moved.',
      imageAsset: imageAsset,
      icon: Icons.map_rounded,
      iconColor: Colors.teal[400],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onGoHome,
      actionText: goHomeText ?? 'Go Home',
      onSecondaryActionPressed: onGoBack,
      secondaryActionText: goBackText ?? 'Go Back',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.permission({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onRequestPermission,
    String? requestText,
    VoidCallback? onCancel,
    String? cancelText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.permission,
      title: title ?? 'Permission Required',
      message:
          message ??
          'This feature requires additional permissions to work properly.',
      imageAsset: imageAsset,
      icon: Icons.lock_outline_rounded,
      iconColor: Colors.amber[700],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onRequestPermission,
      actionText: requestText ?? 'Grant Permission',
      onSecondaryActionPressed: onCancel,
      secondaryActionText: cancelText ?? 'Not Now',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.timeout({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onRetry,
    String? retryText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.timeout,
      title: title ?? 'Request Timeout',
      message:
          message ??
          'The server is taking too long to respond. Please try again later.',
      imageAsset: imageAsset,
      icon: Icons.timer_off_rounded,
      iconColor: Colors.red[300],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onRetry,
      actionText: retryText ?? 'Try Again',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.maintenance({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onCheckStatus,
    String? checkStatusText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.maintenance,
      title: title ?? 'Under Maintenance',
      message:
          message ??
          'Our servers are currently undergoing scheduled maintenance. We\'ll be back shortly!',
      imageAsset: imageAsset,
      icon: Icons.handyman_rounded,
      iconColor: Colors.blue[400],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onCheckStatus,
      actionText: checkStatusText ?? 'Check Status',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.searchEmpty({
    String? title,
    String? message,
    String? imageAsset,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onClearSearch,
    String? clearSearchText,
    bool showDismiss = false,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.searchEmpty,
      title: title ?? 'No Results Found',
      message:
          message ??
          'We couldn\'t find any matches for your search. Try different keywords.',
      imageAsset: imageAsset,
      icon: Icons.search_off_rounded,
      iconColor: Colors.grey[500],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onClearSearch,
      actionText: clearSearchText ?? 'Clear Search',
      showDismiss: showDismiss,
    );
  }

  factory ErrorScreen.custom({
    required String title,
    required String message,
    String? imageAsset,
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onActionPressed,
    String? actionText,
    VoidCallback? onSecondaryActionPressed,
    String? secondaryActionText,
    bool showDismiss = false,
    Widget? customContent,
  }) {
    return ErrorScreen(
      type: ErrorScreenType.custom,
      title: title,
      message: message,
      imageAsset: imageAsset,
      icon: icon,
      iconColor: iconColor ?? Colors.grey[700],
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onActionPressed,
      actionText: actionText,
      onSecondaryActionPressed: onSecondaryActionPressed,
      secondaryActionText: secondaryActionText,
      showDismiss: showDismiss,
      customContent: customContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color bgColor = backgroundColor ?? theme.scaffoldBackgroundColor;
    final Color txtColor =
        textColor ?? theme.textTheme.bodyLarge?.color ?? Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showDismiss) _buildDismissButton(context),
                _buildImage(context),
                const SizedBox(height: 32),
                Text(
                  title ?? 'Something Went Wrong',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: txtColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message ??
                      'An unexpected error occurred. Please try again later.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: txtColor.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (customContent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: customContent!,
                  ),
                const SizedBox(height: 32),
                if (onActionPressed != null) _buildActionButton(context),
                if (onSecondaryActionPressed != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildSecondaryActionButton(context),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
        color: textColor?.withValues(alpha: 0.6) ?? Colors.black54,
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    if (imageAsset != null) {
      return Image.asset(imageAsset!, height: 200, width: 200);
    } else {
      return Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.blueGrey[600])?.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(80),
        ),
        child: Icon(
          icon ?? Icons.error_outline_rounded,
          size: 80,
          color: iconColor ?? Colors.blueGrey[600],
        ),
      );
    }
  }

  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onActionPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: iconColor,
        foregroundColor: Colors.white,
      ),
      child: Text(
        actionText ?? 'Try Again',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSecondaryActionButton(BuildContext context) {
    return TextButton(
      onPressed: onSecondaryActionPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        foregroundColor: iconColor,
      ),
      child: Text(
        secondaryActionText ?? 'Cancel',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: iconColor,
        ),
      ),
    );
  }
}

/// A responsive animation manager for error screens
class ErrorAnimationWrapper extends StatefulWidget {
  final Widget child;
  final bool animated;
  final Duration animationDuration;

  const ErrorAnimationWrapper({
    Key? key,
    required this.child,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<ErrorAnimationWrapper> createState() => _ErrorAnimationWrapperState();
}

class _ErrorAnimationWrapperState extends State<ErrorAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// An advanced error handler widget that detects connection issues automatically
class ConnectionAwareErrorHandler extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, VoidCallback) connectionErrorBuilder;
  final Duration checkInterval;

  const ConnectionAwareErrorHandler({
    Key? key,
    required this.child,
    required this.connectionErrorBuilder,
    this.checkInterval = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<ConnectionAwareErrorHandler> createState() =>
      _ConnectionAwareErrorHandlerState();
}

class _ConnectionAwareErrorHandlerState
    extends State<ConnectionAwareErrorHandler> {
  bool _hasConnection = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    if (_isChecking) return;

    _isChecking = true;

    // This is a simplified mock implementation
    // In real-world apps, you would use Connectivity package or similar
    try {
      // Simulate network check
      await Future.delayed(const Duration(milliseconds: 500));

      // Implement actual connectivity check here
      bool hasConnection = true; // Replace with actual check

      if (mounted && _hasConnection != hasConnection) {
        setState(() {
          _hasConnection = hasConnection;
        });
      }
    } catch (e) {
      if (mounted && _hasConnection) {
        setState(() {
          _hasConnection = false;
        });
      }
    } finally {
      _isChecking = false;

      if (mounted) {
        Future.delayed(widget.checkInterval, _checkConnection);
      }
    }
  }

  void _retryConnection() {
    if (mounted) {
      _checkConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasConnection) {
      return widget.child;
    } else {
      return widget.connectionErrorBuilder(context, _retryConnection);
    }
  }
}

/// A retry handler for automatic retry with exponential backoff
class RetryHandler<T> extends StatefulWidget {
  final Future<T> Function() future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)
  errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final int maxRetries;
  final Duration initialDelay;
  final double backoffFactor;

  const RetryHandler({
    Key? key,
    required this.future,
    required this.builder,
    required this.errorBuilder,
    this.loadingBuilder,
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 2),
    this.backoffFactor = 1.5,
  }) : super(key: key);

  @override
  State<RetryHandler<T>> createState() => _RetryHandlerState<T>();
}

class _RetryHandlerState<T> extends State<RetryHandler<T>> {
  late Future<T> _future;
  int _retryCount = 0;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _future = widget.future();
  }

  Future<void> _retry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
      _future = widget.future();
    });

    // Reset retry status after operation completes
    await _future
        .then((_) {
          _retryCount = 0;
        })
        .catchError((error) {
          if (_retryCount < widget.maxRetries) {
            _retryCount++;
            final delay =
                widget.initialDelay.inMilliseconds *
                (widget.backoffFactor * _retryCount).round();

            Future.delayed(Duration(milliseconds: delay), () {
              if (mounted) {
                _retry();
              }
            });
          }
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _isRetrying = false;
            });
          }
        });
  }

  void _manualRetry() {
    if (mounted) {
      setState(() {
        _retryCount = 0;
        _future = widget.future();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return widget.errorBuilder(context, snapshot.error!, _manualRetry);
        } else if (snapshot.hasData) {
          return widget.builder(context, snapshot.data as T);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// A 404 route error handler for Navigator 2.0
class RouteErrorHandler extends StatelessWidget {
  final String? routeName;
  final VoidCallback? onGoHome;
  final VoidCallback? onGoBack;

  const RouteErrorHandler({
    Key? key,
    this.routeName,
    this.onGoHome,
    this.onGoBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorAnimationWrapper(
      child: ErrorScreen.route(
        title: 'Page Not Found',
        message:
            routeName != null
                ? 'The page "$routeName" could not be found or doesn\'t exist.'
                : 'The page you\'re looking for couldn\'t be found.',
        onGoHome:
            onGoHome ??
            () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
        onGoBack:
            onGoBack ??
            () {
              Navigator.of(context).pop();
            },
      ),
    );
  }
}

/// A placeholder widget for empty states
class EmptyStatedWidget extends StatelessWidget {
  final String type;
  final String title;
  final String message;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const EmptyStatedWidget({
    Key? key,
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    this.iconColor,
    this.onActionPressed,
    this.actionText,
  }) : super(key: key);

  factory EmptyStatedWidget.list({
    VoidCallback? onRefresh,
    String? refreshText,
  }) {
    return EmptyStatedWidget(
      type: 'list',
      title: 'No Items Yet',
      message: 'There are no items to display at the moment.',
      icon: Icons.list_alt_rounded,
      iconColor: Colors.blueGrey[300],
      onActionPressed: onRefresh,
      actionText: refreshText,
    );
  }

  factory EmptyStatedWidget.search({VoidCallback? onClear, String? clearText}) {
    return EmptyStatedWidget(
      type: 'search',
      title: 'No Results',
      message: 'We couldn\'t find any matches for your search criteria.',
      icon: Icons.search_off_rounded,
      iconColor: Colors.grey[500],
      onActionPressed: onClear,
      actionText: clearText ?? 'Clear Search',
    );
  }

  factory EmptyStatedWidget.favorites({
    VoidCallback? onBrowse,
    String? browseText,
  }) {
    return EmptyStatedWidget(
      type: 'favorites',
      title: 'No Favorites',
      message: 'You haven\'t added any favorites yet.',
      icon: Icons.favorite_border_rounded,
      iconColor: Colors.red[300],
      onActionPressed: onBrowse,
      actionText: browseText ?? 'Browse Items',
    );
  }

  factory EmptyStatedWidget.cart({VoidCallback? onShop, String? shopText}) {
    return EmptyStatedWidget(
      type: 'cart',
      title: 'Your Cart is Empty',
      message: 'Add items to your cart to get started.',
      icon: Icons.shopping_cart_outlined,
      iconColor: Colors.amber[700],
      onActionPressed: onShop,
      actionText: shopText ?? 'Shop Now',
    );
  }

  factory EmptyStatedWidget.notifications({
    VoidCallback? onRefresh,
    String? refreshText,
  }) {
    return EmptyStatedWidget(
      type: 'notifications',
      title: 'No Notifications',
      message: 'You don\'t have any notifications at the moment.',
      icon: Icons.notifications_none_rounded,
      iconColor: Colors.purple[300],
      onActionPressed: onRefresh,
      actionText: refreshText,
    );
  }

  factory EmptyStatedWidget.messages({
    VoidCallback? onStart,
    String? startText,
  }) {
    return EmptyStatedWidget(
      type: 'messages',
      title: 'No Messages',
      message: 'Start a conversation to see messages here.',
      icon: Icons.chat_bubble_outline_rounded,
      iconColor: Colors.teal[400],
      onActionPressed: onStart,
      actionText: startText ?? 'Start Chat',
    );
  }

  factory EmptyStatedWidget.custom({
    required String title,
    required String message,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onActionPressed,
    String? actionText,
  }) {
    return EmptyStatedWidget(
      type: 'custom',
      title: title,
      message: message,
      icon: icon,
      iconColor: iconColor ?? Colors.grey[600],
      onActionPressed: onActionPressed,
      actionText: actionText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.blueGrey[300])?.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor ?? Colors.blueGrey[300],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(actionText ?? 'Refresh'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Example usage helper
class ErrorScreenUtils {
  /// Helper method to show fullscreen error
  static Future<T?> showFullscreenError<T>({
    required BuildContext context,
    required String type,
    String? title,
    String? message,
    String? imageAsset,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onActionPressed,
    String? actionText,
    VoidCallback? onSecondaryActionPressed,
    String? secondaryActionText,
    bool barrierDismissible = true,
    bool animated = true,
    bool showDismiss = false,
  }) {
    final ErrorScreen errorScreen = ErrorScreen(
      type: type,
      title: title,
      message: message,
      imageAsset: imageAsset,
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onActionPressed ?? () => Navigator.of(context).pop(),
      actionText: actionText,
      onSecondaryActionPressed: onSecondaryActionPressed,
      secondaryActionText: secondaryActionText,
      showDismiss: showDismiss,
    );

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (BuildContext context, _, __) {
        return ErrorAnimationWrapper(animated: animated, child: errorScreen);
      },
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Helper method to show a bottom sheet error
  static Future<T?> showBottomSheetError<T>({
    required BuildContext context,
    required String type,
    String? title,
    String? message,
    String? imageAsset,
    IconData? icon,
    Color? iconColor,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onActionPressed,
    String? actionText,
    VoidCallback? onSecondaryActionPressed,
    String? secondaryActionText,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
  }) {
    final ErrorScreen errorScreen = ErrorScreen(
      type: type,
      title: title,
      message: message,
      imageAsset: imageAsset,
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      textColor: textColor,
      onActionPressed: onActionPressed,
      actionText: actionText,
      onSecondaryActionPressed: onSecondaryActionPressed,
      secondaryActionText: secondaryActionText,
      showDismiss: true,
    );

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: ErrorAnimationWrapper(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: errorScreen,
            ),
          ),
        );
      },
    );
  }

  /// Helper method to show a snackbar error
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
  showSnackBarError({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    VoidCallback? onActionPressed,
    String? actionText,
    Duration duration = const Duration(seconds: 4),
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(icon, color: textColor ?? Colors.white, size: 20),
              ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor ?? Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? Colors.red[700],
        duration: duration,
        action:
            onActionPressed != null
                ? SnackBarAction(
                  label: actionText ?? 'Retry',
                  textColor: textColor ?? Colors.white,
                  onPressed: onActionPressed,
                )
                : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Advanced retry handler with exponential backoff
class RetryConfiguration {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffFactor;
  final Duration maxDelay;
  final bool shouldShowProgress;

  const RetryConfiguration({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 2),
    this.backoffFactor = 1.5,
    this.maxDelay = const Duration(seconds: 30),
    this.shouldShowProgress = true,
  });

  static const RetryConfiguration gentle = RetryConfiguration(
    maxRetries: 2,
    initialDelay: Duration(seconds: 1),
    backoffFactor: 1.5,
  );

  static const RetryConfiguration aggressive = RetryConfiguration(
    maxRetries: 5,
    initialDelay: Duration(milliseconds: 500),
    backoffFactor: 2.0,
  );

  static const RetryConfiguration persistent = RetryConfiguration(
    maxRetries: 8,
    initialDelay: Duration(seconds: 2),
    backoffFactor: 1.8,
    maxDelay: Duration(minutes: 1),
  );
}

/// Retry utility that can be used independently
class RetryUtility {
  final RetryConfiguration config;

  RetryUtility({RetryConfiguration? config})
    : config = config ?? const RetryConfiguration();

  Future<T> execute<T>({
    required Future<T> Function() operation,
    bool Function(Object error)? shouldRetry,
    void Function(int attempt, Duration nextDelay)? onRetry,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        final bool retry =
            attempt < config.maxRetries &&
            (shouldRetry == null || shouldRetry(e));

        if (!retry) {
          rethrow;
        }

        final delay = _calculateDelay(attempt);

        if (onRetry != null) {
          onRetry(attempt, delay);
        }

        await Future.delayed(delay);
      }
    }
  }

  Duration _calculateDelay(int attempt) {
    final milliseconds =
        config.initialDelay.inMilliseconds *
        (config.backoffFactor * (attempt - 1)).round();

    return Duration(
      milliseconds: milliseconds.clamp(
        config.initialDelay.inMilliseconds,
        config.maxDelay.inMilliseconds,
      ),
    );
  }
}

/// A widget that displays fallback UI when a child widget throws an error

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )
  fallbackBuilder;
  final Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    required this.fallbackBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  void _handleError(Object error, StackTrace? stackTrace) {
    if (widget.onError != null) {
      widget.onError!(error, stackTrace);
    }
    if (mounted) {
      setState(() {
        _error = error;
        _stackTrace = stackTrace;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.fallbackBuilder(context, _error!, _stackTrace);
    }

    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (e, stackTrace) {
          _handleError(e, stackTrace);
          return widget.fallbackBuilder(context, e, stackTrace);
        }
      },
    );
  }
}

/// A screen to display when a route doesn't exist or isn't found
class NotFoundScreen extends StatelessWidget {
  final String? routeName;
  final VoidCallback? onGoHome;
  final VoidCallback? onGoBack;
  final String? customMessage;

  const NotFoundScreen({
    super.key,
    this.routeName,
    this.onGoHome,
    this.onGoBack,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ErrorScreen.route(
        title: 'Page Not Found',
        message:
            customMessage ??
            (routeName != null
                ? 'The page "$routeName" does not exist or has been moved.'
                : 'The page you\'re looking for doesn\'t exist.'),
        onGoHome:
            onGoHome ??
            () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
        onGoBack:
            onGoBack ??
            () {
              Navigator.of(context).pop();
            },
      ),
    );
  }
}

/// A general purpose pagination error widget for lists
class PaginationErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color? retryColor;

  const PaginationErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: Icon(
              Icons.refresh_rounded,
              color: retryColor ?? Theme.of(context).primaryColor,
              size: 18,
            ),
            label: Text(
              'Retry',
              style: TextStyle(
                color: retryColor ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A loadable content widget with built-in error handling
class LoadableContent<T> extends StatefulWidget {
  final Future<T> Function() loadData;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  errorBuilder;
  final Duration? timeout;
  final bool autoLoad;

  const LoadableContent({
    Key? key,
    required this.loadData,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.timeout,
    this.autoLoad = true,
  }) : super(key: key);

  @override
  State<LoadableContent<T>> createState() => _LoadableContentState<T>();
}

class _LoadableContentState<T> extends State<LoadableContent<T>> {
  late Future<T> _future;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoLoad) {
      _load();
    }
  }

  Future<void> _load() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _future =
          widget.timeout != null
              ? widget.loadData().timeout(widget.timeout!)
              : widget.loadData();
    });

    _future.whenComplete(() {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.autoLoad && !_isLoading) {
      return ElevatedButton(
        onPressed: _load,
        child: const Text('Load Content'),
      );
    }

    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, snapshot.error!, _load);
          }

          return ErrorScreen.server(
            message: 'Failed to load content: ${snapshot.error}',
            onRetry: _load,
          );
        } else if (snapshot.hasData) {
          return widget.builder(context, snapshot.data as T);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

// Usage example widget
class ErrorScreensShowcase extends StatelessWidget {
  const ErrorScreensShowcase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error Screens')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildShowcaseButton(
            context,
            'Network Error',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ErrorAnimationWrapper(
                      child: ErrorScreen.network(
                        onRetry: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Server Error',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ErrorAnimationWrapper(
                      child: ErrorScreen.server(
                        onRetry: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Connection Error',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ErrorAnimationWrapper(
                      child: ErrorScreen.connection(
                        onCheckConnection: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Empty State',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ErrorAnimationWrapper(
                      child: ErrorScreen.empty(
                        onActionPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Route Error',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ErrorAnimationWrapper(
                      child: ErrorScreen.route(
                        onGoHome: () => Navigator.of(context).pop(),
                        onGoBack: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Permission Error',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ErrorAnimationWrapper(
                      child: ErrorScreen.permission(
                        onRequestPermission: () => Navigator.of(context).pop(),
                        onCancel: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Timeout Error',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ErrorAnimationWrapper(
                      child: ErrorScreen.timeout(
                        onRetry: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Maintenance Screen',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ErrorAnimationWrapper(
                      child: ErrorScreen.maintenance(
                        onCheckStatus: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Search Empty',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => ErrorAnimationWrapper(
                      child: ErrorScreen.searchEmpty(
                        onClearSearch: () => Navigator.of(context).pop(),
                      ),
                    ),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Empty States Showcase',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const EmptyStatesShowcase(),
              ),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Error Dialog Example',
            () => ErrorScreenUtils.showFullscreenError(
              context: context,
              type: ErrorScreenType.server,
              showDismiss: true,
            ),
          ),
          _buildShowcaseButton(
            context,
            'Error Bottom Sheet Example',
            () => ErrorScreenUtils.showBottomSheetError(
              context: context,
              type: ErrorScreenType.network,
              onActionPressed: () => Navigator.of(context).pop(),
            ),
          ),
          _buildShowcaseButton(
            context,
            'Error Snackbar Example',
            () => ErrorScreenUtils.showSnackBarError(
              context: context,
              message:
                  'Connection failed. Please check your internet and try again.',
              icon: Icons.wifi_off_rounded,
              onActionPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseButton(
    BuildContext context,
    String title,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(title),
      ),
    );
  }
}

/// A showcase for empty states
class EmptyStatesShowcase extends StatelessWidget {
  const EmptyStatesShowcase({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empty States')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEmptyStateCard(
            context,
            'List Empty',
            EmptyStatedWidget.list(onRefresh: () {}),
          ),
          _buildEmptyStateCard(
            context,
            'Search Empty',
            EmptyStatedWidget.search(onClear: () {}),
          ),
          _buildEmptyStateCard(
            context,
            'Favorites Empty',
            EmptyStatedWidget.favorites(onBrowse: () {}),
          ),
          _buildEmptyStateCard(
            context,
            'Cart Empty',
            EmptyStatedWidget.cart(onShop: () {}),
          ),
          _buildEmptyStateCard(
            context,
            'Notifications Empty',
            EmptyStatedWidget.notifications(onRefresh: () {}),
          ),
          _buildEmptyStateCard(
            context,
            'Messages Empty',
            EmptyStatedWidget.messages(onStart: () {}),
          ),
          _buildEmptyStateCard(
            context,
            'Custom Empty State',
            EmptyStatedWidget.custom(
              title: 'No Downloads',
              message: 'You haven\'t downloaded any content yet.',
              icon: Icons.download_rounded,
              iconColor: Colors.blue[400],
              onActionPressed: () {},
              actionText: 'Browse Content',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(
    BuildContext context,
    String title,
    Widget emptyState,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SizedBox(height: 200, child: emptyState),
        ],
      ),
    );
  }
}

/// Simple implementation example of a retry and error-aware widget
class RetryExample extends StatelessWidget {
  const RetryExample({Key? key}) : super(key: key);

  Future<List<String>> _fetchData() async {
    // Simulate network request with potential failure
    await Future.delayed(const Duration(seconds: 2));

    // Randomly succeed or fail to demonstrate retry logic
    if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
      throw Exception('Network request failed');
    }

    return ['Item 1', 'Item 2', 'Item 3'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retry Example')),
      body: RetryHandler<List<String>>(
        future: _fetchData,
        maxRetries: 3,
        initialDelay: const Duration(seconds: 1),
        builder: (context, data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(data[index]));
            },
          );
        },
        errorBuilder: (context, error, retry) {
          return ErrorScreen.network(
            message: 'Failed to load data: ${error.toString()}',
            onRetry: retry,
          );
        },
        loadingBuilder: (context) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading data...'),
              ],
            ),
          );
        },
      ),
    );
  }
}
