
import 'stringx.dart';

extension MapX on Map<String, dynamic> {
  /// Gets a value of type T from the map with comprehensive error handling
  /// Example: json.get<String>('name', '') or json.get<int>('age', 0)
  T get<T>(String key, T defaultValue) {
    // If key doesn't exist, return default
    if (!containsKey(key)) return defaultValue;

    // If value is null, return default
    final dynamic value = this[key];
    if (value == null) return defaultValue;

    // Direct match - value is already of type T
    if (value is T) return value;

    // Type conversion logic for common types
    try {
      // String conversions
      if (T == String) {
        return value.toString() as T;
      }
      // Numeric conversions
      else if (T == int) {
        if (value is String) {
          final parsedValue = int.tryParse(value);
          return (parsedValue ?? defaultValue) as T;
        }
        if (value is double) return value.toInt() as T;
        if (value is bool) return (value ? 1 : 0) as T;
      } else if (T == double) {
        if (value is String) {
          final parsedValue = double.tryParse(value);
          return (parsedValue ?? defaultValue) as T;
        }
        if (value is int) return value.toDouble() as T;
        if (value is bool) return (value ? 1.0 : 0.0) as T;
      }
      // Boolean conversions
      else if (T == bool) {
        if (value is String) {
          final lowercased = value.toLowerCase();
          if (['true', 't', 'yes', 'y', '1'].contains(lowercased))
            return true as T;
          if (['false', 'f', 'no', 'n', '0'].contains(lowercased))
            return false as T;
          return defaultValue;
        }
        if (value is int || value is double) return (value != 0) as T;
      }
      // DateTime conversion
      else if (T == DateTime) {
        if (value is String) {
          final dateTime = DateTime.tryParse(value);
          return (dateTime ?? defaultValue) as T;
        }
        if (value is int) {
          try {
            // Assuming milliseconds since epoch
            return DateTime.fromMillisecondsSinceEpoch(value) as T;
          } catch (_) {
            return defaultValue;
          }
        }
      }
      // List conversion
      else if (T.toString().startsWith('List<')) {
        if (value is List) {
          if (T.toString() == 'List<String>') {
            return value.map((e) => e?.toString() ?? '').toList() as T;
          }
          if (T.toString() == 'List<int>') {
            return value.map((e) {
                  if (e is int) return e;
                  if (e is String) return int.tryParse(e) ?? 0;
                  if (e is double) return e.toInt();
                  return 0;
                }).toList()
                as T;
          }
          if (T.toString() == 'List<double>') {
            return value.map((e) {
                  if (e is double) return e;
                  if (e is int) return e.toDouble();
                  if (e is String) return double.tryParse(e) ?? 0.0;
                  return 0.0;
                }).toList()
                as T;
          }
          if (T.toString() == 'List<bool>') {
            return value.map((e) {
                  if (e is bool) return e;
                  if (e is int || e is double) return e != 0;
                  if (e is String) {
                    final lowercased = e.toLowerCase();
                    if (['true', 't', 'yes', 'y', '1'].contains(lowercased))
                      return true;
                    return false;
                  }
                  return false;
                }).toList()
                as T;
          }
        }
      }
      // Map conversion
      else if (T.toString().startsWith('Map<')) {
        if (value is Map) {
          return Map<String, dynamic>.from(value) as T;
        }
      }
    } catch (e) {
      print('Error converting value for key "$key": $e');
      return defaultValue;
    }

    print(
      'Unsupported conversion for key "$key" from ${value.runtimeType} to $T',
    );
    return defaultValue;
  }

  /// Gets String value (with special handling)
  String getString(String key, [String defaultValue = '']) {
    return get<String>(key, defaultValue);
  }

  List<T> getList<T>(String key, T Function(Map<String, dynamic>) fromMap) {
    final list = this[key];
    if (list is List) {
      return list
          .map((item) =>
      item is Map<String, dynamic> ? fromMap(item) : null)
          .whereType<T>()
          .toList();
    }
    return [];
  }


  /// Gets int value (with special handling)
  int getInt(String key, [int defaultValue = 0]) {
    return get<int>(key, defaultValue);
  }

  /// Gets double value (with special handling)
  double getDouble(String key, [double defaultValue = 0.0]) {
    return get<double>(key, defaultValue);
  }

  /// Gets bool value (with special handling)
  bool getBool(String key, [bool defaultValue = false]) {
    return get<bool>(key, defaultValue);
  }

  /// Gets DateTime value (with special handling for different formats)
  DateTime getDateTime(String key, [DateTime? defaultValue]) {
    defaultValue ??= DateTime(1970);
    return get<DateTime>(key, defaultValue);
  }

  /// Gets a nested map
  Map<String, dynamic> getMap(
    String key, [
    Map<String, dynamic>? defaultValue,
  ]) {
    defaultValue ??= {};
    return get<Map<String, dynamic>>(key, defaultValue);
  }

  /// Gets a list of strings
  List<String> getStringList(String key, [List<String>? defaultValue]) {
    defaultValue ??= [];
    return get<List<String>>(key, defaultValue);
  }

  /// Gets a list of integers
  List<int> getIntList(String key, [List<int>? defaultValue]) {
    defaultValue ??= [];
    return get<List<int>>(key, defaultValue);
  }

