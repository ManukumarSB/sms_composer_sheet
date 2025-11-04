import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sms_composer_sheet_platform_interface.dart';

/// An implementation of [SmsComposerSheetPlatform] that uses method channels.
class MethodChannelSmsComposerSheet extends SmsComposerSheetPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sms_composer_sheet');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
