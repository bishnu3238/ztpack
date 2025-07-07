import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'dart:developer' as dev;

/// Ultimate advanced extensions for DateTime in Flutter
extension UltimateDateTime on DateTime {
  // BASIC LOGGING & UTILITY
  get log => dev.log(toString());



  String toShortDate() {
    return DateFormat('M/d/yyyy').format(this);
  }

  /// Format as a medium date (e.g., "Apr 11, 2025")
  String toMediumDate() {
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Format as a long date (e.g., "April 11, 2025")
  String toLongDate() {
    return DateFormat('MMMM d, yyyy').format(this);
  }

  /// Format as a full date with day of week (e.g., "Friday, April 11, 2025")
  String toFullDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(this);
  }

  /// Format as short time (e.g., "2:30 PM")
  String toShortTime() {
    return DateFormat('h:mm a').format(this);
  }

  /// Format as time with seconds (e.g., "2:30:45 PM")
  String toTimeWithSeconds() {
    return DateFormat('h:mm:ss a').format(this);
  }

  /// Format as 24-hour time (e.g., "14:30")
  String toMilitaryTime() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format as short date and time (e.g., "4/11/2025 2:30 PM")
  String toShortDateTime() {
    return DateFormat('M/d/yyyy h:mm a').format(this);
  }

  /// Format as medium date and time (e.g., "Apr 11, 2025 2:30 PM")
  String toMediumDateTime() {
    return DateFormat('MMM d, yyyy h:mm a').format(this);
  }


