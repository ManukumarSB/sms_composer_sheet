# SMS Composer Sheet

A Flutter plugin that provides SMS composer with bottom sheet UI for iOS and Android. This plugin offers a unified interface for sending SMS messages with native platform integration.

## Features

- ✅ **Native SMS Composer**: Uses platform-native SMS interfaces
- ✅ **Bottom Sheet UI**: Elegant bottom sheet presentation on iOS
- ✅ **Cross-Platform**: Works on both iOS and Android
- ✅ **Error Handling**: Comprehensive error handling and result feedback
- ✅ **SMS Capability Detection**: Check if device can send SMS
- ✅ **Multiple Recipients**: Support for multiple phone numbers
- ✅ **Pre-filled Messages**: Optional message body pre-filling
- ✅ **Success Notifications**: Automatic snackbar notifications for send status
- ✅ **Character Counter**: Real-time character count with multi-SMS indicators
- ✅ **Haptic Feedback**: Tactile feedback for success and error states

## Screenshots

| iOS Native Composer | Android SMS Intent |
|---------------------|-------------------|
| MFMessageComposeViewController | Default SMS App |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  sms_composer_sheet: ^1.0.0
```

Run `flutter pub get` to install.

## Platform Setup

### Android

Add SMS permission to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SEND_SMS" />
```

### iOS

No additional setup required. The plugin uses the built-in MessageUI framework.

## Usage

### Basic Usage

```dart
import 'package:sms_composer_sheet/sms_composer_sheet.dart';

// Send SMS with in-app composer (Android) or native composer (iOS)
final result = await SmsComposerSheet.show(
  recipients: ['+1234567890'],
  body: 'Hello from Flutter!',
  context: context, // Required for Android in-app composer
);

if (result.presented) {
  if (result.sent) {
    print('SMS sent successfully!');
  } else {
    print('SMS composer was shown but not sent');
  }
} else {
  print('Failed to show SMS composer: ${result.error}');
}
```

### Check SMS Capability

```dart
final canSend = await SmsComposerSheet.canSendSms();
if (canSend) {
  // Show SMS button
} else {
  // Hide SMS functionality
}
```

### Multiple Recipients

```dart
final result = await SmsComposerSheet.show(
  recipients: ['+1234567890', '+0987654321'],
  body: 'Hello everyone!',
);
```

### Error Handling

```dart
try {
  final result = await SmsComposerSheet.show(
    recipients: ['+1234567890'],
    body: 'Hello!',
  );
  
  // Handle result
  print('Presented: ${result.presented}');
  print('Sent: ${result.sent}');
  print('Platform Result: ${result.platformResult}');
  if (result.error != null) {
    print('Error: ${result.error}');
  }
} catch (e) {
  print('Exception: $e');
}
```

## API Reference

### SmsComposerSheet

#### Methods

##### `show({required List<String> recipients, String? body})`

Shows the SMS composer with the specified recipients and optional message body.

**Parameters:**
- `recipients` (required): List of phone numbers
- `body` (optional): Pre-filled message content

**Returns:** `Future<SmsResult>`

**Throws:** `ArgumentError` if recipients list is empty

##### `canSendSms()`

Checks if the device can send SMS messages.

**Returns:** `Future<bool>`

##### `platformName`

Gets the current platform name.

**Returns:** `String` ("iOS", "Android", or "Unsupported")

### SmsResult

Result object returned by the `show()` method.

**Properties:**
- `presented` (bool): Whether the SMS composer was successfully shown
- `sent` (bool): Whether the SMS was sent
- `error` (String?): Error message if any occurred
- `platformResult` (String?): Platform-specific result code

## Platform Behavior

### iOS
- Uses native `MFMessageComposeViewController`
- Presents as a bottom sheet modal
- Provides accurate send/cancel/failure feedback
- Works on physical devices (not iOS Simulator)

### Android
- **With Context**: Shows custom in-app bottom sheet SMS composer
- **Without Context**: Falls back to SMS intent (external app)
- Direct SMS sending using Android SmsManager
- Supports long messages (automatically splits)
- Requires SMS permission in manifest

## Example App

Run the example app to see the plugin in action:

```bash
cd example
flutter run
```

The example app includes:
- SMS capability detection
- Form for entering phone numbers and messages
- Result display with detailed feedback
- Error handling demonstration

## Limitations

- **iOS Simulator**: SMS not available on iOS Simulator
- **Android Emulators**: Most Android emulators don't have SMS apps installed by default
- **Android Feedback**: Limited delivery status information on Android
- **Permissions**: Requires appropriate SMS permissions on Android

## Testing

- **iOS**: Test on physical devices only (not iOS Simulator)
- **Android**: Test on physical devices or emulators with Google Play Services/SMS apps installed
- **Emulator Setup**: For Android emulators, install Google Play Store to get SMS apps

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## Support

For detailed implementation documentation, see [CLAUDE.md](CLAUDE.md).

For issues and feature requests, please use the GitHub issue tracker.