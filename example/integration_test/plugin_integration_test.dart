// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sms_composer_sheet/sms_composer_sheet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canSendSms test', (WidgetTester tester) async {
    final bool canSend = await SmsComposerSheet.canSendSms();
    // The result depends on the host platform and capabilities
    // Just assert that the method returns a boolean value
    expect(canSend, isA<bool>());
  });

  testWidgets('platformName test', (WidgetTester tester) async {
    final String platform = SmsComposerSheet.platformName;
    // The platform name should be one of the expected values
    expect(['iOS', 'Android', 'Unsupported'], contains(platform));
  });
}
