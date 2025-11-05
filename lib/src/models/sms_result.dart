/// Result model for SMS composer operations
class SmsResult {
  /// Whether the SMS composer was successfully presented
  final bool presented;

  /// Whether the SMS was successfully sent
  final bool sent;

  /// Error message if any occurred
  final String? error;

  /// Platform-specific result code
  final String? platformResult;

  const SmsResult({
    required this.presented,
    required this.sent,
    this.error,
    this.platformResult,
  });

  /// Creates an SmsResult from a map (typically from platform channel)
  factory SmsResult.fromMap(Map<String, dynamic> map) {
    return SmsResult(
      presented: map['presented'] as bool? ?? false,
      sent: map['sent'] as bool? ?? false,
      error: map['error'] as String?,
      platformResult: map['platformResult'] as String?,
    );
  }

  /// Converts the SmsResult to a map
  Map<String, dynamic> toMap() {
    return {
      'presented': presented,
      'sent': sent,
      'error': error,
      'platformResult': platformResult,
    };
  }

  @override
  String toString() {
    return 'SmsResult(presented: $presented, sent: $sent, error: $error, platformResult: $platformResult)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmsResult &&
        other.presented == presented &&
        other.sent == sent &&
        other.error == error &&
        other.platformResult == platformResult;
  }

  @override
  int get hashCode {
    return presented.hashCode ^
        sent.hashCode ^
        error.hashCode ^
        platformResult.hashCode;
  }
}
