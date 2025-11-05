import 'dart:io';
import 'package:flutter/services.dart';
import 'models/sms_result.dart';

/// SMS Composer Sheet Plugin
/// 
/// Provides a unified interface for SMS composition with bottom sheet UI
/// on both iOS and Android platforms.
/// 
/// iOS: Uses native MFMessageComposeViewController
/// Android: Uses native SMS intent with bottom sheet presentation
class SmsComposerSheet {
  static const MethodChannel _channel = MethodChannel('sms_composer_sheet');

  /// Show SMS composer as a bottom sheet
  /// 
  /// [recipients] - List of phone numbers (required, non-empty)
  /// [body] - Optional pre-filled message body
  /// 
  /// Returns [SmsResult] with operation details
  /// 
  /// Throws [ArgumentError] if recipients list is empty
  static Future<SmsResult> show({
    required List<String> recipients,
    String? body,
  }) async {
    // Input validation
    if (recipients.isEmpty) {
      throw ArgumentError('Recipients list cannot be empty');
    }

    // Clean recipients (remove empty strings and trim whitespace)
    final cleanRecipients = recipients
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    if (cleanRecipients.isEmpty) {
      throw ArgumentError('No valid recipients provided');
    }

    try {
      final result = await _channel.invokeMethod('show', {
        'recipients': cleanRecipients,
        'body': body ?? '',
      });

      if (result is Map<String, dynamic>) {
        return SmsResult.fromMap(result);
      } else {
        return SmsResult(
          presented: false,
          sent: false,
          error: 'Invalid response from platform: ${result.runtimeType}',
        );
      }
    } on PlatformException catch (e) {
      return SmsResult(
        presented: false,
        sent: false,
        error: 'Platform error: ${e.message}',
        platformResult: e.code,
      );
    } catch (e) {
      return SmsResult(
        presented: false,
        sent: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  /// Check if SMS can be sent on the current platform
  /// 
  /// Returns true if SMS functionality is available, false otherwise
  static Future<bool> canSendSms() async {
    try {
      final result = await _channel.invokeMethod('canSendSms');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get the current platform (for debugging purposes)
  /// 
  /// Returns a string identifying the platform
  static String get platformName {
    if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else {
      return 'Unsupported';
    }
  }
}