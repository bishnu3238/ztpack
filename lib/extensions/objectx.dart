
import 'dart:developer' as dev;

import 'dart:convert';

/// General logging utility for any object
extension LoggingExtension on Object? {
  /// Logs the object's string representation and returns the object
  T log<T>() {
    dev.log(toString());
    return this as T;
  }

  /// Logs with a custom tag
  T logWithTag<T>(String tag) {
    dev.log('[$tag] $this');
    return this as T;
  }

  /// Pretty-print for maps and lists
  T prettyPrint<T>() {
    if (this is Map || this is List) {
      const encoder = JsonEncoder.withIndent('  ');
      try {
        dev.log(encoder.convert(this));
      } catch (e) {
        dev.log('Failed to pretty print: $e\nFalling back to regular toString: $this');
      }
    } else {
      dev.log(toString());
    }
    return this as T;
  }
}





