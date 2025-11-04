import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sms_composer_sheet_method_channel.dart';

abstract class SmsComposerSheetPlatform extends PlatformInterface {
  /// Constructs a SmsComposerSheetPlatform.
  SmsComposerSheetPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmsComposerSheetPlatform _instance = MethodChannelSmsComposerSheet();

  /// The default instance of [SmsComposerSheetPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmsComposerSheet].
  static SmsComposerSheetPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmsComposerSheetPlatform] when
  /// they register themselves.
  static set instance(SmsComposerSheetPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
