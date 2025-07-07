

// Stream Extensions
import 'dart:developer' as dev;

extension StreamX<T> on Stream<T> {
  /// Logs each event emitted by the stream
  Stream<T> logEvents([String tag = 'Stream']) {
    return map((event) {
      dev.log('[$tag] Stream event: $event');
      return event;
    });
  }

  /// Buffers events into lists of specified size
  Stream<List<T>> buffer(int count) async* {
    final buffer = <T>[];
    await for (final event in this) {
      buffer.add(event);
      if (buffer.length >= count) {
        yield List<T>.from(buffer);
        buffer.clear();
      }
    }
    if (buffer.isNotEmpty) {
      yield List<T>.from(buffer);
    }
  }

  /// Delays each event by the specified duration
  Stream<T> delay(Duration duration) async* {
    await for (final event in this) {
      await Future.delayed(duration);
      yield event;
    }
  }

  // /// Maps events to another type with error handling
  // Stream<R> safeMap<R>(R Function(T) transform) {
  //   return transformEvents((event, sink) {
  //     try {
  //       sink.add(transform(event));
  //     } catch (e) {
  //       sink.addError(e);
  //     }
  //   });
  // }

  /// Throttles the stream to emit events at most once per duration
  Stream<T> throttle(Duration duration) async* {
    T? lastEvent;
    DateTime? lastEmission;
    await for (final event in this) {
      final now = DateTime.now();
      lastEvent = event;
      if (lastEmission == null || now.difference(lastEmission).inMilliseconds >= duration.inMilliseconds) {
        yield event;
        lastEmission = now;
      }
    }
  }
}