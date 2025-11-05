# SMS Composer Sheet Plugin - Developer Documentation

## Overview

The `sms_composer_sheet` plugin provides a unified interface for SMS composition with bottom sheet UI on both iOS and Android platforms. This plugin was developed based on an existing iOS implementation and extended to support Android with native functionality.

## Architecture

### Flutter Interface
- **Main Class**: `SmsComposerSheet` - Static methods for SMS operations
- **Result Model**: `SmsResult` - Structured response with detailed information
- **Method Channel**: `sms_composer_sheet` - Communication bridge with native platforms

### Platform Implementations

#### iOS Implementation
- **Framework**: Uses `MFMessageComposeViewController` from MessageUI framework
- **Presentation**: Native bottom sheet modal presentation
- **Delegate**: Implements `MFMessageComposeViewControllerDelegate` for result handling
- **Result Mapping**: 
  - `sent` → successful send
  - `cancelled` → user cancelled (may include successful sends)
  - `failed` → send failure

#### Android Implementation
- **Method**: Uses SMS Intent with `ACTION_SENDTO`
- **Presentation**: System SMS app with configured intent flags
- **Activity Result**: Tracks user interaction through `onActivityResult`
- **Permissions**: Requires `SEND_SMS` permission in AndroidManifest.xml

## API Reference

### Core Methods

#### `SmsComposerSheet.show()`
```dart
static Future<SmsResult> show({
  required List<String> recipients,
  String? body,
})
```

**Parameters:**
- `recipients`: Non-empty list of phone numbers
- `body`: Optional pre-filled message content

**Returns:** `SmsResult` with operation details

**Throws:** `ArgumentError` if recipients list is empty or contains only invalid entries

#### `SmsComposerSheet.canSendSms()`
```dart
static Future<bool> canSendSms()
```

**Returns:** `true` if SMS functionality is available on the device

#### `SmsComposerSheet.platformName`
```dart
static String get platformName
```

**Returns:** Platform identifier string ("iOS", "Android", "Unsupported")

### Result Model

```dart
class SmsResult {
  final bool presented;     // Whether composer was shown
  final bool sent;          // Whether SMS was sent
  final String? error;      // Error message if any
  final String? platformResult; // Platform-specific result code
}
```

## Platform-Specific Behavior

### iOS Behavior
- **Native UI**: Uses system MFMessageComposeViewController
- **User Experience**: Standard iOS SMS composer with familiar interface
- **Result Accuracy**: Reliable detection of send/cancel/failure states
- **Edge Case**: iOS returns "cancelled" even after successful manual sends

### Android Behavior
- **Intent-Based**: Launches default SMS app via intent
- **User Experience**: Uses device's default SMS application
- **Result Limitations**: Limited feedback about actual SMS sending
- **Permissions**: Requires SMS permission declared in manifest

## Development Commands

### Plugin Development
```bash
# Analyze code quality
flutter analyze

# Run unit tests
flutter test

# Run integration tests (requires device/simulator)
cd example
flutter drive --target=integration_test/plugin_integration_test.dart

# Test on specific platform
flutter run -d ios
flutter run -d android
```

### Code Quality Checks
```bash
# Check Dart formatting
dart format --set-exit-if-changed .

# Check for linting issues
flutter analyze

# Run all tests
flutter test
```

## Integration Guide

### Add to Project
```yaml
dependencies:
  sms_composer_sheet: ^1.0.0
```

### Android Setup
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.SEND_SMS" />
```

### Basic Usage Example
```dart
import 'package:sms_composer_sheet/sms_composer_sheet.dart';

Future<void> sendSMS() async {
  try {
    final result = await SmsComposerSheet.show(
      recipients: ['+1234567890'],
      body: 'Hello from Flutter!',
    );
    
    if (result.presented) {
      if (result.sent) {
        print('SMS sent successfully');
      } else {
        print('SMS composer shown but not sent');
      }
    } else {
      print('Failed to show SMS composer: ${result.error}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

## Testing Strategy

### Unit Tests
- Input validation (empty recipients)
- Platform name verification
- Error handling for edge cases

### Integration Tests
- SMS capability detection
- Platform identification
- End-to-end functionality (requires real device)

### Manual Testing Checklist
- [ ] iOS: Native composer appears as bottom sheet
- [ ] iOS: Send button works and returns appropriate result
- [ ] iOS: Cancel button works and returns cancelled result
- [ ] Android: Default SMS app opens with pre-filled data
- [ ] Android: Back navigation returns to Flutter app
- [ ] Both: Multiple recipients are handled correctly
- [ ] Both: Empty message body is handled gracefully
- [ ] Both: SMS capability detection works on devices without SMS

## Error Handling

### Common Error Scenarios
1. **No Recipients**: Throws `ArgumentError`
2. **Invalid Recipients**: Throws `ArgumentError` after cleaning
3. **SMS Unavailable**: Returns `SmsResult` with `presented: false`
4. **No Activity (Android)**: Returns error in `SmsResult`
5. **Permission Denied**: Platform-specific handling

### Error Response Format
```dart
SmsResult(
  presented: false,
  sent: false,
  error: "Description of what went wrong",
  platformResult: "platform_specific_code"
)
```

## Performance Considerations

- **Memory**: Plugin creates minimal overhead with static methods
- **Threading**: All platform calls are async and non-blocking
- **Resource Cleanup**: iOS implementation properly cleans up delegates
- **Battery**: No background processing or persistent connections

## Security Considerations

- **Permissions**: Android requires explicit SMS permission
- **Data Validation**: All input is validated before platform calls
- **No Storage**: Plugin doesn't store or log SMS content
- **Privacy**: Respects platform privacy settings and user choices

## Troubleshooting

### iOS Issues
- **Simulator**: SMS not available on iOS Simulator
- **Delegate Cleanup**: Ensure proper memory management
- **Result Handling**: Account for iOS "cancelled" quirk

### Android Issues
- **Permissions**: Verify SMS permission in manifest
- **Intent Resolution**: Ensure SMS app is available
- **Activity Results**: Check activity lifecycle management

### Common Solutions
```bash
# Clean build for platform issues
flutter clean
cd ios && rm -rf Podfile.lock && cd ..
flutter pub get
```

## Future Enhancements

### Potential Features
- Attachment support (images, files)
- Template message management
- Delivery status tracking
- Custom UI themes
- Batch SMS sending
- MMS support

### Platform Improvements
- Better Android result detection
- iOS 17+ improvements
- Tablet-specific optimizations
- Accessibility enhancements

## Changelog

### Version 1.0.0 (Initial Release)
- ✅ iOS native SMS composer with MFMessageComposeViewController
- ✅ Android SMS intent integration
- ✅ Unified Flutter interface
- ✅ Comprehensive error handling
- ✅ Unit and integration tests
- ✅ Example app with full functionality
- ✅ Cross-platform SMS capability detection

## Contributing

### Development Setup
1. Clone the repository
2. Run `flutter pub get`
3. Open in IDE with Flutter support
4. Run example app for testing

### Code Standards
- Follow Dart style guide
- Add tests for new features
- Update documentation
- Ensure cross-platform compatibility

### Pull Request Process
1. Create feature branch
2. Implement changes with tests
3. Run full test suite
4. Update documentation
5. Submit PR with detailed description

---

**Note**: This plugin provides a production-ready SMS composer solution based on battle-tested implementations from the blue-vote-volunteer-native project. The design prioritizes reliability, user experience, and cross-platform consistency.