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
- **🤖 In-App Android Composer**: Custom bottom sheet that keeps users in your app
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
| **Android** | Custom Flutter bottom sheet + `SmsManager` | In-app composer, no external app switching |

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
  context: context, // Required for Android in-app experience
);

// Handle the result
if (result.sent) {
  print('✅ SMS sent successfully!');
} else if (result.platformResult == 'permission_denied') {
  print('❌ SMS permission denied');
} else {
  print('❌ Failed: ${result.error}');
}

// Alternative: Manual SMS sending (requires permission check)
final manualResult = await SmsComposerSheet.show(
  recipients: ['+1234567890'],
  body: 'Hello from Flutter!',
  context: context,
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

### Multiple Recipients

```dart
final result = await SmsComposerSheet.show(
  recipients: [
    '+1234567890',
    '+0987654321',
    '+1122334455',
  ],
  body: 'Group message from Flutter app!',
  context: context,
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

##### `show({required List<String> recipients, String? body, BuildContext? context})`

Shows the SMS composer interface.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `recipients` | `List<String>` | ✅ | Phone numbers (non-empty list) |
| `body` | `String?` | ❌ | Pre-filled message content |
| `context` | `BuildContext?` | ⚠️ | Required for Android in-app composer |

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

##### `showWithPermission({required List<String> recipients, String? body, BuildContext? context})`

Shows SMS composer with automatic permission handling.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `recipients` | `List<String>` | ✅ | Phone numbers (non-empty list) |
| `body` | `String?` | ❌ | Pre-filled message content |
| `context` | `BuildContext?` | ⚠️ | Required for Android in-app composer |

**Returns:** `Future<SmsResult>`

**Note:** This method automatically checks and requests SMS permission before showing the composer.

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

## 🧪 Testing

### Recommended Testing Setup

| Platform | Environment | SMS Support |
|----------|-------------|-------------|
| **iOS** | Physical device | ✅ Full support |
| **iOS** | Simulator | ❌ Not supported |
| **Android** | Physical device | ✅ Full support |
| **Android** | Emulator with Play Store | ✅ Supported |
| **Android** | Basic emulator | ❌ Limited support |

### Testing Checklist

- [ ] Test on physical devices for both platforms
- [ ] Verify SMS permissions are granted
- [ ] Test with single and multiple recipients
- [ ] Test with short and long messages (160+ characters)
- [ ] Verify error handling for invalid phone numbers
- [ ] Test network connectivity scenarios

## 🛠️ Troubleshooting

### Common Issues

| Issue | Platform | Solution |
|-------|----------|----------|
| "SMS not available" | iOS Simulator | Use physical iOS device |
| "Permission denied" | Android | Grant SMS permission in device settings |
| "No SMS app available" | Android Emulator | Use emulator with Google Play Store |
| External app opens | Android | Ensure `context` parameter is provided |
| Build errors | Both | Run `flutter clean && flutter pub get` |

### Debug Steps

1. **Check SMS capability:**
   ```dart
   final canSend = await SmsComposerSheet.canSendSms();
   ```

2. **Verify permissions (Android):**
   ```dart
   final status = await SmsComposerSheet.checkPermissionStatus();
   ```

3. **Enable debug logging:**
   ```dart
   // Check console output for detailed error messages
   ```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
git clone https://github.com/manukumarsb/sms_composer_sheet.git
cd sms_composer_sheet
flutter pub get
flutter analyze
flutter test
```

### Pull Request Process

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes with tests
4. **Run** `flutter analyze` and `flutter test`
5. **Commit** your changes (`git commit -m 'Add amazing feature'`)
6. **Push** to the branch (`git push origin feature/amazing-feature`)
7. **Open** a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with ❤️ for the Flutter community
- Inspired by iOS Messages app design
- Thanks to all contributors and users

## 📞 Support

- 📖 **Documentation**: [API Documentation](https://pub.dev/documentation/sms_composer_sheet/latest/)
- 🐛 **Issues**: [GitHub Issues](https://github.com/manukumarsb/sms_composer_sheet/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/manukumarsb/sms_composer_sheet/discussions)
- 📧 **Email**: manubalarama@gmail.com

---

<div align="center">

**Made with ❤️ by [Manukumar S B](https://github.com/manukumarsb)**

[⭐ Star this repo](https://github.com/manukumarsb/sms_composer_sheet) • [🐛 Report Bug](https://github.com/manukumarsb/sms_composer_sheet/issues) • [💡 Request Feature](https://github.com/manukumarsb/sms_composer_sheet/issues)

</div>