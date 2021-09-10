import UIKit
import PushKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
            
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
              
        enableSendbirdChannels()
        enableSendbirdVoIP()
        enableSendbirdPushNotifications(application)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

//    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//    
//        
//    }
}

