import UIKit
import Flutter
import MessageUI

/// iOS SMS composer plugin with bottom sheet presentation
@available(iOS 13.0, *)
public class SmsComposerSheetPlugin: NSObject, FlutterPlugin, MFMessageComposeViewControllerDelegate {
    
    private var pendingResult: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sms_composer_sheet", binaryMessenger: registrar.messenger())
        
        // Register appropriate plugin based on iOS version
        if #available(iOS 13.0, *) {
            let instance = SmsComposerSheetPlugin()
            registrar.addMethodCallDelegate(instance, channel: channel)
        } else {
            let instance = SmsComposerSheetPluginLegacy()
            registrar.addMethodCallDelegate(instance, channel: channel)
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "show":
            handleShow(call: call, result: result)
        case "canSendSms":
            handleCanSendSms(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleCanSendSms(result: @escaping FlutterResult) {
        result(MFMessageComposeViewController.canSendText())
    }
    
    private func handleShow(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Ensure we're on main thread
        DispatchQueue.main.async { [weak self] in
            self?.presentSmsComposer(call: call, result: result)
        }
    }
    
    private func presentSmsComposer(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Check if device can send SMS
        guard MFMessageComposeViewController.canSendText() else {
            result([
                "presented": false,
                "sent": false,
                "error": "device_cannot_send_sms",
                "platformResult": "unavailable"
            ])
            return
        }
        
        // Parse arguments
        guard let args = call.arguments as? [String: Any],
              let recipients = args["recipients"] as? [String] else {
            result([
                "presented": false,
                "sent": false,
                "error": "invalid_arguments",
                "platformResult": "parse_error"
            ])
            return
        }
        
        let body = args["body"] as? String ?? ""
        
        // Validate recipients
        guard !recipients.isEmpty else {
            result([
                "presented": false,
                "sent": false,
                "error": "empty_recipients",
                "platformResult": "validation_error"
            ])
            return
        }
        
        // Store the result callback
        if pendingResult != nil {
            // Already have a pending operation
            result([
                "presented": false,
                "sent": false,
                "error": "operation_in_progress",
                "platformResult": "busy"
            ])
            return
        }
        
        pendingResult = result
        
        // Create message composer
        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.recipients = recipients
        messageComposer.body = body
        
        // Configure for maximum screen coverage like WhatsApp
        if #available(iOS 15.0, *) {
            messageComposer.modalPresentationStyle = .pageSheet
        } else {
            // For older iOS versions, use full screen coverage
            messageComposer.modalPresentationStyle = .overFullScreen
        }
        
        // Configure sheet presentation for 90% screen coverage (iOS 15+)
        if #available(iOS 15.0, *) {
            if let sheet = messageComposer.sheetPresentationController {
                // Create custom detent for 90% height to match WhatsApp style
                if #available(iOS 16.0, *) {
                    let fullScreenDetent = UISheetPresentationController.Detent.custom { context in
                        return context.maximumDetentValue * 0.92 // 92% of screen height for maximum coverage
                    }
                    sheet.detents = [fullScreenDetent] // Only provide the large detent
                } else {
                    // Fallback for iOS 15: Use only large detent for maximum coverage
                    sheet.detents = [.large()]
                }
                
                // Configure for full-screen-like appearance
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 16 // Slightly smaller radius for fuller appearance
                sheet.largestUndimmedDetentIdentifier = nil // Allow dimming behind sheet
                
                // Additional iOS 16+ configurations for better full-screen appearance
                if #available(iOS 16.0, *) {
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                }
            }
        }
        
        // Find top-most view controller
        guard let topViewController = getTopMostViewController() else {
            pendingResult = nil
            result([
                "presented": false,
                "sent": false,
                "error": "no_view_controller",
                "platformResult": "presentation_error"
            ])
            return
        }
        
        // Present the composer
        topViewController.present(messageComposer, animated: true) { [weak self] in
            // Presentation completed successfully
            // Don't call result here - wait for delegate callback
        }
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, 
                                           didFinishWith result: MessageComposeResult) {
        
        // Debug: Print the result to understand what's happening
        print("SMS Delegate called with result: \(result.rawValue)")
        
        controller.dismiss(animated: true) { [weak self] in
            self?.handleComposeResult(result)
        }
    }
    
    private func handleComposeResult(_ result: MessageComposeResult) {
        guard let flutterResult = pendingResult else {
            print("SMS Error: No pending result found")
            return
        }
        
        pendingResult = nil
        
        let (sent, platformResult) = mapComposeResult(result)
        
        print("SMS Result - Sent: \(sent), Platform: \(platformResult)")
        
        flutterResult([
            "presented": true,
            "sent": sent,
            "platformResult": platformResult,
            "error": nil
        ])
    }
    
    private func mapComposeResult(_ result: MessageComposeResult) -> (Bool, String) {
        switch result {
        case .sent:
            return (true, "sent")
        case .cancelled:
            return (false, "cancelled")  
        case .failed:
            return (false, "failed")
        @unknown default:
            return (false, "unknown")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Find the top-most presentable view controller
    private func getTopMostViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        return findTopMostViewController(from: rootViewController)
    }
    
    private func findTopMostViewController(from viewController: UIViewController) -> UIViewController {
        // If there's a presented view controller, go deeper
        if let presentedViewController = viewController.presentedViewController {
            return findTopMostViewController(from: presentedViewController)
        }
        
        // Handle navigation controller
        if let navigationController = viewController as? UINavigationController,
           let topViewController = navigationController.topViewController {
            return findTopMostViewController(from: topViewController)
        }
        
        // Handle tab bar controller
        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return findTopMostViewController(from: selectedViewController)
        }
        
        // This is the top-most
        return viewController
    }
}

