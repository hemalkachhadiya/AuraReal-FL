import Flutter
import UIKit
import GoogleMaps  // 👈 Add this

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // 👇 Add your API key here
    GMSServices.provideAPIKey("AIzaSyAEp1bymEbwslNks5rrCgtFKXrcOvAp_O0")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
