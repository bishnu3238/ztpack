import 'listx.dart';
// Iterable Extensions
extension IterableX<T> on Iterable<T> {
  /// Groups elements by a key selector
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final result = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      result.putIfAbsent(key, () => []).add(item);
    }
    return result;
  }

  /// Finds the first element or returns null
  T? firstOrNull([bool Function(T)? predicate]) {
    if (predicate == null) {
      return isEmpty ? null : first;
    }
    return cast<T>().firstOrNull(predicate);
  }

  /// Finds the last element or returns null
  T? lastOrNull([bool Function(T)? predicate]) {
    if (predicate == null) {
      return isEmpty ? null : last;
    }
    return cast<T>().lastOrNull(predicate);
  }

  /// Maps elements with their indices
  Iterable<R> mapIndexed<R>(R Function(T, int) transform) sync* {
    var index = 0;
    for (final item in this) {
      yield transform(item, index++);
    }
  }

  /// Filters out null elements
  Iterable<T> whereNotNull() => where((e) => e != null);

  /// Counts elements matching a predicate
  int count([bool Function(T)? predicate]) {
    if (predicate == null) return length;
    return where(predicate).length;
  }

  /// Partitions into two lists based on a predicate
  (List<T>, List<T>) partition(bool Function(T) predicate) {
    final trueList = <T>[];
    final falseList = <T>[];
    for (final item in this) {
      if (predicate(item)) {
        trueList.add(item);
      } else {
        falseList.add(item);
      }
    }
    return (trueList, falseList);
  }
}