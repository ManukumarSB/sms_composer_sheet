import 'package:flutter_test/flutter_test.dart';
import 'package:sms_composer_sheet/sms_composer_sheet.dart';
import 'package:sms_composer_sheet/sms_composer_sheet_platform_interface.dart';
import 'package:sms_composer_sheet/sms_composer_sheet_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmsComposerSheetPlatform
    with MockPlatformInterfaceMixin
    implements SmsComposerSheetPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SmsComposerSheetPlatform initialPlatform = SmsComposerSheetPlatform.instance;

  test('$MethodChannelSmsComposerSheet is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmsComposerSheet>());
  });

  test('getPlatformVersion', () async {
    SmsComposerSheet smsComposerSheetPlugin = SmsComposerSheet();
    MockSmsComposerSheetPlatform fakePlatform = MockSmsComposerSheetPlatform();
    SmsComposerSheetPlatform.instance = fakePlatform;

    expect(await smsComposerSheetPlugin.getPlatformVersion(), '42');
  });
}
