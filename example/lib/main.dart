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
      final result = await SmsComposerSheet.show(
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
          _showSnackBar('📱 SMS composer was shown but not sent', Colors.orange);
        }
      } else {
        _showSnackBar('❌ Failed to show SMS composer: ${result.error}', Colors.red);
      }
    } catch (e) {
      setState(() {
        _lastResult = 'Error: $e';
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
      body: Padding(
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
                    Text(
                      'Send SMS',
                      style: Theme.of(context).textTheme.titleMedium,
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
                        label: const Text('Send SMS'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    if (!_canSendSms) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'SMS not available on this device/emulator',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Note: Android emulators typically don\'t have SMS apps installed',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
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