import UIKit
//import Flutter
//import SendBirdCalls

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        initSendbirdChannels(appDelegate: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    
}

