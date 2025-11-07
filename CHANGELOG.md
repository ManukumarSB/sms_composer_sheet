# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2025-01-07

### Added
- `showWithPermission()` - Recommended method with automatic Android permission handling
- `showNative()` - Always uses platform native SMS implementation  
- `showCustom()` - Custom UI with optional bottom sheet builder
- Enhanced `show()` with `useCustomBottomSheet` and `bottomSheetBuilder` parameters

## [1.0.1] - 2025-11-05

### Fixed
- 🔧 **Pub.dev compliance**: Fixed package description length to meet pub.dev requirements (60-180 characters)
- 🔧 **Documentation URL**: Removed non-existent documentation URL until package is published
- 🔧 **Code formatting**: Applied `dart format` to all Dart files for consistent formatting
- 🔧 **Lint warnings**: Addressed BuildContext async gap warnings with proper ignore comments
- 🔧 **Package validation**: Ensured all pub.dev validation requirements are met

### Improved
- 📦 **Package metadata**: Added topics for better discoverability on pub.dev
- 📝 **Code quality**: Enhanced code formatting and documentation consistency

## [1.0.0] - 2025-11-05

### Added
- 🎉 **Initial release** of SMS Composer Sheet plugin
- 📱 **Cross-platform SMS composer** with unified API for iOS and Android
- 🍎 **iOS native implementation** using `MFMessageComposeViewController`
- 🤖 **Android in-app bottom sheet** composer (when context provided)
- 🤖 **Android fallback** to system SMS app (when context not provided)
- ✅ **Success notifications** with automatic snackbar display
- ❌ **Comprehensive error handling** with detailed error messages
- 📊 **Character counter** with real-time updates and multi-SMS indicators
- 📳 **Haptic feedback** for success and error states
- 🔐 **Automatic permission handling** with system dialog requests (Android)
- 🔐 **Permission status checking** with detailed user guidance
- 🔐 **Manual permission request** with user-friendly dialog prompts
- 📞 **Multiple recipients** support
- 📝 **Pre-filled message** body support
- 🔍 **SMS capability detection** across platforms
- 📏 **Long message support** with automatic splitting (Android)
- 🎨 **Material Design** bottom sheet with iOS-like styling
- ⚡ **Loading states** with progress indicators
- 🛡️ **Input validation** with meaningful error messages

### Features
- `SmsComposerSheet.show()` - Display SMS composer with bottom sheet UI
- `SmsComposerSheet.showWithPermission()` - Display SMS composer with automatic permission handling
- `SmsComposerSheet.canSendSms()` - Check SMS capability on device
- `SmsComposerSheet.checkPermissionStatus()` - Get detailed permission status (Android)
- `SmsComposerSheet.requestSmsPermission()` - Request SMS permission with system dialog (Android)
- `SmsComposerSheet.platformName` - Get current platform name
- `SmsResult` model with detailed operation feedback
- `SmsComposerWidget` - Customizable Flutter SMS composer UI

### Platform Support
- ✅ **iOS 12.0+** - Native MFMessageComposeViewController
- ✅ **Android API 21+** - Custom bottom sheet + SmsManager integration
- ✅ **Flutter 3.3.0+** - Modern Flutter SDK support

### Dependencies
- `flutter: ">=3.3.0"`
- `dart: ">=3.0.0"`

### Documentation
- 📖 Comprehensive README with installation and usage examples
- 🔧 Developer documentation (CLAUDE.md) with architecture details
- 🧪 Example app with complete demonstration
- ✅ Unit tests and integration tests
- 📋 API documentation with detailed method descriptions

---

## Semantic Versioning Guide

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version (X.0.0): Breaking changes that require code updates
- **MINOR** version (0.X.0): New features that are backward compatible  
- **PATCH** version (0.0.X): Bug fixes and improvements that are backward compatible

