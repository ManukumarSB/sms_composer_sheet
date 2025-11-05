package com.sms_composer_sheet.sms_composer_sheet

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.telephony.SmsManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class SmsComposerSheetPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    
    companion object {
        private const val SMS_REQUEST_CODE = 1001
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sms_composer_sheet")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "show" -> showSmsComposer(call, result)
            "canSendSms" -> result.success(canSendSms())
            else -> result.notImplemented()
        }
    }

    private fun showSmsComposer(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<String, Any>
        if (arguments == null) {
            result.success(mapOf(
                "presented" to false,
                "sent" to false,
                "error" to "Invalid arguments provided",
                "platformResult" to "invalid_args"
            ))
            return
        }

        val recipients = arguments["recipients"] as? List<String>
        if (recipients.isNullOrEmpty()) {
            result.success(mapOf(
                "presented" to false,
                "sent" to false,
                "error" to "Recipients list cannot be empty",
                "platformResult" to "no_recipients"
            ))
            return
        }

        val body = arguments["body"] as? String ?: ""
        
        if (!canSendSms()) {
            result.success(mapOf(
                "presented" to false,
                "sent" to false,
                "error" to "Device cannot send SMS",
                "platformResult" to "sms_unavailable"
            ))
            return
        }

        val currentActivity = activity
        if (currentActivity == null) {
            result.success(mapOf(
                "presented" to false,
                "sent" to false,
                "error" to "No activity available",
                "platformResult" to "no_activity"
            ))
            return
        }

        try {
            pendingResult = result
            
            // Create SMS intent with bottom sheet-style presentation
            val smsIntent = Intent(Intent.ACTION_SENDTO).apply {
                data = Uri.parse("smsto:${recipients.joinToString(";")}")
                putExtra("sms_body", body)
                // Add flags for bottom sheet-like behavior
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            
            // Check if SMS app is available
            if (smsIntent.resolveActivity(currentActivity.packageManager) != null) {
                currentActivity.startActivityForResult(smsIntent, SMS_REQUEST_CODE)
            } else {
                pendingResult = null
                result.success(mapOf(
                    "presented" to false,
                    "sent" to false,
                    "error" to "No SMS app available",
                    "platformResult" to "no_sms_app"
                ))
            }
        } catch (e: Exception) {
            pendingResult = null
            result.success(mapOf(
                "presented" to false,
                "sent" to false,
                "error" to "Failed to launch SMS composer: ${e.message}",
                "platformResult" to "launch_failed"
            ))
        }
    }

    private fun canSendSms(): Boolean {
        return try {
            val smsManager = SmsManager.getDefault()
            smsManager != null
        } catch (e: Exception) {
            false
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == SMS_REQUEST_CODE) {
            val result = pendingResult
            pendingResult = null
            
            if (result != null) {
                // Android doesn't provide reliable feedback about SMS sending success
                // We assume the composer was presented successfully
                val response = when (resultCode) {
                    Activity.RESULT_OK -> mapOf(
                        "presented" to true,
                        "sent" to true, // Optimistic assumption
                        "platformResult" to "completed"
                    )
                    Activity.RESULT_CANCELED -> mapOf(
                        "presented" to true,
                        "sent" to false,
                        "platformResult" to "cancelled"
                    )
                    else -> mapOf(
                        "presented" to true,
                        "sent" to false,
                        "platformResult" to "unknown_result"
                    )
                }
                result.success(response)
            }
            return true
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}