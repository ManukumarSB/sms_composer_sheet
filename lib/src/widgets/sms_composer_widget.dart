import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/sms_result.dart';

/// Custom SMS composer widget that appears as a bottom sheet
class SmsComposerWidget extends StatefulWidget {
  final List<String> recipients;
  final String? initialBody;
  final Function(SmsResult) onResult;

  const SmsComposerWidget({
    super.key,
    required this.recipients,
    this.initialBody,
    required this.onResult,
  });

  @override
  State<SmsComposerWidget> createState() => _SmsComposerWidgetState();
}

class _SmsComposerWidgetState extends State<SmsComposerWidget> {
  late TextEditingController _messageController;
  late TextEditingController _recipientsController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(text: widget.initialBody ?? '');
    _recipientsController = TextEditingController(
      text: widget.recipients.join(', '),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _recipientsController.dispose();
    super.dispose();
  }

  Future<void> _sendSms() async {
    if (_isSending) return;

    final recipients = _recipientsController.text
        .split(',')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();

    if (recipients.isEmpty) {
      _showError('Please enter at least one recipient');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      // Use the native Android SMS sending directly
      const platform = MethodChannel('sms_composer_sheet');
      final result = await platform.invokeMethod('sendSmsDirectly', {
        'recipients': recipients,
        'body': _messageController.text,
      });

      final smsResult = SmsResult.fromMap(Map<String, dynamic>.from(result));
      
      if (mounted) {
        // Show success/failure snackbar before closing
        if (smsResult.sent) {
          // Add haptic feedback for success
          HapticFeedback.lightImpact();
          _showSuccessMessage('SMS sent successfully!');
        } else if (smsResult.presented && !smsResult.sent) {
          // Add haptic feedback for error
          HapticFeedback.heavyImpact();
          _showError(smsResult.error ?? 'Failed to send SMS');
        }
        
        // Close the bottom sheet after showing status
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onResult(smsResult);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        
        // Handle specific error types
        String errorMessage = 'Failed to send SMS: $e';
        if (e.toString().contains('permission')) {
          errorMessage = 'SMS permission required. Please grant SMS permission in device settings.';
        } else if (e.toString().contains('MissingPluginException')) {
          errorMessage = 'SMS functionality not available on this platform.';
        }
        
        HapticFeedback.heavyImpact();
        _showError(errorMessage);
      }
    }
  }

  void _cancel() {
    Navigator.of(context).pop();
    widget.onResult(const SmsResult(
      presented: true,
      sent: false,
      platformResult: 'cancelled',
    ));
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                TextButton(
                  onPressed: _isSending ? null : _cancel,
                  child: const Text('Cancel'),
                ),
                const Expanded(
                  child: Text(
                    'New Message',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isSending ? null : _sendSms,
                  child: _isSending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Sending...'),
                          ],
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipients field
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'To:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _recipientsController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter phone numbers...',
                          ),
                          keyboardType: TextInputType.phone,
                          enabled: !_isSending,
                        ),
                      ),
                    ],
                  ),
                  
                  const Divider(),
                  
                  // Message field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'iMessage',
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        enabled: !_isSending,
                        onChanged: (text) {
                          setState(() {}); // Trigger rebuild for character count
                        },
                      ),
                      if (_messageController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${_messageController.text.length} characters${_messageController.text.length > 160 ? ' (${(_messageController.text.length / 160).ceil()} SMS)' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: _messageController.text.length > 160 
                                  ? Colors.orange 
                                  : Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}