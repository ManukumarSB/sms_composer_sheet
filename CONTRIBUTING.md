# Contributing to SMS Composer Sheet

First off, thank you for considering contributing to SMS Composer Sheet! 🎉

The following is a set of guidelines for contributing to this Flutter plugin. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Versioning Guidelines](#versioning-guidelines)
- [Testing Guidelines](#testing-guidelines)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [manukumarsb@example.com](mailto:manukumarsb@example.com).

### Our Pledge

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members

## How Can I Contribute?

### Reporting Bugs 🐛

Before creating bug reports, please check the [existing issues](https://github.com/manukumarsb/sms_composer_sheet/issues) as you might find that one has already been created.

When you are creating a bug report, please include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples to demonstrate the steps**
- **Include logs and error messages**
- **Specify the platform** (iOS/Android version, Flutter version, etc.)

#### Bug Report Template

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**
 - Platform: [e.g. iOS 17.0, Android 13]
 - Flutter version: [e.g. 3.16.0]
 - Plugin version: [e.g. 1.0.0]
 - Device: [e.g. iPhone 15 Pro, Pixel 7]

**Additional context**
Add any other context about the problem here.
```

### Suggesting Enhancements 💡

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the feature**
- **Describe the current behavior and explain the desired behavior**
- **Explain why this enhancement would be useful**

### Your First Code Contribution

Unsure where to begin contributing? You can start by looking through these `beginner` and `help-wanted` issues:

- **Beginner issues** - issues which should only require a few lines of code
- **Help wanted issues** - issues which should be a bit more involved

## Development Setup

### Prerequisites

- Flutter 3.3.0 or higher
- Dart 3.0.0 or higher
- Xcode (for iOS development)
- Android Studio/IntelliJ (for Android development)

### Setup Instructions

1. **Fork and clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/sms_composer_sheet.git
   cd sms_composer_sheet
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run analysis:**
   ```bash
   flutter analyze
   ```

4. **Run tests:**
   ```bash
   flutter test
   ```

5. **Run the example app:**
   ```bash
   cd example
   flutter run
   ```

### Project Structure

```
sms_composer_sheet/
├── lib/
│   ├── src/
│   │   ├── models/          # Data models
│   │   ├── widgets/         # UI components
│   │   └── sms_composer_sheet.dart  # Main plugin class
│   └── sms_composer_sheet.dart      # Public API exports
├── ios/                     # iOS native implementation
├── android/                 # Android native implementation
├── example/                 # Example application
├── test/                    # Unit tests
└── CHANGELOG.md            # Version history
```

## Pull Request Process

### Before Submitting

1. **Search existing PRs** to avoid duplicates
2. **Create an issue** first for major changes
3. **Follow coding standards** described below
4. **Add tests** for new functionality
5. **Update documentation** as needed

### Submission Steps

1. **Create a branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our coding standards

3. **Add tests** for new functionality:
   ```bash
   flutter test
   ```

4. **Run analysis** and fix any issues:
   ```bash
   flutter analyze
   ```

5. **Update CHANGELOG.md** following our [versioning guidelines](#versioning-guidelines)

6. **Commit your changes** with a clear message:
   ```bash
   git commit -m "Add feature: your feature description"
   ```

7. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

8. **Create a Pull Request** with:
   - Clear title and description
   - Reference to related issues
   - Screenshots/GIFs for UI changes
   - Testing instructions

### PR Review Process

- All PRs require at least one review
- CI checks must pass
- Documentation must be updated
- CHANGELOG.md must be updated
- Breaking changes require major version bump

## Coding Standards

### Dart Code Style

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// ✅ Good
class SmsComposerSheet {
  static Future<SmsResult> show({
    required List<String> recipients,
    String? body,
  }) async {
    // Implementation
  }
}

// ❌ Bad
class smsComposerSheet {
  static Future<SmsResult> Show(List<String> recipients, String body) async {
    // Implementation
  }
}
```

### Documentation

- All public APIs must have documentation comments
- Use `///` for documentation comments
- Include examples in documentation when helpful

```dart
/// Shows the SMS composer interface.
/// 
/// [recipients] - List of phone numbers (required, non-empty)
/// [body] - Optional pre-filled message content
/// 
/// Returns [SmsResult] with operation details.
/// 
/// Example:
/// ```dart
/// final result = await SmsComposerSheet.show(
///   recipients: ['+1234567890'],
///   body: 'Hello!',
/// );
/// ```
static Future<SmsResult> show({
  required List<String> recipients,
  String? body,
}) async {
  // Implementation
}
```

### Platform-Specific Code

#### iOS (Swift)
- Follow Swift naming conventions
- Use proper error handling
- Document public methods

#### Android (Kotlin)
- Follow Kotlin coding conventions
- Use proper null safety
- Handle permissions appropriately

## Versioning Guidelines

This project follows [Semantic Versioning](https://semver.org/):

### Version Format: MAJOR.MINOR.PATCH

- **MAJOR** (X.0.0): Breaking changes that require code updates
  ```yaml
  # Example: Changing method signatures
  # Before (1.x.x)
  SmsComposerSheet.show(recipients, body)
  # After (2.0.0)
  SmsComposerSheet.show({required recipients, body, context})
  ```

- **MINOR** (0.X.0): New features that are backward compatible
  ```yaml
  # Example: Adding new methods
  SmsComposerSheet.checkPermissionStatus() # New in 1.1.0
  ```

- **PATCH** (0.0.X): Bug fixes and improvements
  ```yaml
  # Example: Fixing character counting bug
  # No API changes, just internal fixes
  ```

### CHANGELOG.md Updates

When making changes, update `CHANGELOG.md`:

```markdown
## [1.1.0] - 2025-11-06

### Added
- New `checkPermissionStatus()` method for Android permission checking
- Support for custom SMS composer themes

### Fixed
- Character counter now correctly handles emoji characters
- Improved error handling for network timeouts

### Changed
- Updated minimum Flutter version to 3.4.0

### Deprecated
- `oldMethod()` is deprecated, use `newMethod()` instead

### Removed
- Removed support for Flutter 2.x (breaking change in 2.0.0)
```

## Testing Guidelines

### Unit Tests

Write unit tests for all new functionality:

```dart
// test/sms_composer_sheet_test.dart
void main() {
  group('SmsComposerSheet', () {
    test('should throw ArgumentError for empty recipients', () {
      expect(
        () => SmsComposerSheet.show(recipients: []),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
```

### Integration Tests

Add integration tests for platform-specific functionality:

```dart
// example/integration_test/plugin_integration_test.dart
void main() {
  testWidgets('SMS capability check', (WidgetTester tester) async {
    final canSend = await SmsComposerSheet.canSendSms();
    expect(canSend, isA<bool>());
  });
}
```

### Testing Checklist

Before submitting a PR, ensure:

- [ ] Unit tests pass: `flutter test`
- [ ] Integration tests pass on real devices
- [ ] Code analysis passes: `flutter analyze`
- [ ] Example app builds and runs
- [ ] Both iOS and Android platforms work
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated

## Recognition

Contributors who make significant contributions will be:

- Added to the CONTRIBUTORS.md file
- Mentioned in release notes
- Given credit in the README.md

## Questions?

Don't hesitate to ask questions! You can:

- Create an issue for discussion
- Start a GitHub Discussion
- Reach out via email: manukumarsb@example.com

Thank you for contributing! 🚀