  // BASIC COMPARISON OPERATORS
  bool get isToday {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.year == year &&
        yesterday.month == month &&
        yesterday.day == day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.year == year &&
        tomorrow.month == month &&
        tomorrow.day == day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return isAfter(weekStart) && isBefore(weekEnd.add(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return now.year == year && now.month == month;
  }

  bool get isThisYear {
    return DateTime.now().year == year;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;
  bool isSameYear(DateTime other) => year == other.year;
  bool isBetween(DateTime start, DateTime end) =>
      isAfter(start) && isBefore(end);

  // BASIC DATE FORMATTING
  String get toDMY => DateFormat('dd MMM yyyy').format(this);
  String get toYMD => DateFormat('yyyy MMM dd').format(this);
  String get toMDY => DateFormat('MMM dd, yyyy').format(this);

  // ADVANCED FORMATTING - DAY AND MONTH NAMES
  String get dayName => DateFormat('EEEE').format(this); // "Monday"
  String get shortDayName => DateFormat('EEE').format(this); // "Mon"
  String get monthName => DateFormat('MMMM').format(this); // "January"
  String get shortMonthName => DateFormat('MMM').format(this); // "Jan"

  // ADVANCED FORMATTING - NUMERIC FORMATS
  String get numeric => DateFormat('yyyy-MM-dd').format(this);
  String get slashFormat => DateFormat('dd/MM/yyyy').format(this);
  String get usSlashFormat => DateFormat('MM/dd/yyyy').format(this);
  String get dotFormat => DateFormat('dd.MM.yyyy').format(this);

  // DATE COMPONENTS FORMATTING
  String get yearMonth => DateFormat('yyyy-MM').format(this);
  String get monthDay => DateFormat('MM-dd').format(this);
  String get shortDate => DateFormat('d MMM').format(this); // "5 Jan"

  // TIME FORMATTING
  String get time12Hour => DateFormat('h:mm a').format(this); // "2:30 PM"
  String get time24Hour => DateFormat('HH:mm').format(this); // "14:30"
  String get timeWithSeconds =>
      DateFormat('HH:mm:ss').format(this); // "14:30:45"
  String get timeWithMilliseconds =>
      DateFormat('HH:mm:ss.SSS').format(this); // "14:30:45.123"

  // COMBINED DATE-TIME FORMATS
  String get fullDateTime =>
      DateFormat('EEEE, MMMM d, yyyy HH:mm:ss').format(this);
  String get shortDateTime => DateFormat('yyyy-MM-dd HH:mm').format(this);
  String get mediumDateTime => DateFormat('MMM d, yyyy h:mm a').format(this);
  String get isoFormat => toIso8601String();

  // SPECIALIZED FORMATTING
  String get filenameFormat =>
      DateFormat('yyyy-MM-dd_HH-mm-ss').format(this); // For filenames
  String get apiFormat => toUtc().toIso8601String(); // For API requests
  String get rfc2822Format =>
      '${DateFormat('EEE, dd MMM yyyy HH:mm:ss').format(this)} GMT'; // For email headers
  String get rfc3339Format =>
      toUtc().toIso8601String().replaceAll('Z', '-00:00');
  String get calendarHeader => DateFormat('MMMM yyyy').format(this);

  // RELATIVE TIME - PAST
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 5) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // RELATIVE TIME - FUTURE
  String get fromNow {
    final now = DateTime.now();
    final difference = now.difference(now);

    if (difference.inSeconds < 5) {
      return 'In a moment';
    } else if (difference.inSeconds < 60) {
      return 'In ${difference.inSeconds} seconds';
    } else if (difference.inMinutes < 60) {
      return 'In ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else if (difference.inHours < 24) {
      return 'In ${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (difference.inDays < 7) {
      return 'In ${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'In $weeks ${weeks == 1 ? 'week' : 'weeks'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'In $months ${months == 1 ? 'month' : 'months'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'In $years ${years == 1 ? 'year' : 'years'}';
    }
  }

  // UNIFIED RELATIVE TIME WITH OPTIONS
  String relativeToNow({
    bool short = false,
    bool includeTime = false,
    bool roundUp = false,
    int shortLimit = 7, // Days before switching to short date
  }) {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      // Future date
      final absDifference = difference.abs();

      if (absDifference.inSeconds < 5) {
        return short ? 'now' : 'In a moment';
      } else if (absDifference.inSeconds < 60) {
        return short
            ? '${absDifference.inSeconds}s'
            : 'In ${absDifference.inSeconds} seconds';
      } else if (absDifference.inMinutes < 60) {
        return short
            ? '${absDifference.inMinutes}m'
            : 'In ${absDifference.inMinutes} min';
      } else if (absDifference.inHours < 24) {
        return short
            ? '${absDifference.inHours}h'
            : 'In ${absDifference.inHours} hrs';
      } else if (absDifference.inDays < shortLimit) {
        return short
            ? '${absDifference.inDays}d'
            : 'In ${absDifference.inDays} days';
      } else {
        return includeTime ? shortDateTime : shortDate;
      }
    } else {
      // Past date
      if (difference.inSeconds < 5) {
        return short ? 'now' : 'Just now';
      } else if (difference.inSeconds < 60) {
        return short
            ? '${difference.inSeconds}s'
            : '${difference.inSeconds} seconds ago';
      } else if (difference.inMinutes < 60) {
        return short
            ? '${difference.inMinutes}m'
            : '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return short
            ? '${difference.inHours}h'
            : '${difference.inHours} hrs ago';
      } else if (difference.inDays < shortLimit) {
        return short
            ? '${difference.inDays}d'
            : '${difference.inDays} days ago';
      } else {
        return includeTime ? shortDateTime : shortDate;
      }
    }
  }

  // SMART FORMATTING BASED ON DATE RECENCY
  String get smartFormat {
    if (isToday) {
      return 'Today, ${time12Hour}';
    } else if (isYesterday) {
      return 'Yesterday, ${time12Hour}';
    } else if (isTomorrow) {
      return 'Tomorrow, ${time12Hour}';
    } else if (isThisWeek) {
      return '${dayName}, ${time12Hour}';
    } else if (isThisYear) {
      return DateFormat('d MMM, HH:mm').format(this);
    } else {
      return DateFormat('d MMM yyyy, HH:mm').format(this);
    }
  }

  // CALENDAR UTILITIES
  DateTime get firstDayOfMonth => DateTime(year, month, 1);
  DateTime get lastDayOfMonth => DateTime(year, month + 1, 0);

  DateTime get firstDayOfWeek => subtract(Duration(days: weekday - 1));
  DateTime get lastDayOfWeek =>
      add(Duration(days: DateTime.daysPerWeek - weekday));

  // TIME BOUNDARIES
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfMonth => DateTime(year, month, 1);
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  DateTime get startOfYear => DateTime(year, 1, 1);
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  // QUARTER HANDLING
  int get quarter => ((month - 1) ~/ 3) + 1;
  DateTime get startOfQuarter => DateTime(year, 3 * quarter - 2, 1);
  DateTime get endOfQuarter =>
      DateTime(year, 3 * quarter + 1, 0, 23, 59, 59, 999);
  String get quarterName => 'Q$quarter $year';

  // WEEK HANDLING
  int get weekOfYear {
    // The week containing January 4th is the first week of the year
    final firstDayOfYear = DateTime(year, 1, 1);
    final dayOfYear = difference(firstDayOfYear).inDays;

    // Calculate the offset to get to the first day of the week
    int firstDayOffset = (firstDayOfYear.weekday - 1) % 7;

    // Calculate week number
    return ((dayOfYear + firstDayOffset) / 7).ceil();
  }

  // AGE CALCULATION
  int get age {
    final now = DateTime.now();
    int years = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      years--;
    }
    return years;
  }

  // MANIPULATION METHODS
  DateTime addTime({
    int years = 0,
    int months = 0,
    int weeks = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int milliseconds = 0,
    int microseconds = 0,
  }) {
    DateTime result = this;

    if (years != 0) {
      result = DateTime(
        result.year + years,
        result.month,
        result.day,
        result.hour,
        result.minute,
        result.second,
        result.millisecond,
        result.microsecond,
      );
    }

    if (months != 0) {
      int newMonth = result.month + months;
      int yearDelta = (newMonth - 1) ~/ 12;
      newMonth = ((newMonth - 1) % 12) + 1;

      int newDay = result.day;
      // Handle cases where the day might be invalid (e.g., trying to get Feb 30)
      int daysInMonth = DateTime(result.year + yearDelta, newMonth + 1, 0).day;
      if (newDay > daysInMonth) {
        newDay = daysInMonth;
      }

      result = DateTime(
        result.year + yearDelta,
        newMonth,
        newDay,
        result.hour,
        result.minute,
        result.second,
        result.millisecond,
        result.microsecond,
      );
    }

    if (weeks != 0) {
      days += weeks * 7;
    }

    if (days != 0 ||
        hours != 0 ||
        minutes != 0 ||
        seconds != 0 ||
        milliseconds != 0 ||
        microseconds != 0) {
      result = result.add(
        Duration(
          days: days,
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
          microseconds: microseconds,
        ),
      );
    }

    return result;
  }

  DateTime subtractTime({
    int years = 0,
    int months = 0,
    int weeks = 0,
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int milliseconds = 0,
    int microseconds = 0,
  }) {
    return addTime(
      years: -years,
      months: -months,
      weeks: -weeks,
      days: -days,
      hours: -hours,
      minutes: -minutes,
      seconds: -seconds,
      milliseconds: -milliseconds,
      microseconds: -microseconds,
    );
  }

  // Gets the next occurrence of a specific weekday
  DateTime nextWeekday(int weekday) {
    if (weekday < 1 || weekday > 7) {
      throw ArgumentError('Weekday must be between 1 (Monday) and 7 (Sunday)');
    }

    int daysUntilNextWeekday = (weekday - this.weekday) % 7;
    if (daysUntilNextWeekday == 0) {
      daysUntilNextWeekday = 7; // If same day, get next week
    }

    return add(Duration(days: daysUntilNextWeekday));
  }

  // Gets the previous occurrence of a specific weekday
  DateTime previousWeekday(int weekday) {
    if (weekday < 1 || weekday > 7) {
      throw ArgumentError('Weekday must be between 1 (Monday) and 7 (Sunday)');
    }

    int daysSincePreviousWeekday = (this.weekday - weekday) % 7;
    if (daysSincePreviousWeekday == 0) {
      daysSincePreviousWeekday = 7; // If same day, get previous week
    }

    return subtract(Duration(days: daysSincePreviousWeekday));
  }

  // BUSINESS DAY CALCULATIONS
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;
  bool get isWeekday => !isWeekend;

  DateTime get nextBusinessDay {
    DateTime date = add(const Duration(days: 1));
    while (date.isWeekend) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  DateTime get previousBusinessDay {
    DateTime date = subtract(const Duration(days: 1));
    while (date.isWeekend) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }

  int businessDaysBetween(DateTime other) {
    if (isAfter(other)) {
      return -other.businessDaysBetween(this);
    }

    int count = 0;
    DateTime date = this;

    while (date.isBefore(other)) {
      date = date.add(const Duration(days: 1));
      if (date.isWeekday && date.isBefore(other)) count++;
    }

    return count;
  }

  // TIMEZONE HANDLING
  DateTime toLocalTime() => toLocal();
  DateTime toUniversalTime() => toUtc();

  String get timezoneName {
    final offset = timeZoneOffset;
    final hours = offset.inHours;
    final minutes = (offset.inMinutes - hours * 60).abs().toString().padLeft(
      2,
      '0',
    );

    final sign = offset.isNegative ? '-' : '+';
    return 'UTC$sign${hours.abs()}:$minutes';
  }

  // ADVANCED FORMATTING WITH OPTIONS
  String format({String pattern = 'yyyy-MM-dd', String? locale}) {
    return locale != null
        ? DateFormat(pattern, locale).format(this)
        : DateFormat(pattern).format(this);
  }

  // LOCALIZED FORMATTING
  String localizedFormat(String locale) {
    switch (locale.toLowerCase()) {
      case 'en_us':
        return DateFormat('MM/dd/yyyy').format(this);
      case 'en_gb':
        return DateFormat('dd/MM/yyyy').format(this);
      case 'fr':
        return DateFormat('dd/MM/yyyy').format(this);
      case 'de':
        return DateFormat('dd.MM.yyyy').format(this);
      case 'es':
        return DateFormat('dd/MM/yyyy').format(this);
      case 'ja':
        return DateFormat('yyyy年MM月dd日').format(this);
      case 'zh':
        return DateFormat('yyyy年MM月dd日').format(this);
      default:
        return DateFormat('yyyy-MM-dd').format(this);
    }
  }

  // CALENDAR DISPLAY HELPERS
  List<DateTime> daysInMonth() {
    final List<DateTime> days = [];
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(year, month, i));
    }

    return days;
  }