// MARK: - iOS 12 Compatibility Implementation

/// Fallback for iOS versions < 13 with basic SMS composer
@available(iOS, deprecated: 13.0, message: "Use SmsComposerSheetPlugin for iOS 13+")
public class SmsComposerSheetPluginLegacy: NSObject, FlutterPlugin, MFMessageComposeViewControllerDelegate {
    
    private var pendingResult: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "sms_composer_sheet", binaryMessenger: registrar.messenger())
        let instance = SmsComposerSheetPluginLegacy()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "show":
            handleShowLegacy(call: call, result: result)
        case "canSendSms":
            result(MFMessageComposeViewController.canSendText())
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleShowLegacy(call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Check if device can send SMS
        guard MFMessageComposeViewController.canSendText() else {
            result([
                "presented": false,
                "sent": false,
                "error": "device_cannot_send_sms",
                "platformResult": "unavailable"
            ])
            return
        }
        
        // Parse arguments
        guard let args = call.arguments as? [String: Any],
              let recipients = args["recipients"] as? [String] else {
            result([
                "presented": false,
                "sent": false,
                "error": "invalid_arguments",
                "platformResult": "parse_error"
            ])
            return
        }
        
        let body = args["body"] as? String ?? ""
        
        // Validate recipients
        guard !recipients.isEmpty else {
            result([
                "presented": false,
                "sent": false,
                "error": "empty_recipients",
                "platformResult": "validation_error"
            ])
            return
        }
        
        // Store the result callback
        if pendingResult != nil {
            result([
                "presented": false,
                "sent": false,
                "error": "operation_in_progress",
                "platformResult": "busy"
            ])
            return
        }
        
        pendingResult = result
        
        // Create message composer with basic presentation for iOS 12
        let messageComposer = MFMessageComposeViewController()
        messageComposer.messageComposeDelegate = self
        messageComposer.recipients = recipients
        messageComposer.body = body
        messageComposer.modalPresentationStyle = .fullScreen
        
        // Find root view controller
        guard let rootViewController = getRootViewControllerLegacy() else {
            pendingResult = nil
            result([
                "presented": false,
                "sent": false,
                "error": "no_view_controller",
                "platformResult": "presentation_error"
            ])
            return
        }
        
        // Present the composer
        DispatchQueue.main.async {
            rootViewController.present(messageComposer, animated: true, completion: nil)
        }
    }
    
    private func getRootViewControllerLegacy() -> UIViewController? {
        guard let window = UIApplication.shared.keyWindow,
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate for Legacy
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, 
                                           didFinishWith result: MessageComposeResult) {
        
        controller.dismiss(animated: true) { [weak self] in
            self?.handleLegacyComposeResult(result)
        }
    }
    
    private func handleLegacyComposeResult(_ result: MessageComposeResult) {
        guard let flutterResult = pendingResult else {
            return
        }
        
        pendingResult = nil
        
        let (sent, platformResult) = mapLegacyComposeResult(result)
        
        flutterResult([
            "presented": true,
            "sent": sent,
            "platformResult": platformResult,
            "error": nil
        ])
    }
    
    private func mapLegacyComposeResult(_ result: MessageComposeResult) -> (Bool, String) {
        switch result {
        case .sent:
            return (true, "sent")
        case .cancelled:
            return (false, "cancelled")  
        case .failed:
            return (false, "failed")
        @unknown default:
            return (false, "unknown")
        }
    }
}