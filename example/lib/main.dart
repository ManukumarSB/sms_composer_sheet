import 'package:flutter/material.dart';
import 'package:sms_composer_sheet/sms_composer_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMS Composer Sheet Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const SmsComposerDemo(),
    );
  }
}

class SmsComposerDemo extends StatefulWidget {
  const SmsComposerDemo({super.key});

  @override
  State<SmsComposerDemo> createState() => _SmsComposerDemoState();
}

class _SmsComposerDemoState extends State<SmsComposerDemo> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _canSendSms = false;
  String _lastResult = '';

  @override
  void initState() {
    super.initState();
    _checkSmsCapability();
    _setDefaultValues();
  }

  void _setDefaultValues() {
    _phoneController.text = '+1234567890';
    _messageController.text = 'Hello from SMS Composer Sheet plugin!';
  }

  Future<void> _checkSmsCapability() async {
    final canSend = await SmsComposerSheet.canSendSms();
    setState(() {
      _canSendSms = canSend;
    });
  }

  Future<void> _sendSms() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter a phone number');
      return;
    }

    try {
      // Use showWithPermission for better Android experience
      final result = await SmsComposerSheet.showWithPermission(
        recipients: [_phoneController.text.trim()],
        body: _messageController.text,
        context: context,
      );

      setState(() {
        _lastResult = result.toString();
      });

      if (result.presented) {
        if (result.sent) {
          _showSnackBar('✅ SMS sent successfully!', Colors.green);
        } else {
          _showSnackBar(
            '📱 SMS composer was shown but not sent',
            Colors.orange,
          );
        }
      } else {
        _showSnackBar(
          '❌ Failed to show SMS composer: ${result.error}',
          Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _lastResult = 'Error: $e';
      });
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _sendSmsNative() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter a phone number');
      return;
    }

    try {
      final result = await SmsComposerSheet.showNative(
        recipients: [_phoneController.text.trim()],
        body: _messageController.text,
      );

      setState(() {
        _lastResult = 'Native SMS: ${result.toString()}';
      });

      if (result.presented) {
        if (result.sent) {
          _showSnackBar('✅ Native SMS sent successfully!', Colors.green);
        } else {
          _showSnackBar(
            '📱 Native SMS composer was shown but not sent',
            Colors.orange,
          );
        }
      } else {
        _showSnackBar(
          '❌ Failed to show native SMS composer: ${result.error}',
          Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _lastResult = 'Native SMS Error: $e';
      });
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _sendSmsCustom() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter a phone number');
      return;
    }

    try {
      final result = await SmsComposerSheet.showCustom(
        recipients: [_phoneController.text.trim()],
        context: context,
        body: _messageController.text,
        bottomSheetBuilder: (context, recipients, body, onResult) {
          return CustomSmsComposerSheet(
            recipients: recipients,
            body: body,
            onResult: onResult,
          );
        },
      );

      setState(() {
        _lastResult = 'Custom SMS: ${result.toString()}';
      });

      if (result.presented) {
        if (result.sent) {
          _showSnackBar('✅ Custom SMS sent successfully!', Colors.green);
        } else {
          _showSnackBar(
            '📱 Custom SMS composer was shown but not sent',
            Colors.orange,
          );
        }
      } else {
        _showSnackBar(
          '❌ Failed to show custom SMS composer: ${result.error}',
          Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _lastResult = 'Custom SMS Error: $e';
      });
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, [Color? backgroundColor]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Composer Sheet Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Info',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Platform: ${SmsComposerSheet.platformName}'),
                    Text('SMS Available: ${_canSendSms ? 'Yes' : 'No'}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sms, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'SMS Composer Options',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try different SMS composition methods:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+1234567890',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message (optional)',
                        hintText: 'Enter your message here...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.message),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _canSendSms ? _sendSms : null,
                        icon: const Icon(Icons.send),
                        label: const Text('Send SMS (With Permission)'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _canSendSms ? _sendSmsNative : null,
                            icon: const Icon(Icons.smartphone, size: 18),
                            label: const Text('Native SMS'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _canSendSms ? _sendSmsCustom : null,
                            icon: const Icon(Icons.palette, size: 18),
                            label: const Text('Custom UI'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_canSendSms) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning, color: Colors.red, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'SMS not available',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Note: Android emulators typically don\'t have SMS apps installed. Try running on a real device.',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'SMS Methods Available:',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              '• With Permission: Recommended for Android (handles permissions automatically)',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                            Text(
                              '• Native SMS: Uses platform native SMS app/composer',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                            Text(
                              '• Custom UI: Demonstrates custom Android bottom sheet design',
                              style: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_lastResult.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Result',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          _lastResult,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class CustomSmsComposerSheet extends StatelessWidget {
  final List<String> recipients;
  final String? body;
  final Function(SmsResult) onResult;

  const CustomSmsComposerSheet({
    super.key,
    required this.recipients,
    this.body,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom header with purple styling
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  '🎨 Custom SMS Composer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Custom themed SMS composer using package API',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Use the existing SmsComposerWidget with custom theme
          Theme(
            data: ThemeData(
              primarySwatch: Colors.deepPurple,
              scaffoldBackgroundColor: Colors.deepPurple,
              cardColor: Colors.deepPurple,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                hintStyle: TextStyle(color: Colors.white60),
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: SmsComposerWidget(
                recipients: recipients,
                initialBody: body,
                onResult: onResult,
              ),
            ),
          ),
        ],
      ),
    );
  }
}