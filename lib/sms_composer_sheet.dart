
import 'sms_composer_sheet_platform_interface.dart';

class SmsComposerSheet {
  Future<String?> getPlatformVersion() {
    return SmsComposerSheetPlatform.instance.getPlatformVersion();
  }
}
