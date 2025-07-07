 import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A class to manage and provide app version information.
class AppVersionTracker extends ChangeNotifier {
  String _appVersion = 'Unknown';
  String _buildNumber = 'Unknown';
  String _packageName = 'Unknown';

  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;
  String get packageName => _packageName;

  AppVersionTracker() {
    _initialize();
  }

  /// Initializes the app version details.
  Future<void> _initialize() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
      _packageName = packageInfo.packageName;
      notifyListeners();
    } catch (e) {
      _appVersion = 'Error: $e';
      _buildNumber = 'Error: $e';
      _packageName = 'Error: $e';
      notifyListeners();
    }
  }

  /// Refreshes the app version details.
  Future<void> refresh() async {
    await _initialize();
  }
}

/// Provides a singleton instance of AppVersionTracker.
class AppVersionTrackerProvider {
  static final AppVersionTracker _instance = AppVersionTracker();

  static AppVersionTracker get instance => _instance;

  /// Wraps a widget with a ChangeNotifierProvider for AppVersionTracker.
  static Widget provide({required Widget child}) {
    return ChangeNotifierProvider.value(
      value: _instance,
      child: child,
    );
  }
}