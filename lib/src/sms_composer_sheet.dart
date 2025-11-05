import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/sms_result.dart';
import 'widgets/sms_composer_widget.dart';

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
  /// [context] - Required for Android to show in-app bottom sheet
  /// 
  /// Returns [SmsResult] with operation details
  /// 
  /// Throws [ArgumentError] if recipients list is empty
  static Future<SmsResult> show({
    required List<String> recipients,
    String? body,
    BuildContext? context,
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

    // Platform-specific implementation
    if (Platform.isAndroid && context != null) {
      // Use custom in-app bottom sheet for Android
      return _showAndroidBottomSheet(context, cleanRecipients, body);
    } else {
      // Use native implementation for iOS or when context is not provided
      return _showNative(cleanRecipients, body);
    }
  }

  /// Show native SMS composer (iOS or fallback Android)
  static Future<SmsResult> _showNative(List<String> recipients, String? body) async {
    try {
      final result = await _channel.invokeMethod('show', {
        'recipients': recipients,
        'body': body ?? '',
      });

      if (result is Map) {
        // Convert Map<Object?, Object?> to Map<String, dynamic>
        final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
        return SmsResult.fromMap(resultMap);
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

  /// Show custom Android bottom sheet SMS composer
  static Future<SmsResult> _showAndroidBottomSheet(
    BuildContext context,
    List<String> recipients,
    String? body,
  ) async {
    try {
      final completer = Completer<SmsResult>();
      
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SmsComposerWidget(
              recipients: recipients,
              initialBody: body,
              onResult: (result) {
                if (!completer.isCompleted) {
                  completer.complete(result);
                }
              },
            ),
          );
        },
      );

      // If bottom sheet was dismissed without sending
      if (!completer.isCompleted) {
        completer.complete(const SmsResult(
          presented: true,
          sent: false,
          platformResult: 'dismissed',
        ));
      }

      return completer.future;
    } catch (e) {
      return SmsResult(
        presented: false,
        sent: false,
        error: 'Failed to show SMS composer: $e',
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

  /// Check SMS permission status (Android only)
  /// 
  /// Returns detailed information about SMS permission status
  static Future<Map<String, dynamic>> checkPermissionStatus() async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod('checkSmsPermission');
        return Map<String, dynamic>.from(result);
      } else {
        return {
          'hasPermission': true,
          'message': 'iOS does not require explicit SMS permission',
          'platform': 'iOS'
        };
      }
    } catch (e) {
      return {
        'hasPermission': false,
        'message': 'Failed to check permission: $e',
        'platform': Platform.isAndroid ? 'Android' : 'iOS'
      };
    }
  }
}