  /// Gets an enum value by matching string representations
  T getEnum<T extends Enum>(String key, List<T> values, T defaultValue) {
    final String stringValue = getString(key);
    if (stringValue.isEmpty) return defaultValue;

    // Try to match by name
    try {
      return values.firstWhere(
        (element) => element.name.toLowerCase() == stringValue.toLowerCase(),
        orElse: () => defaultValue,
      );
    } catch (_) {
      // Try to match by index if it's a number
      final int? index = int.tryParse(stringValue);
      if (index != null && index >= 0 && index < values.length) {
        return values[index];
      }
      return defaultValue;
    }
  }

  /// Generic status parser for any enum type with active/inactive pattern
  T getStatus<T extends Enum>(String key, List<T> values, T defaultValue) {
    final dynamic value = this[key];
    if (value == null) return defaultValue;

    // Handle string values
    if (value is String) {
      if (value == '0') {
        return values.firstWhere(
          (e) => e.name == 'inactive',
          orElse: () => defaultValue,
        );
      }
      if (value == '1') {
        return values.firstWhere(
          (e) => e.name == 'active',
          orElse: () => defaultValue,
        );
      }
      final lowercased = value.toLowerCase();
      return values.firstWhere(
        (e) => e.name.toLowerCase() == lowercased,
        orElse: () => defaultValue,
      );
    }

    // Handle numeric values
    if (value is int || value is double) {
      if (value == 0) {
        return values.firstWhere(
          (e) => e.name == 'inactive',
          orElse: () => defaultValue,
        );
      }
      if (value == 1) {
        return values.firstWhere(
          (e) => e.name == 'active',
          orElse: () => defaultValue,
        );
      }
    }

    // Handle boolean values
    if (value is bool) {
      return value
          ? values.firstWhere(
            (e) => e.name == 'active',
            orElse: () => defaultValue,
          )
          : values.firstWhere(
            (e) => e.name == 'inactive',
            orElse: () => defaultValue,
          );
    }

    return defaultValue;
  }

  /// Deep get - access nested properties with dot notation
  T deepGet<T>(String path, T defaultValue) {
    final parts = path.split('.');
    dynamic current = this;

    for (int i = 0; i < parts.length; i++) {
      final key = parts[i];

      // Handle array access with bracket notation: items[0].name
      if (key.contains('[') && key.contains(']')) {
        final match = RegExp(r'(\w+)\[(\d+)\]').firstMatch(key);
        if (match != null) {
          final arrayName = match.group(1)!;
          final index = int.parse(match.group(2)!);

          if (current is Map && current.containsKey(arrayName)) {
            final array = current[arrayName];
            if (array is List && index < array.length) {
              current = array[index];
              continue;
            }
          }
          return defaultValue;
        }
      }

      if (current is Map && current.containsKey(key)) {
        current = current[key];
      } else {
        return defaultValue;
      }
    }

    if (current is T) return current;

    if (T == String) return current?.toString() as T ?? defaultValue;
    if (T == int && current is String) {
      return (int.tryParse(current) ?? defaultValue) as T;
    }
    if (T == double && current is String) {
      return (double.tryParse(current) ?? defaultValue) as T;
    }

    return defaultValue;
  }

  /// Returns a new map with only the specified keys
  Map<String, dynamic> selectKeys(List<String> keys) {
    final result = <String, dynamic>{};
    for (final key in keys) {
      if (containsKey(key)) {
        result[key] = this[key];
      }
    }
    return result;
  }

  /// Returns a new map without the specified keys
  Map<String, dynamic> excludeKeys(List<String> keys) {
    final result = <String, dynamic>{};
    forEach((key, value) {
      if (!keys.contains(key)) {
        result[key] = value;
      }
    });
    return result;
  }

  /// Transforms all keys in the map
  Map<String, dynamic> transformKeys(String Function(String key) transformer) {
    final result = <String, dynamic>{};
    forEach((key, value) {
      result[transformer(key)] = value;
    });
    return result;
  }

  /// Converts keys to camelCase
  Map<String, dynamic> get toCamelCase => transformKeys((key) => key.camelCase);

  /// Converts keys to snake_case
  Map<String, dynamic> get toSnakeCase => transformKeys((key) => key.snakeCase);

  /// Flattens a nested map with dot notation
  Map<String, dynamic> flatten() {
    final result = <String, dynamic>{};

    void process(dynamic obj, String prefix) {
      if (obj is Map) {
        obj.forEach((key, value) {
          final newKey = prefix.isEmpty ? key.toString() : '$prefix.$key';
          if (value is Map || value is List) {
            process(value, newKey);
          } else {
            result[newKey] = value;
          }
        });
      } else if (obj is List) {
        for (var i = 0; i < obj.length; i++) {
          process(obj[i], '$prefix[$i]');
        }
      }
    }

    process(this, '');
    return result;
  }

  /// Deep merge two maps
  Map<String, dynamic> deepMerge(Map<String, dynamic> other) {
    final result = Map<String, dynamic>.from(this);

    other.forEach((key, value) {
      if (result.containsKey(key)) {
        final thisValue = result[key];
        if (thisValue is Map<String, dynamic> && value is Map<String, dynamic>) {
          result[key] = thisValue.deepMerge(value);
        } else {
          result[key] = value;
        }
      } else {
        result[key] = value;
      }
    });

    return result;
  }

  /// Recursively remove null values from map
  Map<String, dynamic> removeNulls() {
    final result = <String, dynamic>{};

    forEach((key, value) {
      if (value != null) {
        if (value is Map<String, dynamic>) {
          result[key] = value.removeNulls();
        } else if (value is List) {
          result[key] = value.where((item) => item != null).toList();
        } else {
          result[key] = value;
        }
      }
    });

    return result;
  }
}
