// network_connectivity_snackbar.dart
import 'package:flutter/material.dart';
import 'package:pack/pack.dart';

import '../../services/connectivity_service/connectivity_service.dart';
import '../../services/snack_bar_service/notify_service.dart';


class NetworkConnectivitySnackBar extends StatefulWidget {
  final Widget child;
  final ConnectivityService connectivityService;
  const NetworkConnectivitySnackBar({super.key, required this.child, required this.connectivityService});

  @override
  State<NetworkConnectivitySnackBar> createState() =>
      _NetworkConnectivitySnackBarState();
}

class _NetworkConnectivitySnackBarState
    extends State<NetworkConnectivitySnackBar> {
  late ConnectivityService _connectivityService;
  bool _isOnline = true; // Track current state
  bool _snackbarShown = false;

  @override
  void initState() {
    super.initState();
    _connectivityService = widget.connectivityService;

    // Set initial state
    _isOnline = _connectivityService.isConnected;
    WidgetsBinding.instance.addPostFrameCallback((_)=>_checkConnectivity());

    // Listen to actual network changes instead of periodic polling
    _connectivityService.onConnectivityChanged.listen((_) {
      _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    // Use hasActiveInternet to check for actual internet access
    final hasInternet = await _connectivityService.hasActiveInternet();

    if (mounted) {
      setState(() {
        if (_isOnline != hasInternet) {
          _isOnline = hasInternet;
          _showConnectivitySnackBar(context, _isOnline);
        }
      });
    }
  }

  void _showConnectivitySnackBar(BuildContext context, bool isOnline) {
    // Always clear previous snackbars first
    ScaffoldMessenger.of(context).clearSnackBars();

    // Only show the snackbar if we need to
    if (_snackbarShown && isOnline) {
      // We were showing the offline snackbar and now we're online
      _snackbarShown = false;
      NotifyService.googleFilesStyle(
        context: context,
        message: 'Internet Connection Restored',

        color: context.colorScheme.primary,
      );
    } else if (!isOnline) {
      // We're offline, show the offline snackbar
      _snackbarShown = true;
      NotifyService.googleFilesStyle(
        context: context,
        message: 'No Internet Connection',
        duration: Duration(minutes: 60),
        color: context.colorScheme.error

        // type: NotificationType.warning,
        // showIcon: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
