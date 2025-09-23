//import AVFoundation
//import Firebase
//import FirebaseMessaging
//import Flutter
//import GoogleMaps
//import UIKit
//import UserNotifications
//
//@main
//@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//
//    FirebaseApp.configure()
//
//    if #available(iOS 10.0, *) {
//      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//    }
//    // Request notification permission
//    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//    UNUserNotificationCenter.current().requestAuthorization(
//      options: authOptions,
//      completionHandler: { _, _ in }
//    )
//
//    if let controller = window?.rootViewController as? FlutterViewController {
//
//      let cameraChannel = FlutterMethodChannel(
//        name: "camera_permission_channel",
//        binaryMessenger: controller.binaryMessenger
//      )
//      cameraChannel.setMethodCallHandler {
//        (call: FlutterMethodCall, result: @escaping FlutterResult) in
//        if call.method == "checkCameraPermission" {
//          self.checkCameraPermission(result: result)
//        }
//      }
//
//    }
//    GMSServices.provideAPIKey("AIzaSyAEp1bymEbwslNks5rrCgtFKXrcOvAp_O0")
//    GeneratedPluginRegistrant.register(with: self)
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//
//  private func checkCameraPermission(result: @escaping FlutterResult) {
//    switch AVCaptureDevice.authorizationStatus(for: .video) {
//    case .authorized:
//      result("authorized")
//    case .notDetermined:
//      AVCaptureDevice.requestAccess(for: .video) { granted in
//        result(granted ? "granted" : "denied")
//      }
//    case .denied, .restricted:
//      result("permanentlyDenied")
//    @unknown default:
//      result("unknown")
//    }
//  }
//
//}
//// MARK: - UNUserNotificationCenterDelegate
//
import AVFoundation
import Firebase
import FirebaseMessaging
import Flutter
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()

    // Set delegate for notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    Messaging.messaging().delegate = self

    // Request notification permission
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
        print("Notification permission granted: \(granted)")
    }

    // Flutter camera permission channel
    if let controller = window?.rootViewController as? FlutterViewController {
      let cameraChannel = FlutterMethodChannel(
        name: "camera_permission_channel",
        binaryMessenger: controller.binaryMessenger
      )
      cameraChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "checkCameraPermission" {
          self.checkCameraPermission(result: result)
        }
      }
    }

    GMSServices.provideAPIKey("AIzaSyAEp1bymEbwslNks5rrCgtFKXrcOvAp_O0")
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Camera Permission
  private func checkCameraPermission(result: @escaping FlutterResult) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      result("authorized")
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { granted in
        result(granted ? "granted" : "denied")
      }
    case .denied, .restricted:
      result("permanentlyDenied")
    @unknown default:
      result("unknown")
    }
  }

  // MARK: - Foreground Notification
    @available(iOS 10.0, *)
    override func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
      if #available(iOS 14.0, *) {
        completionHandler([.banner, .sound, .badge])  // iOS 14 and above
      } else {
        completionHandler([.alert, .sound, .badge])   // iOS 13 fallback
      }
    }

  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    // Handle tap on notification
    completionHandler()
  }
}