  List<DateTime> daysInCalendarMonth({bool startOnMonday = true}) {
    final List<DateTime> days = [];
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    // Adjust first day of week (Monday or Sunday)
    int firstDayOfWeek = startOnMonday ? 1 : 7; // 1 for Monday, 7 for Sunday

    // Calculate days from previous month to include
    int previousMonthDays = (firstDay.weekday - firstDayOfWeek) % 7;
    if (previousMonthDays < 0) previousMonthDays += 7;

    final firstDayToShow = firstDay.subtract(Duration(days: previousMonthDays));

    // Create array of 42 days (6 weeks)
    for (int i = 0; i < 42; i++) {
      days.add(firstDayToShow.add(Duration(days: i)));
    }

    return days;
  }

  // UTILITY METHODS
  Duration durationUntil(DateTime other) => other.difference(this);
  Duration durationSince(DateTime other) => difference(other);

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  // SERIALIZATION & PARSING
  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'day': day,
    'hour': hour,
    'minute': minute,
    'second': second,
    'millisecond': millisecond,
    'microsecond': microsecond,
    'timezone': timeZoneName,
  };

  // ADVANCED TIME CALCULATIONS
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  int get dayOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    return difference(firstDayOfYear).inDays + 1;
  }

  int get daysInCurrentMonth => DateTime(year, month + 1, 0).day;

  int get weeksInMonth {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final daysInMonth = lastDay.day;

    // Calculate the day of week of the first day (0-6, where 0 is Monday)
    final firstDayWeekday = (firstDay.weekday - 1) % 7;

    // Calculate total calendar days including days from previous/next months
    final totalCalendarDays = daysInMonth + firstDayWeekday;

    // Calculate weeks
    return (totalCalendarDays / 7).ceil();
  }

  // COUNTDOWN FORMATTING
  String countdownFormat() {
    final now = DateTime.now();
    if (isBefore(now)) return 'Expired';

    final diff = difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m ${seconds}s';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // COMPACT DATE RANGES
  String rangeUntil(DateTime end) {
    if (year == end.year) {
      if (month == end.month) {
        if (day == end.day) {
          // Same day
          return DateFormat('MMM d, yyyy').format(this);
        } else {
          // Same month
          return '${DateFormat('MMM d').format(this)} - ${DateFormat('d, yyyy').format(end)}';
        }
      } else {
        // Same year, different month
        return '${DateFormat('MMM d').format(this)} - ${DateFormat('MMM d, yyyy').format(end)}';
      }
    } else {
      // Different years
      return '${DateFormat('MMM d, yyyy').format(this)} - ${DateFormat('MMM d, yyyy').format(end)}';
    }
  }

  // PARSING UTILITIES
  static DateTime? tryParse(String input) {
    try {
      return DateTime.parse(input);
    } catch (e) {
      try {
        // Try different formats
        for (final format in [
          'yyyy-MM-dd',
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-ddTHH:mm:ss',
          'dd/MM/yyyy',
          'MM/dd/yyyy',
          'dd-MM-yyyy',
          'MM-dd-yyyy',
          'dd.MM.yyyy',
        ]) {
          try {
            return DateFormat(format).parse(input);
          } catch (e) {
            // Try next format
          }
        }

        // Try month name formats
        RegExp monthNameRegex = RegExp(
          r"^(?<month>\w{3,}) (?<day>\d{1,2})(,)? (?<year>\d{4})$",
          caseSensitive: false,
        );
        Match? monthNameMatch = monthNameRegex.firstMatch(input);
        if (monthNameMatch != null) {
          final Map<String, int> monthNames = {
            "january": 1,
            "february": 2,
            "march": 3,
            "april": 4,
            "may": 5,
            "june": 6,
            "july": 7,
            "august": 8,
            "september": 9,
            "october": 10,
            "november": 11,
            "december": 12,
            "jan": 1,
            "feb": 2,
            "mar": 3,
            "apr": 4,
            "jun": 6,
            "jul": 7,
            "aug": 8,
            "sep": 9,
            "oct": 10,
            "nov": 11,
            "dec": 12,
          };

          final monthName = monthNameMatch.group(1)!.toLowerCase();
          final monthNum = monthNames[monthName];
          if (monthNum != null) {
            return DateTime(
              int.parse(monthNameMatch.group(3)!),
              monthNum,
              int.parse(monthNameMatch.group(2)!),
            );
          }
        }

        // Try two-digit year format (MM/DD/YY)
        RegExp twoDigitYearRegex = RegExp(
          r"^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2})$",
        );
        Match? twoDigitYearMatch = twoDigitYearRegex.firstMatch(input);
        if (twoDigitYearMatch != null) {
          int month = int.parse(twoDigitYearMatch.group(1)!);
          int day = int.parse(twoDigitYearMatch.group(2)!);
          int year = int.parse(twoDigitYearMatch.group(3)!);

          if (year < 50) {
            year += 2000;
          } else {
            year += 1900;
          }

          return DateTime(year, month, day);
        }

        return null;
      } catch (e) {
        return null;
      }
    }
  }

  // CUSTOM FORMATTING HELPERS
  String customFormat({
    bool showDate = true,
    bool showTime = true,
    bool showWeekday = false,
    bool useShortNames = false,
    String dateDelimiter = '/',
    String timeDelimiter = ':',
    bool use24Hour = false,
    bool includeSeconds = false,
  }) {
    String result = '';

    // Add weekday if requested
    if (showWeekday) {
      result += useShortNames ? '$shortDayName, ' : '$dayName, ';
    }

    // Add date if requested
    if (showDate) {
      final monthStr = useShortNames ? shortMonthName : monthName;
      switch (dateDelimiter) {
        case '.':
          result += '${day.toString().padLeft(2, '0')}.$month.$year';
          break;
        case '-':
          result +=
              '${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
          break;
        case ' ':
          result += '$day $monthStr $year';
          break;
        default: // '/'
          result +=
              '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
      }
    }

    // Add time if requested
    if (showTime) {
      if (showDate) result += ' ';

      if (use24Hour) {
        result +=
            '${hour.toString().padLeft(2, '0')}$timeDelimiter${minute.toString().padLeft(2, '0')}';
        if (includeSeconds) {
          result += '$timeDelimiter${second.toString().padLeft(2, '0')}';
        }
      } else {
        int hour12 = hour % 12;
        if (hour12 == 0) hour12 = 12;
        result +=
            '${hour12.toString().padLeft(2, '0')}$timeDelimiter${minute.toString().padLeft(2, '0')}';
        if (includeSeconds) {
          result += '$timeDelimiter${second.toString().padLeft(2, '0')}';
        }
        result += ' ${hour < 12 ? "AM" : "PM"}';
      }
    }

    return result;
  }
  DateTime addDays(int days) => add(Duration(days: days));
  DateTime addMonths(int months) {
    var month = this.month + months;
    var year = this.year;

    while (month > 12) {
      month -= 12;
      year++;
    }
    while (month < 1) {
      month += 12;
      year--;
    }

    var day = math.min(this.day, DateUtils.getDaysInMonth(year, month));
    return DateTime(year, month, day, hour, minute, second, millisecond, microsecond);
  }

  DateTime addYears(int years) => DateTime(
      year + years, month,
      math.min(day, DateUtils.getDaysInMonth(year + years, month)),
      hour, minute, second, millisecond, microsecond
  );
}


