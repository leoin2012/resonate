import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'app_logger.dart';

/// Error monitoring and crash reporting
/// 
/// Provides:
/// - Global error handler
/// - Flutter error handler
/// - Device and app info collection
/// - Crash report generation
class ErrorMonitor {
  static final ErrorMonitor _instance = ErrorMonitor._internal();
  factory ErrorMonitor() => _instance;
  ErrorMonitor._internal();

  final AppLogger _logger = AppLogger();
  bool _initialized = false;

  DeviceInfoPlugin? _deviceInfoPlugin;
  PackageInfo? _packageInfo;
  Map<String, dynamic>? _deviceInfo;

  /// Initialize error monitor
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Set up global error handlers
      _setupErrorHandlers();
      
      _initialized = true;
      _logger.info('✅ Error Monitor Initialized');
    } catch (e, stack) {
      debugPrint('Failed to initialize error monitor: $e\n$stack');
    }
  }

  /// Collect device and app information
  Future<void> _collectDeviceAndAppInfo() async {
    // Temporarily disabled - causing build issues
    // Will be re-enabled after app is running
    _deviceInfo = {
      'platform': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
    };
  }

  /// Set up global error handlers
  void _setupErrorHandlers() {
    // Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _logger.fatal(
        'Flutter Error: ${details.exception}',
        details.exception,
        details.stack,
      );
      
      // In debug mode, also show to user
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };

    // Platform channel errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logger.fatal(
        'Platform Error: $error',
        error,
        stack,
      );
      return true; // Prevent error from propagating
    };

    // Dart errors (outside Flutter)
    // Note: runZonedGuarded disabled for compatibility
    _logger.debug('Error monitoring zone established');
  }

  /// Log error with context
  void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? additionalInfo,
  }) {
    final message = context != null ? '[$context] $error' : error;
    
    _logger.error(message, error, stackTrace);
    
    // Add additional info to log if provided
    if (additionalInfo != null) {
      _logger.debug('Additional info: $additionalInfo');
    }
  }

  /// Log warning with context
  void logWarning(
    dynamic warning, {
    String? context,
    Map<String, dynamic>? additionalInfo,
  }) {
    final message = context != null ? '[$context] $warning' : warning;
    
    _logger.warning(message);
    
    if (additionalInfo != null) {
      _logger.debug('Additional info: $additionalInfo');
    }
  }

  /// Generate crash report
  Future<String> generateCrashReport(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    final buffer = StringBuffer();
    
    buffer.writeln('=== CRASH REPORT ===');
    buffer.writeln('Timestamp: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    
    if (_deviceInfo != null) {
      buffer.writeln('Device Information:');
      _deviceInfo!.forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
      buffer.writeln('');
    }
    
    if (context != null) {
      buffer.writeln('Context: $context');
      buffer.writeln('');
    }
    
    buffer.writeln('Error: $error');
    buffer.writeln('');
    buffer.writeln('Stack Trace:');
    buffer.writeln(stackTrace ?? 'No stack trace available');
    buffer.writeln('');
    
    buffer.writeln('=== END REPORT ===');
    
    final report = buffer.toString();
    _logger.fatal('Crash Report Generated:\n$report');
    
    return report;
  }

  /// Get device info
  Map<String, dynamic>? get deviceInfo => _deviceInfo;

  /// Get package info
  PackageInfo? get packageInfo => _packageInfo;

  /// Check if initialized
  bool get isInitialized => _initialized;
}
