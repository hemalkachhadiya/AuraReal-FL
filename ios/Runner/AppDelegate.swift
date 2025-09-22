import AVFoundation
import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if let controller = window?.rootViewController as? FlutterViewController {

      let cameraChannel = FlutterMethodChannel(
        name: "camera_permission_channel",
        binaryMessenger: controller.binaryMessenger
      )
      cameraChannel.setMethodCallHandler {
        (call: FlutterMethodCall, result: @escaping FlutterResult) in
        if call.method == "checkCameraPermission" {
          self.checkCameraPermission(result: result)
        }
      }

    }
    GMSServices.provideAPIKey("AIzaSyAEp1bymEbwslNks5rrCgtFKXrcOvAp_O0")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

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
}
