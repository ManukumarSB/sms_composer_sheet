package com.sms_composer_sheet.sms_composer_sheet

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.telephony.SmsManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class SmsComposerSheetPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener, PluginRegistry.RequestPermissionsResultListener {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    
    companion object {
        private const val SMS_REQUEST_CODE = 1001
        private const val SMS_PERMISSION_REQUEST_CODE = 1002
    }

    private var permissionResult: Result? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sms_composer_sheet")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "show" -> showSmsComposer(call, result)
            "sendSmsDirectly" -> sendSmsDirectly(call, result)
            "requestSmsPermission" -> requestSmsPermission(result)
            "checkSmsPermission" -> checkSmsPermission(result)
            "canSendSms" -> result.success(canSendSms())
            else -> result.notImplemented()
        }
    }

    private fun showSmsComposer(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null) {
            result.success(mapOf(
                "presented" to false,
                "sent" to false,
                "error" to "Invalid arguments provided",
                "platformResult" to "invalid_args"
            ))
            return
        }

        @Suppress("UNCHECKED_CAST")
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
            
            // Try multiple SMS intent approaches for better compatibility
            var smsIntent: Intent? = null
            var intentType = "sendto"
            
            // Primary approach: ACTION_SENDTO with smsto URI
            val sendtoIntent = Intent(Intent.ACTION_SENDTO).apply {
                data = Uri.parse("smsto:${recipients.joinToString(";")}")
                putExtra("sms_body", body)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            
            if (sendtoIntent.resolveActivity(currentActivity.packageManager) != null) {
                smsIntent = sendtoIntent
                intentType = "sendto"
            } else {
                // Fallback approach: ACTION_VIEW with sms URI
                val viewIntent = Intent(Intent.ACTION_VIEW).apply {
                    data = Uri.parse("sms:${recipients.joinToString(";")}")
                    putExtra("sms_body", body)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                
                if (viewIntent.resolveActivity(currentActivity.packageManager) != null) {
                    smsIntent = viewIntent
                    intentType = "view"
                } else {
                    // Second fallback: Generic ACTION_SEND
                    val sendIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, body)
                        putExtra("address", recipients.joinToString(";"))
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    
                    if (sendIntent.resolveActivity(currentActivity.packageManager) != null) {
                        smsIntent = sendIntent
                        intentType = "send"
                    }
                }
            }
            
            if (smsIntent != null) {
                currentActivity.startActivityForResult(smsIntent, SMS_REQUEST_CODE)
            } else {
                pendingResult = null
                result.success(mapOf(
                    "presented" to false,
                    "sent" to false,
                    "error" to "No SMS app available on this device",
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

    private fun sendSmsDirectly(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments == null) {
            result.success(mapOf(
                "presented" to true,
                "sent" to false,
                "error" to "Invalid arguments provided",
                "platformResult" to "invalid_args"
            ))
            return
        }

        @Suppress("UNCHECKED_CAST")
        val recipients = arguments["recipients"] as? List<String>
        if (recipients.isNullOrEmpty()) {
            result.success(mapOf(
                "presented" to true,
                "sent" to false,
                "error" to "Recipients list cannot be empty",
                "platformResult" to "no_recipients"
            ))
            return
        }

        val body = arguments["body"] as? String ?: ""
        
        // Check for SMS permission
        val currentActivity = activity
        if (currentActivity == null) {
            result.success(mapOf(
                "presented" to true,
                "sent" to false,
                "error" to "No activity available",
                "platformResult" to "no_activity"
            ))
            return
        }
        
        if (ContextCompat.checkSelfPermission(currentActivity, android.Manifest.permission.SEND_SMS) 
            != PackageManager.PERMISSION_GRANTED) {
            result.success(mapOf(
                "presented" to true,
                "sent" to false,
                "error" to "SMS permission not granted. Please grant SMS permission in device settings.",
                "platformResult" to "permission_denied"
            ))
            return
        }
        
        try {
            val smsManager = SmsManager.getDefault()
            var allSent = true
            var errorMessage: String? = null
            
            for (recipient in recipients) {
                try {
                    if (body.length > 160) {
                        // Handle long messages by splitting them
                        val parts = smsManager.divideMessage(body)
                        smsManager.sendMultipartTextMessage(recipient, null, parts, null, null)
                    } else {
                        smsManager.sendTextMessage(recipient, null, body, null, null)
                    }
                } catch (e: Exception) {
                    allSent = false
                    errorMessage = "Failed to send to $recipient: ${e.message}"
                    break
                }
            }
            
            result.success(mapOf(
                "presented" to true,
                "sent" to allSent,
                "error" to errorMessage,
                "platformResult" to if (allSent) "sent" else "partial_failure"
            ))
            
        } catch (e: Exception) {
            result.success(mapOf(
                "presented" to true,
                "sent" to false,
                "error" to "SMS sending failed: ${e.message}",
                "platformResult" to "send_failed"
            ))
        }
    }

    private fun canSendSms(): Boolean {
        return try {
            val activity = this.activity ?: return false
            
            // Check if any SMS-related intent can be resolved
            val sendtoIntent = Intent(Intent.ACTION_SENDTO).apply {
                data = Uri.parse("smsto:")
            }
            
            val viewIntent = Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("sms:")
            }
            
            val sendIntent = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
            }
            
            // Return true if any of these intents can be resolved
            sendtoIntent.resolveActivity(activity.packageManager) != null ||
            viewIntent.resolveActivity(activity.packageManager) != null ||
            sendIntent.resolveActivity(activity.packageManager) != null
        } catch (e: Exception) {
            false
        }
    }

    private fun requestSmsPermission(result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.success(mapOf(
                "hasPermission" to false,
                "message" to "No activity available to request permission",
                "platform" to "Android"
            ))
            return
        }
        
        if (ContextCompat.checkSelfPermission(currentActivity, android.Manifest.permission.SEND_SMS) 
            == PackageManager.PERMISSION_GRANTED) {
            result.success(mapOf(
                "hasPermission" to true,
                "message" to "SMS permission already granted",
                "platform" to "Android"
            ))
            return
        }
        
        permissionResult = result
        ActivityCompat.requestPermissions(
            currentActivity,
            arrayOf(android.Manifest.permission.SEND_SMS),
            SMS_PERMISSION_REQUEST_CODE
        )
    }
    
    private fun checkSmsPermission(result: Result) {
        val currentActivity = activity
        if (currentActivity == null) {
            result.success(mapOf(
                "hasPermission" to false,
                "message" to "No activity available to check permission",
                "platform" to "Android"
            ))
            return
        }
        
        val hasPermission = ContextCompat.checkSelfPermission(
            currentActivity, 
            android.Manifest.permission.SEND_SMS
        ) == PackageManager.PERMISSION_GRANTED
        
        result.success(mapOf(
            "hasPermission" to hasPermission,
            "message" to if (hasPermission) {
                "SMS permission is granted"
            } else {
                "SMS permission is required to send text messages. Please grant SMS permission in device settings."
            },
            "platform" to "Android"
        ))
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == SMS_PERMISSION_REQUEST_CODE) {
            val result = permissionResult
            permissionResult = null
            
            if (result != null) {
                val granted = grantResults.isNotEmpty() && 
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
                
                result.success(mapOf(
                    "hasPermission" to granted,
                    "message" to if (granted) {
                        "SMS permission granted successfully"
                    } else {
                        "SMS permission denied. You can enable it in device settings under App permissions."
                    },
                    "platform" to "Android"
                ))
            }
            return true
        }
        return false
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
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}