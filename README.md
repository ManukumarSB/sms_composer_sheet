# SMS Composer Sheet

[![pub package](https://img.shields.io/pub/v/sms_composer_sheet.svg)](https://pub.dev/packages/sms_composer_sheet)
[![GitHub](https://img.shields.io/github/license/manukumarsb/sms_composer_sheet)](https://github.com/manukumarsb/sms_composer_sheet/blob/main/LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-lightgrey)](https://pub.dev/packages/sms_composer_sheet)
[![Flutter](https://img.shields.io/badge/Flutter-3.3.0%2B-blue)](https://flutter.dev/)

A Flutter plugin that provides **native SMS composer functionality** with beautiful bottom sheet UI for both iOS and Android platforms. Send SMS messages directly from your Flutter app with a seamless, cross-platform experience.

## ✨ Features

### 🎯 Core Features
- **📱 Cross-Platform**: Unified API that works seamlessly on iOS and Android
- **🍎 Native iOS Composer**: Uses `MFMessageComposeViewController` for authentic iOS experience  
- **🤖 Flexible Android Options**: Custom bottom sheet or native intent - your choice
- **✅ Success Notifications**: Automatic feedback with haptic responses
- **📊 Smart Character Counter**: Real-time count with multi-SMS indicators
- **🔐 Permission Handling**: Intelligent permission management with user guidance

### 🚀 Advanced Features
- **📞 Multiple Recipients**: Send to multiple phone numbers simultaneously
- **📝 Pre-filled Messages**: Optional message body with full customization
- **📏 Long Message Support**: Automatic splitting for messages over 160 characters
- **🎨 Beautiful UI**: Material Design with iOS-like polish
- **⚡ Loading States**: Smooth animations and progress indicators
- **🛡️ Error Handling**: Comprehensive error management with helpful messages

### 🏗️ Technical Features
- **🔍 SMS Capability Detection**: Check device SMS support before attempting to send
- **📳 Haptic Feedback**: Tactile responses for better user experience
- **🌐 Wide Compatibility**: iOS 12.0+ and Android API 21+
- **⚙️ Zero Configuration**: Works out of the box with minimal setup

## 📱 Platform Behavior

| Platform | Implementation | User Experience |
|----------|---------------|------------------|
| **iOS** | Native `MFMessageComposeViewController` | System bottom sheet, authentic iOS feel |
| **Android** | Custom bottom sheet (default) or native intent | Flexible: stay in-app or use system SMS app |

## 🚀 Quick Start

### 1. Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sms_composer_sheet: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### 2. Platform Setup

#### iOS Setup
No additional setup required! The plugin uses the built-in MessageUI framework.

#### Android Setup
Add SMS permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SEND_SMS" />
```

### 3. Basic Usage

```dart
import 'package:sms_composer_sheet/sms_composer_sheet.dart';

// Recommended: Use automatic permission handling
final result = await SmsComposerSheet.showWithPermission(
  recipients: ['+1234567890'],
  body: 'Hello from Flutter!',
  context: context, // Required for Android custom UI
);

// Handle the result
if (result.sent) {
  print('✅ SMS sent successfully!');
} else if (result.platformResult == 'permission_denied') {
  print('❌ SMS permission denied');
} else {
  print('❌ Failed: ${result.error}');
}

// Alternative: Use native SMS app (Android) or composer (iOS)
final nativeResult = await SmsComposerSheet.showNative(
  recipients: ['+1234567890'],
  body: 'Hello from Flutter!',
);

// Custom UI for Android with your own design
final customResult = await SmsComposerSheet.showCustom(
  recipients: ['+1234567890'],
  context: context,
  body: 'Hello!',
  bottomSheetBuilder: (context, recipients, body, onResult) {
    // Your custom bottom sheet UI here
    return YourCustomSmsComposer();
  },
);
```

## 📖 Complete Usage Guide

### Check SMS Capability

```dart
// Check if device can send SMS
final canSend = await SmsComposerSheet.canSendSms();
if (!canSend) {
  // Show alternative contact methods
  _showAlternativeOptions();
  return;
}
```

### Multiple Recipients & Platform Options

```dart
// Standard approach with custom Android UI
final result = await SmsComposerSheet.showWithPermission(
  recipients: [
    '+1234567890',
    '+0987654321',
    '+1122334455',
  ],
  body: 'Group message from Flutter app!',
  context: context,
);

// Native approach - uses system SMS app on Android
final nativeResult = await SmsComposerSheet.showNative(
  recipients: ['+1234567890'],
  body: 'Hello from Flutter!',
);

// Custom UI approach - fully customizable Android bottom sheet
final customResult = await SmsComposerSheet.showCustom(
  recipients: ['+1234567890'],
  context: context,
  body: 'Hello!',
  bottomSheetBuilder: (context, recipients, body, onResult) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: YourCustomSmsComposer(
        recipients: recipients,
        initialMessage: body,
        onSend: () {
          // Handle send action
          onResult(SmsResult(presented: true, sent: true));
        },
        onCancel: () {
          onResult(SmsResult(presented: true, sent: false));
        },
      ),
    );
  },
);
```

### Permission Handling (Android)

#### Check Permission Status
```dart
final permissionStatus = await SmsComposerSheet.checkPermissionStatus();
if (!permissionStatus['hasPermission']) {
  // Permission not granted
  print('Status: ${permissionStatus['message']}');
}
```

#### Request Permission with Dialog
```dart
final permissionResult = await SmsComposerSheet.requestSmsPermission();
if (permissionResult['hasPermission']) {
  // Permission granted - proceed with SMS
  print('Permission granted!');
} else {
  // Permission denied - show guidance
  _showPermissionGuidance(permissionResult['message']);
}
```

#### Automatic Permission Handling
```dart
// This method automatically handles permission requests
final result = await SmsComposerSheet.showWithPermission(
  recipients: ['+1234567890'],
  body: 'Hello from Flutter!',
  context: context,
);

if (result.sent) {
  print('✅ SMS sent successfully!');
} else if (result.platformResult == 'permission_denied') {
  print('❌ SMS permission denied');
} else {
  print('❌ Failed: ${result.error}');
}
```

### Advanced Error Handling

```dart
try {
  final result = await SmsComposerSheet.show(
    recipients: phoneNumbers,
    body: messageText,
    context: context,
  );
  
  // Detailed result handling
  if (result.presented) {
    if (result.sent) {
      _showSuccess('SMS sent to ${phoneNumbers.length} recipients');
    } else {
      _showWarning('SMS composer shown but not sent');
    }
  } else {
    _showError('Failed to show SMS composer: ${result.error}');
  }
  
} on ArgumentError catch (e) {
  _showError('Invalid input: $e');
} catch (e) {
  _showError('Unexpected error: $e');
}
```

### Platform-Specific Handling

```dart
// Check current platform
final platform = SmsComposerSheet.platformName;
print('Running on: $platform'); // "iOS", "Android", or "Unsupported"

// Conditional behavior based on platform
if (platform == 'iOS') {
  // iOS-specific logic
} else if (platform == 'Android') {
  // Android-specific logic
}
```

## 🎯 API Reference

### SmsComposerSheet

#### Methods

##### `show({required List<String> recipients, String? body, BuildContext? context, bool useCustomBottomSheet, Widget Function()? bottomSheetBuilder})`

Shows the SMS composer interface with customization options.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `recipients` | `List<String>` | ✅ | Phone numbers (non-empty list) |
| `body` | `String?` | ❌ | Pre-filled message content |
| `context` | `BuildContext?` | ⚠️ | Required for Android custom UI |
| `useCustomBottomSheet` | `bool` | ❌ | Use Flutter UI (true) or native (false). Default: true |
| `bottomSheetBuilder` | `Widget Function()?` | ❌ | Custom Android bottom sheet builder |

**Returns:** `Future<SmsResult>`

**Throws:** `ArgumentError` if recipients list is empty

##### `canSendSms()`

Checks if the device supports SMS functionality.

**Returns:** `Future<bool>`

##### `checkPermissionStatus()`

Gets detailed SMS permission status (Android only).

**Returns:** `Future<Map<String, dynamic>>`

```dart
{
  'hasPermission': bool,
  'message': String,
  'platform': String
}
```

##### `requestSmsPermission()`

Requests SMS permission with system dialog (Android only).

**Returns:** `Future<Map<String, dynamic>>`

```dart
{
  'hasPermission': bool,
  'message': String,
  'platform': String
}
```

##### `showWithPermission({required List<String> recipients, String? body, BuildContext? context, bool useCustomBottomSheet, Widget Function()? bottomSheetBuilder})`

Shows SMS composer with automatic permission handling. **Recommended method for Android.**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `recipients` | `List<String>` | ✅ | Phone numbers (non-empty list) |
| `body` | `String?` | ❌ | Pre-filled message content |
| `context` | `BuildContext?` | ⚠️ | Required for Android custom UI |
| `useCustomBottomSheet` | `bool` | ❌ | Use Flutter UI (true) or native (false). Default: true |
| `bottomSheetBuilder` | `Widget Function()?` | ❌ | Custom Android bottom sheet builder |

**Returns:** `Future<SmsResult>`

**Note:** This method automatically checks and requests SMS permission before showing the composer.

##### `showNative({required List<String> recipients, String? body})`

Shows native SMS implementation only. Uses system SMS app on Android and MFMessageComposeViewController on iOS.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `recipients` | `List<String>` | ✅ | Phone numbers (non-empty list) |
| `body` | `String?` | ❌ | Pre-filled message content |

**Returns:** `Future<SmsResult>`

##### `showCustom({required List<String> recipients, required BuildContext context, String? body, Widget Function()? bottomSheetBuilder})`

Shows custom Android bottom sheet (or native iOS composer). Always uses custom UI on Android.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `recipients` | `List<String>` | ✅ | Phone numbers (non-empty list) |
| `context` | `BuildContext` | ✅ | Build context for bottom sheet |
| `body` | `String?` | ❌ | Pre-filled message content |
| `bottomSheetBuilder` | `Widget Function()?` | ❌ | Custom bottom sheet builder |

**Returns:** `Future<SmsResult>`

##### `platformName`

Gets the current platform identifier.

**Returns:** `String` - "iOS", "Android", or "Unsupported"

### SmsResult

Result object returned by the `show()` method.

| Property | Type | Description |
|----------|------|-------------|
| `presented` | `bool` | Whether the SMS composer was successfully shown |
| `sent` | `bool` | Whether the SMS was sent |
| `error` | `String?` | Error message if any occurred |
| `platformResult` | `String?` | Platform-specific result code |

#### Result Codes

| Platform | Code | Meaning |
|----------|------|---------|
| iOS | `sent` | Successfully sent |
| iOS | `cancelled` | User cancelled |
| iOS | `failed` | Send failed |
| Android | `sent` | Successfully sent |
| Android | `cancelled` | User cancelled |
| Android | `permission_denied` | SMS permission not granted |

## 📱 Example App

The plugin includes a comprehensive example app demonstrating all features:

```bash
git clone https://github.com/manukumarsb/sms_composer_sheet.git
cd sms_composer_sheet/example
flutter run
```

**Example app features:**
- 📱 Platform information display
- 🔍 SMS capability detection
- 📝 Interactive form with validation
- 🎨 Three SMS sending methods:
  - **With Permission** (recommended for Android)
  - **Native SMS** (system SMS app)
  - **Custom UI** (demonstrates custom bottom sheet design)
- 📊 Real-time character counting
- 📋 Detailed result logging
- 🎨 Beautiful Material Design UI

## ⚠️ Platform Limitations

### iOS
- **Simulator**: SMS not available on iOS Simulator (hardware only)
- **Permissions**: No explicit permission required
- **UI**: Uses system native composer (cannot be customized)

### Android
- **Emulators**: Basic emulators may not have SMS apps installed
- **Permissions**: Requires `SEND_SMS` permission in manifest
- **Battery**: Some devices may have SMS restrictions for battery optimization



## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ for the Flutter community
- Inspired by iOS Messages app design
- Thanks to all contributors and users



