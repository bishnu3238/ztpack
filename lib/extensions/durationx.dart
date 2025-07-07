/// Duration extensions
extension DurationX on Duration {
  // Formatting
  String get formatted {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String get formatHMS {
    final h = inHours;
    final m = inMinutes % 60;
    final s = inSeconds % 60;

    if (h > 0) {
      return '${h}h ${m}m ${s}s';
    } else if (m > 0) {
      return '${m}m ${s}s';
    } else {
      return '${s}s';
    }
  }

  String get hoursMinutes {
    final h = inHours;
    final m = inMinutes % 60;

    if (h > 0) {
      return '${h}h ${m}m';
    } else {
      return '${m}m';
    }
  }

  String get minutesSeconds {
    final m = inMinutes;
    final s = inSeconds % 60;

    if (m > 0) {
      return '${m}m ${s}s';
    } else {
      return '${s}s';
    }
  }

  // Arithmetic
  Duration operator +(Duration other) => Duration(microseconds: inMicroseconds + other.inMicroseconds);
  Duration operator -(Duration other) => Duration(microseconds: inMicroseconds - other.inMicroseconds);
  Duration operator *(num factor) => Duration(microseconds: (inMicroseconds * factor).round());
  Duration operator /(num factor) => Duration(microseconds: (inMicroseconds / factor).round());

  // Comparisons
  bool operator >(Duration other) => inMicroseconds > other.inMicroseconds;
  bool operator <(Duration other) => inMicroseconds < other.inMicroseconds;
  bool operator >=(Duration other) => inMicroseconds >= other.inMicroseconds;
  bool operator <=(Duration other) => inMicroseconds <= other.inMicroseconds;

  Duration abs() => Duration(microseconds: inMicroseconds.abs());
}