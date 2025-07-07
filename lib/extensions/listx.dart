
import 'dart:math' as math;

/// List extensions
extension ListX<T> on List<T> {
  /// Get element at index safely (returns null if out of bounds)
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get element at index with default value
  T elementAtOrDefault(int index, T defaultValue) {
    if (index < 0 || index >= length) return defaultValue;
    return this[index];
  }

  /// Transform list to map with custom key selector
  Map<K, T> toMap<K>(K Function(T item) keySelector) {
    final result = <K, T>{};
    for (final item in this) {
      result[keySelector(item)] = item;
    }
    return result;
  }

  /// Group by a common property
  Map<K, List<T>> groupBy<K>(K Function(T item) keySelector) {
    final result = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      result.putIfAbsent(key, () => []).add(item);
    }
    return result;
  }

  /// Partition list into two lists based on predicate
  List<List<T>> partition(bool Function(T item) predicate) {
    final trueList = <T>[];
    final falseList = <T>[];

    for (final item in this) {
      if (predicate(item)) {
        trueList.add(item);
      } else {
        falseList.add(item);
      }
    }

    return [trueList, falseList];
  }

  /// Get distinct elements by a specific property
  List<T> distinctBy<K>(K Function(T item) keySelector) {
    final result = <T>[];
    final keys = <K>{};

    for (final item in this) {
      final key = keySelector(item);
      if (!keys.contains(key)) {
        keys.add(key);
        result.add(item);
      }
    }

    return result;
  }

  /// Split list into chunks of specified size
  List<List<T>> chunked(int size) {
    if (size <= 0) return [this];

    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, math.min(i + size, length)));
    }

    return result;
  }

  /// Check if all elements satisfy predicate
  bool all(bool Function(T item) predicate) {
    for (final item in this) {
      if (!predicate(item)) return false;
    }
    return true;
  }

  /// Check if any element satisfies predicate
  bool any(bool Function(T item) predicate) {
    for (final item in this) {
      if (predicate(item)) return true;
    }
    return false;
  }

  /// Check if no element satisfies predicate
  bool none(bool Function(T item) predicate) {
    return !any(predicate);
  }

  /// Get random element
  T? get randomOrNull => isEmpty ? null : this[math.Random().nextInt(length)];

  /// Shuffle and return a new list
  List<T> get shuffled {
    final result = List<T>.from(this);
    result.shuffle();
    return result;
  }

  /// Find index of first element matching predicate
  int indexOfFirstOrNull(bool Function(T item) predicate) {
    for (var i = 0; i < length; i++) {
      if (predicate(this[i])) return i;
    }
    return -1;
  }

  /// Sum elements (for numeric lists)
  num sum() {
    if (isEmpty) return 0;
    if (T is num) {
      return fold<num>(0, (sum, item) => sum + (item as num));
    }
    throw Exception('Sum operation is only applicable to numeric lists');
  }

  /// Average of elements (for numeric lists)
  double average() {
    if (isEmpty) return 0;
    if (T is num) {
      return sum() / length;
    }
    throw Exception('Average operation is only applicable to numeric lists');
  }
}