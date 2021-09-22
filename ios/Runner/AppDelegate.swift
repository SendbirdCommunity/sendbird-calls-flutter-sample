import UIKit
import PushKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
            
//    var queue: DispatchQueue = DispatchQueue(label: "com.sendbird.calls.quickstart.appdelegate")
    var voipRegistry: PKPushRegistry?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
              
        voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        
        enableSendbirdChannels()
//        enableSendbirdVoIP()
        enableSendbirdVoIP(voipRegistry: voipRegistry!)
        enableSendbirdPushNotifications(application)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

//    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//    
//        
//    }
}

