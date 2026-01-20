import Flutter
import UIKit
import os.log

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    os_log("=== AppDelegate: didFinishLaunchingWithOptions ===", type: .info)
    GeneratedPluginRegistrant.register(with: self)
    os_log("=== AppDelegate: GeneratedPluginRegistrant.register complete ===", type: .info)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
