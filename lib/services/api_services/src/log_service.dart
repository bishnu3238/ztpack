import 'package:logger/logger.dart';

/// Logger service
class LogService {
  final Logger _logger;
  final bool enableLogging;

  LogService({this.enableLogging = true})
      : _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    level: Level.debug,
  );

  void debug(dynamic message) {
    if (enableLogging) _logger.d(message);
  }

  void info(dynamic message) {
    if (enableLogging) _logger.i(message);
  }

  void warning(dynamic message) {
    if (enableLogging) _logger.w(message);
  }

  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (enableLogging) _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void exception(dynamic error, [StackTrace? stackTrace]) {
    if (enableLogging) _logger.e('Exception', error: error, stackTrace: stackTrace);
  }

  void setLogLevel(Level level) {
    if (enableLogging) Logger.level = level;
  }
}