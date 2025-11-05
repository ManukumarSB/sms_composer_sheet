import 'package:flutter_test/flutter_test.dart';
import 'package:sms_composer_sheet/sms_composer_sheet.dart';

void main() {
  group('SmsComposerSheet', () {
    test('platformName returns correct platform', () {
      expect(SmsComposerSheet.platformName, isA<String>());
      expect(SmsComposerSheet.platformName.isNotEmpty, true);
    });

    test('show throws ArgumentError for empty recipients', () async {
      expect(
        () => SmsComposerSheet.show(recipients: []),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('show throws ArgumentError for empty recipients after cleaning', () async {
      expect(
        () => SmsComposerSheet.show(recipients: ['', '  ', '\t']),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}