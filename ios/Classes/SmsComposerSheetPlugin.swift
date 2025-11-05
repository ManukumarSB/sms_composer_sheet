import Flutter
import UIKit
import MessageUI

public class SmsComposerSheetPlugin: NSObject, FlutterPlugin {
    private var flutterResult: FlutterResult?
    private var presentingViewController: UIViewController?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sms_composer_sheet", binaryMessenger: registrar.messenger())
        let instance = SmsComposerSheetPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "show":
            showSmsComposer(call: call, result: result)
        case "canSendSms":
            result(MFMessageComposeViewController.canSendText())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func showSmsComposer(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let recipients = args["recipients"] as? [String] else {
            result([
                "presented": false,
                "sent": false,
                "error": "Invalid arguments provided",
                "platformResult": "invalid_args"
            ])
            return
        }
        
        let body = args["body"] as? String ?? ""
        
        guard MFMessageComposeViewController.canSendText() else {
            result([
                "presented": false,
                "sent": false,
                "error": "Device cannot send SMS",
                "platformResult": "sms_unavailable"
            ])
            return
        }
        
        guard let viewController = getRootViewController() else {
            result([
                "presented": false,
                "sent": false,
                "error": "Could not find root view controller",
                "platformResult": "no_view_controller"
            ])
            return
        }
        
        self.flutterResult = result
        self.presentingViewController = viewController
        
        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.recipients = recipients
        messageComposer.body = body
        
        DispatchQueue.main.async {
            viewController.present(messageComposer, animated: true, completion: nil)
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        var rootViewController = window.rootViewController
        while let presentedViewController = rootViewController?.presentedViewController {
            rootViewController = presentedViewController
        }
        
        return rootViewController
    }
}

extension SmsComposerSheetPlugin: MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
        
        guard let flutterResult = self.flutterResult else {
            return
        }
        
        let response: [String: Any]
        
        switch result {
        case .cancelled:
            response = [
                "presented": true,
                "sent": false,
                "platformResult": "cancelled"
            ]
        case .sent:
            response = [
                "presented": true,
                "sent": true,
                "platformResult": "sent"
            ]
        case .failed:
            response = [
                "presented": true,
                "sent": false,
                "error": "Failed to send SMS",
                "platformResult": "failed"
            ]
        @unknown default:
            response = [
                "presented": true,
                "sent": false,
                "error": "Unknown result",
                "platformResult": "unknown"
            ]
        }
        
        flutterResult(response)
        self.flutterResult = nil
        self.presentingViewController = nil
    }
}