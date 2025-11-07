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

  /// Show SMS composer with custom UI options
  ///
  /// [recipients] - List of phone numbers (required, non-empty)
  /// [body] - Optional pre-filled message body
  /// [context] - Required for Android custom bottom sheet
  /// [useCustomBottomSheet] - For Android: use Flutter bottom sheet (true) or native intent (false)
  /// [bottomSheetBuilder] - Custom builder for Android bottom sheet
  ///
  /// Returns [SmsResult] with operation details
  ///
  /// Throws [ArgumentError] if recipients list is empty
  static Future<SmsResult> show({
    required List<String> recipients,
    String? body,
    BuildContext? context,
    bool useCustomBottomSheet = true,
    Widget Function(BuildContext, List<String>, String?, Function(SmsResult))? bottomSheetBuilder,
  }) async {
    // Input validation
    if (recipients.isEmpty) {
      throw ArgumentError('Recipients list cannot be empty');
    }

    // Clean recipients (remove empty strings and trim whitespace)
    final cleanRecipients =
        recipients.map((r) => r.trim()).where((r) => r.isNotEmpty).toList();

    if (cleanRecipients.isEmpty) {
      throw ArgumentError('No valid recipients provided');
    }

    // Platform-specific implementation
    if (Platform.isAndroid && context != null && useCustomBottomSheet) {
      // Use custom in-app bottom sheet for Android
      return _showAndroidBottomSheet(context, cleanRecipients, body, bottomSheetBuilder);
    } else {
      // Use native implementation for iOS or when custom bottom sheet is disabled
      return _showNative(cleanRecipients, body);
    }
  }

  /// Show native SMS composer (iOS or fallback Android)
  static Future<SmsResult> _showNative(
      List<String> recipients, String? body) async {
    try {
      final result = await _channel.invokeMethod('show', {
        'recipients': recipients,
        'body': body ?? '',
      });

      if (result is Map) {
        // Convert Map<Object?, Object?> to Map<String, dynamic>
        final Map<String, dynamic> resultMap =
            Map<String, dynamic>.from(result);
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
    Widget Function(BuildContext, List<String>, String?, Function(SmsResult))? customBuilder,
  ) async {
    try {
      final completer = Completer<SmsResult>();

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          if (customBuilder != null) {
            return customBuilder(
              context,
              recipients,
              body,
              (result) {
                if (!completer.isCompleted) {
                  completer.complete(result);
                }
              },
            );
          }
          
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

  /// Request SMS permission with user dialog (Android only)
  ///
  /// Shows permission dialog and handles user response
  /// Returns detailed information about the permission request result
  static Future<Map<String, dynamic>> requestSmsPermission() async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod('requestSmsPermission');
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
        'message': 'Failed to request permission: $e',
        'platform': Platform.isAndroid ? 'Android' : 'iOS'
      };
    }
  }

  /// Show SMS composer with automatic permission handling
  ///
  /// This is the recommended method for Android as it handles permissions automatically.
  /// For iOS, this behaves the same as `show()` since no permission is required.
  ///
  /// [recipients] - List of phone numbers (required, non-empty)
  /// [body] - Optional pre-filled message body
  /// [context] - Required for Android custom bottom sheet (recommended)
  /// [useCustomBottomSheet] - For Android: use Flutter bottom sheet (true) or native intent (false)
  /// [bottomSheetBuilder] - Custom builder for Android bottom sheet UI
  ///
  /// Returns [SmsResult] with operation details
  /// Throws [ArgumentError] if recipients list is empty
  static Future<SmsResult> showWithPermission({
    required List<String> recipients,
    String? body,
    BuildContext? context,
    bool useCustomBottomSheet = true,
    Widget Function(BuildContext, List<String>, String?, Function(SmsResult))? bottomSheetBuilder,
  }) async {
    // Input validation
    if (recipients.isEmpty) {
      throw ArgumentError('Recipients list cannot be empty');
    }

    // Clean recipients (remove empty strings and trim whitespace)
    final cleanRecipients =
        recipients.map((r) => r.trim()).where((r) => r.isNotEmpty).toList();

    if (cleanRecipients.isEmpty) {
      throw ArgumentError('No valid recipients provided');
    }

    // For iOS, proceed directly as no permission is needed
    if (Platform.isIOS) {
      // ignore: use_build_context_synchronously
      // Safe to use context here as no async operations precede this
      return show(
        recipients: cleanRecipients,
        body: body,
        context: context,
        useCustomBottomSheet: useCustomBottomSheet,
        bottomSheetBuilder: bottomSheetBuilder,
      );
    }

    // For Android, handle permission and SMS sending
    return _handleAndroidPermissionAndShow(
      cleanRecipients,
      body,
      context,
      useCustomBottomSheet,
      bottomSheetBuilder,
    );
  }

  /// Handle Android permission check and SMS composer display
  static Future<SmsResult> _handleAndroidPermissionAndShow(
    List<String> recipients,
    String? body,
    BuildContext? context,
    bool useCustomBottomSheet,
    Widget Function(BuildContext, List<String>, String?, Function(SmsResult))? bottomSheetBuilder,
  ) async {
    // Check and request permission if needed
    final permissionStatus = await checkPermissionStatus();

    if (!permissionStatus['hasPermission']) {
      // Show permission dialog and request permission
      final permissionResult = await requestSmsPermission();

      if (!permissionResult['hasPermission']) {
        // Permission denied, return error result
        return SmsResult(
          presented: false,
          sent: false,
          error: permissionResult['message'],
          platformResult: 'permission_denied',
        );
      }
    }

    // Permission granted, proceed with SMS composer
    if (context != null && useCustomBottomSheet) {
      try {
        // Safe to use context here as permission dialogs are system-level
        // and don't affect Flutter widget tree state
        // ignore: use_build_context_synchronously
        return await _showAndroidBottomSheet(context, recipients, body, bottomSheetBuilder);
      } catch (e) {
        // Fallback to native implementation if context is invalid
        return _showNative(recipients, body);
      }
    } else {
      // Use native implementation when context is not provided or custom bottom sheet is disabled
      return _showNative(recipients, body);
    }
  }

  /// Convenience method: Show SMS with native intent (Android) or native composer (iOS)
  ///
  /// This method bypasses custom bottom sheets and uses the platform's native SMS implementation.
  /// Useful when you want consistent native behavior across platforms.
  static Future<SmsResult> showNative({
    required List<String> recipients,
    String? body,
  }) async {
    // Input validation
    if (recipients.isEmpty) {
      throw ArgumentError('Recipients list cannot be empty');
    }

    final cleanRecipients =
        recipients.map((r) => r.trim()).where((r) => r.isNotEmpty).toList();

    if (cleanRecipients.isEmpty) {
      throw ArgumentError('No valid recipients provided');
    }

    return _showNative(cleanRecipients, body);
  }

  /// Convenience method: Show SMS with custom Android bottom sheet
  ///
  /// This method always uses the custom Flutter bottom sheet on Android and native on iOS.
  /// Automatically handles permissions on Android.
  static Future<SmsResult> showCustom({
    required List<String> recipients,
    required BuildContext context,
    String? body,
    Widget Function(BuildContext, List<String>, String?, Function(SmsResult))? bottomSheetBuilder,
  }) async {
    return showWithPermission(
      recipients: recipients,
      body: body,
      context: context,
      useCustomBottomSheet: true,
      bottomSheetBuilder: bottomSheetBuilder,
    );
  }
}
