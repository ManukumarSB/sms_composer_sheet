# SMS Composer Sheet - API Documentation

## Overview

The SMS Composer Sheet plugin provides a unified, cross-platform API for sending SMS messages through native interfaces. This document provides detailed technical documentation for all public APIs.

## Table of Contents

- [SmsComposerSheet](#smscomposersheet)
- [SmsResult](#smsresult)
- [SmsComposerWidget](#smscomposerwidget)
- [Error Handling](#error-handling)
- [Platform Differences](#platform-differences)
- [Examples](#examples)

## SmsComposerSheet

The main class providing static methods for SMS functionality.

### Methods

#### `show`

```dart
static Future<SmsResult> show({
  required List<String> recipients,
  String? body,
  BuildContext? context,
}) async
```

Displays the SMS composer interface.

**Parameters:**
- `recipients` (`List<String>`, required): List of phone numbers in any valid format
- `body` (`String?`, optional): Pre-filled message content
- `context` (`BuildContext?`, optional): Required for Android in-app composer

**Returns:** `Future<SmsResult>` - Detailed result of the SMS operation

**Throws:**
- `ArgumentError` if recipients list is empty or contains only invalid entries

**Platform Behavior:**
- **iOS**: Shows native `MFMessageComposeViewController`
- **Android (with context)**: Shows custom in-app bottom sheet
- **Android (without context)**: Falls back to system SMS app

**Example:**
```dart
final result = await SmsComposerSheet.show(
  recipients: ['+1 (555) 123-4567', '5551234567'],
  body: 'Hello from Flutter!',
  context: context,
);
```

---

#### `canSendSms`

```dart
static Future<bool> canSendSms() async
```

Checks if the current device supports SMS functionality.

**Returns:** `Future<bool>` - `true` if SMS is supported, `false` otherwise

**Platform Behavior:**
- **iOS**: Checks `MFMessageComposeViewController.canSendText()`
- **Android**: Checks for SMS intents and `SmsManager` availability

**Example:**
```dart
if (await SmsComposerSheet.canSendSms()) {
  // Show SMS button
} else {
  // Hide SMS functionality or show alternatives
}
```

---

#### `checkPermissionStatus`

```dart
static Future<Map<String, dynamic>> checkPermissionStatus() async
```

Gets detailed SMS permission status (Android only).

**Returns:** `Future<Map<String, dynamic>>` with keys:
- `hasPermission` (`bool`): Whether SMS permission is granted
- `message` (`String`): Human-readable status message
- `platform` (`String`): Platform identifier

**Platform Behavior:**
- **iOS**: Always returns `hasPermission: true` (no explicit permission needed)
- **Android**: Checks `SEND_SMS` permission status

**Example:**
```dart
final status = await SmsComposerSheet.checkPermissionStatus();
if (!status['hasPermission']) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('SMS Permission Required'),
      content: Text(status['message']),
      actions: [
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

---

#### `platformName`

```dart
static String get platformName
```

Gets the current platform identifier.

**Returns:** `String` - "iOS", "Android", or "Unsupported"

**Example:**
```dart
final platform = SmsComposerSheet.platformName;
print('Running on: $platform');

// Platform-specific logic
switch (platform) {
  case 'iOS':
    // iOS-specific handling
    break;
  case 'Android':
    // Android-specific handling
    break;
  default:
    // Unsupported platform
    break;
}
```

## SmsResult

Represents the result of an SMS operation.

### Properties

```dart
class SmsResult {
  final bool presented;        // Whether composer was shown
  final bool sent;             // Whether SMS was sent
  final String? error;         // Error message if any
  final String? platformResult; // Platform-specific result code
}
```

#### `presented`

**Type:** `bool`  
**Description:** Indicates whether the SMS composer interface was successfully displayed to the user.

- `true`: Composer was shown (success or user interaction)
- `false`: Failed to show composer (permission issues, no SMS support, etc.)

#### `sent`

**Type:** `bool`  
**Description:** Indicates whether the SMS was actually sent.

- `true`: SMS was successfully sent
- `false`: SMS was not sent (user cancelled, send failed, etc.)

**Note:** On iOS, this might be `false` even if the user manually sent the message, due to platform limitations.

#### `error`

**Type:** `String?`  
**Description:** Human-readable error message if something went wrong.

**Common Error Messages:**
- `"SMS permission not granted"` (Android)
- `"No SMS app available"` (Android emulator)
- `"Recipients list cannot be empty"` (Input validation)
- `"Device cannot send SMS"` (iOS simulator)

#### `platformResult`

**Type:** `String?`  
**Description:** Platform-specific result code for detailed analysis.

**iOS Result Codes:**
- `"sent"`: Successfully sent
- `"cancelled"`: User cancelled
- `"failed"`: Send operation failed

**Android Result Codes:**
- `"sent"`: Successfully sent
- `"cancelled"`: User cancelled
- `"permission_denied"`: SMS permission not granted
- `"no_sms_app"`: No SMS application available

### Methods

#### `fromMap`

```dart
factory SmsResult.fromMap(Map<String, dynamic> map)
```

Creates an `SmsResult` from a map (typically from platform channels).

#### `toMap`

```dart
Map<String, dynamic> toMap()
```

Converts the `SmsResult` to a map representation.

## SmsComposerWidget

Custom Flutter widget for the Android in-app SMS composer.

### Constructor

```dart
SmsComposerWidget({
  Key? key,
  required List<String> recipients,
  String? initialBody,
  required Function(SmsResult) onResult,
})
```

**Parameters:**
- `recipients`: Initial list of phone numbers
- `initialBody`: Pre-filled message content
- `onResult`: Callback function to handle the result

**Note:** This widget is typically used internally by the plugin and not directly by developers.

## Error Handling

### Exception Types

The plugin uses standard Dart exceptions:

#### `ArgumentError`

Thrown for invalid input parameters:

```dart
try {
  await SmsComposerSheet.show(recipients: []); // Empty list
} on ArgumentError catch (e) {
  print('Invalid input: $e');
}
```

#### `PlatformException`

Thrown for platform-specific errors (wrapped in `SmsResult.error`):

```dart
// Platform exceptions are caught and returned in SmsResult
final result = await SmsComposerSheet.show(recipients: ['+1234567890']);
if (result.error != null) {
  print('Platform error: ${result.error}');
}
```

### Error Handling Best Practices

```dart
Future<void> sendSMS() async {
  try {
    // 1. Check capability first
    if (!await SmsComposerSheet.canSendSms()) {
      _showError('SMS not supported on this device');
      return;
    }

    // 2. Check permissions (Android)
    final permissionStatus = await SmsComposerSheet.checkPermissionStatus();
    if (!permissionStatus['hasPermission']) {
      _showPermissionDialog(permissionStatus['message']);
      return;
    }

    // 3. Attempt to send
    final result = await SmsComposerSheet.show(
      recipients: phoneNumbers,
      body: messageText,
      context: context,
    );

    // 4. Handle result
    if (result.presented) {
      if (result.sent) {
        _showSuccess('SMS sent successfully!');
      } else {
        _showWarning('SMS composer shown but message not sent');
      }
    } else {
      _showError('Failed to show SMS composer: ${result.error}');
    }

  } on ArgumentError catch (e) {
    _showError('Invalid input: $e');
  } catch (e) {
    _showError('Unexpected error: $e');
  }
}
```

## Platform Differences

### iOS Specifics

#### Capabilities
- Uses native `MFMessageComposeViewController`
- Requires physical device (not supported in Simulator)
- No explicit permission required
- Cannot customize UI appearance

#### Behavior
- Shows system bottom sheet
- User can manually modify recipients and message
- Returns accurate send/cancel/fail status
- Automatically handles long messages

#### Limitations
- SMS Simulator not supported
- Cannot detect if user manually modified message before sending
- May return "cancelled" even after successful manual send

### Android Specifics

#### Capabilities
- Two modes: in-app composer (with context) or external app (without context)
- Requires `SEND_SMS` permission in manifest
- Supports UI customization in in-app mode
- Works on emulators with SMS apps

#### Behavior
- **In-app mode**: Custom Flutter bottom sheet with direct SMS sending
- **External mode**: Launches system SMS app
- Provides character counting and multi-SMS indicators
- Handles permissions intelligently

#### Limitations
- Permission must be granted by user
- Some emulators don't have SMS apps
- Battery optimization may affect SMS sending

## Examples

### Basic Usage

```dart
// Simple SMS with minimal configuration
final result = await SmsComposerSheet.show(
  recipients: ['+1234567890'],
  body: 'Hello!',
  context: context,
);

print('Sent: ${result.sent}');
```

### Advanced Usage with Error Handling

```dart
Future<bool> sendSMSWithFullHandling({
  required List<String> phoneNumbers,
  required String message,
  required BuildContext context,
}) async {
  try {
    // Validate inputs
    if (phoneNumbers.isEmpty) {
      throw ArgumentError('At least one phone number is required');
    }

    // Check capability
    if (!await SmsComposerSheet.canSendSms()) {
      _showError('SMS not supported on this device');
      return false;
    }

    // Check permissions
    final permissionStatus = await SmsComposerSheet.checkPermissionStatus();
    if (!permissionStatus['hasPermission']) {
      final granted = await _requestSMSPermission();
      if (!granted) return false;
    }

    // Show loading indicator
    _setLoading(true);

    // Attempt to send SMS
    final result = await SmsComposerSheet.show(
      recipients: phoneNumbers,
      body: message,
      context: context,
    );

    // Handle results
    if (result.sent) {
      _showSuccessMessage('SMS sent to ${phoneNumbers.length} recipients');
      return true;
    } else if (result.presented) {
      _showInfoMessage('SMS composer was shown but message not sent');
      return false;
    } else {
      _showErrorMessage('Failed to show SMS composer: ${result.error}');
      return false;
    }

  } on ArgumentError catch (e) {
    _showErrorMessage('Invalid input: $e');
    return false;
  } catch (e) {
    _showErrorMessage('Unexpected error: $e');
    return false;
  } finally {
    _setLoading(false);
  }
}
```

### Platform-Specific Handling

```dart
Future<void> handlePlatformSpecificBehavior() async {
  final platform = SmsComposerSheet.platformName;
  
  switch (platform) {
    case 'iOS':
      // iOS-specific behavior
      final result = await SmsComposerSheet.show(
        recipients: phoneNumbers,
        body: message,
        // No context needed for iOS
      );
      
      // iOS may return cancelled even after successful send
      if (result.presented && !result.sent && result.platformResult == 'cancelled') {
        _showInfoMessage('SMS composer was shown. Message may have been sent manually.');
      }
      break;

    case 'Android':
      // Android-specific behavior
      
      // Check permissions first
      final permissionStatus = await SmsComposerSheet.checkPermissionStatus();
      if (!permissionStatus['hasPermission']) {
        await _showPermissionDialog();
        return;
      }

      // Use in-app composer
      final result = await SmsComposerSheet.show(
        recipients: phoneNumbers,
        body: message,
        context: context, // Required for in-app experience
      );

      // Android provides more accurate send status
      if (result.sent) {
        _showSuccessMessage('SMS sent successfully!');
      }
      break;

    default:
      _showErrorMessage('SMS not supported on this platform');
      break;
  }
}
```

---

For more examples and usage patterns, see the [example app](example/) included with the plugin.