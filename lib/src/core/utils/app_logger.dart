import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/// App logger manager
/// 
/// Provides centralized logging with:
/// - Console output with colored formatting
/// - File output for debugging
/// - Automatic log file rotation
/// - Multiple log levels (debug, info, warning, error, fatal)
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  factory AppLogger() => _instance;
  AppLogger._internal();

  late Logger _logger;
  late File _logFile;
  bool _initialized = false;

  /// Initialize logger
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get application documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String logPath = '${appDocDir.path}/logs';
      
      // Create logs directory if not exists
      final Directory logDir = Directory(logPath);
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // Create log file with timestamp
      final String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _logFile = File('$logPath/app_$timestamp.log');
      await _logFile.create();

      // Initialize logger with multiple outputs
      _logger = Logger(
        level: kDebugMode ? Level.debug : Level.info,
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
        output: MultiOutput([
          ConsoleOutput(),
          FileOutput(_logFile),
        ]),
      );

      _initialized = true;
      
      _logger.i('=== App Logger Initialized ===');
      _logger.i('Log file: ${_logFile.path}');
      _logger.i('Debug mode: $kDebugMode');
      _logger.i('Platform: ${Platform.operatingSystem}');
    } catch (e, stack) {
      debugPrint('Failed to initialize logger: $e\n$stack');
    }
  }

  /// Debug level logging
  void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    } else {
      debugPrint('[DEBUG] $message');
    }
  }

  /// Info level logging
  void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    } else {
      debugPrint('[INFO] $message');
    }
  }

  /// Warning level logging
  void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    } else {
      debugPrint('[WARN] $message');
    }
  }

  /// Error level logging
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    } else {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Fatal level logging
  void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_initialized) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    } else {
      debugPrint('[FATAL] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log application lifecycle event
  void logLifecycle(String event) {
    final timestamp = DateTime.now().toIso8601String();
    info('🔄 Lifecycle: $event at $timestamp');
  }

  /// Log widget build
  void logWidgetBuild(String widgetName, {Map<String, dynamic>? params}) {
    debug('🏗️  Build: $widgetName ${params != null ? 'with $params' : ''}');
  }

  /// Log state change
  void logStateChange(String providerName, dynamic state) {
    debug('📊 State: $providerName changed to $state');
  }

  /// Log user action
  void logUserAction(String action, {Map<String, dynamic>? details}) {
    info('👤 Action: $action ${details != null ? '- $details' : ''}');
  }

  /// Log network request
  void logNetworkRequest(String url, {String? method, Map<String, dynamic>? body}) {
    debug('🌐 Request: $method $url ${body != null ? 'with body: $body' : ''}');
  }

  /// Log network response
  void logNetworkResponse(String url, int statusCode, {dynamic data}) {
    debug('📡 Response: $url - Status: $statusCode ${data != null ? '- Data: $data' : ''}');
  }

  /// Get log file path
  String? get logFilePath => _initialized ? _logFile.path : null;

  /// Get log file content
  Future<String> getLogFileContent() async {
    if (!_initialized) return 'Logger not initialized';
    
    try {
      return await _logFile.readAsString();
    } catch (e) {
      error('Failed to read log file', e);
      return 'Error reading log file: $e';
    }
  }

  /// Clear old log files (keep only last 5)
  Future<void> clearOldLogs() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory logDir = Directory('${appDocDir.path}/logs');
      
      if (!await logDir.exists()) return;

      final List<FileSystemEntity> files = await logDir.list().toList();
      final List<File> logFiles = files.whereType<File>().toList();

      // Sort by modified time
      logFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      // Delete old logs (keep last 5)
      for (int i = 5; i < logFiles.length; i++) {
        try {
          await logFiles[i].delete();
          debug('Deleted old log file: ${logFiles[i].path}');
        } catch (e) {
          error('Failed to delete old log file: ${logFiles[i].path}', e);
        }
      }
    } catch (e) {
      error('Failed to clear old logs', e);
    }
  }
}

/// Custom console output for Logger
class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final String line in event.lines) {
      debugPrint(line);
    }
  }
}

/// Custom file output for Logger
class FileOutput extends LogOutput {
  final File file;
  final IOSink? sink;

  FileOutput(this.file) : sink = file.openWrite(mode: FileMode.append);

  @override
  void output(OutputEvent event) {
    if (sink == null) return;
    
    for (final String line in event.lines) {
      sink!.writeln(line);
    }
  }

  @override
  Future<void> destroy() async {
    sink?.close();
  }
}
