// network_connectivity_snackbar.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ztpack/pack.dart';
import 'package:ztpack/services/snack_bar_service/notify_service.dart';

import '../../core/network/connectivity_service.dart';


class NetworkConnectivitySnackBar extends StatefulWidget {
  final Widget child;
  final ConnectivityService connectivityService;
  final String offlineMessage;
  final String onlineMessage;
  final Duration offlineDuration;
  final Duration onlineDuration;
  final Color? offlineColor;
  final Color? onlineColor;

  const NetworkConnectivitySnackBar({
    super.key,
    required this.child,
    required this.connectivityService,
    this.offlineMessage = 'No Internet Connection',
    this.onlineMessage = 'Internet Connection Restored',
    this.offlineDuration = const Duration(minutes: 60),
    this.onlineDuration = const Duration(seconds: 2),
    this.offlineColor,
    this.onlineColor,
  });

  @override
  State<NetworkConnectivitySnackBar> createState() => _NetworkConnectivitySnackBarState();
}

class _NetworkConnectivitySnackBarState extends State<NetworkConnectivitySnackBar> {
  late ConnectivityService _connectivityService;
  bool _isOnline = true;
  bool _snackbarShown = false;
  late final Stream<ConnectivityStatus> _statusStream;
  late final StreamSubscription<ConnectivityStatus> _subscription;

  @override
  void initState() {
    super.initState();
    _connectivityService = widget.connectivityService;
    _isOnline = _connectivityService.isConnected;
    _statusStream = _connectivityService.onStatusChanged;
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConnectivity());
    _subscription = _statusStream.listen(_onStatusChanged);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
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

  void _onStatusChanged(ConnectivityStatus status) {
    final isOnline = status == ConnectivityStatus.online;
    if (_isOnline != isOnline) {
      setState(() {
        _isOnline = isOnline;
        _showConnectivitySnackBar(context, _isOnline);
      });
    }
  }

  void _showConnectivitySnackBar(BuildContext context, bool isOnline) {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (_snackbarShown && isOnline) {
      _snackbarShown = false;
      NotifyService.googleFilesStyle(
        context: context,
        message: widget.onlineMessage,
        duration: widget.onlineDuration,
        color: widget.onlineColor ?? Theme.of(context).colorScheme.primary,
      );
    } else if (!isOnline) {
      _snackbarShown = true;
      NotifyService.googleFilesStyle(
        context: context,
        message: widget.offlineMessage,
        duration: widget.offlineDuration,
        color: widget.offlineColor ?? Theme.of(context).colorScheme.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
