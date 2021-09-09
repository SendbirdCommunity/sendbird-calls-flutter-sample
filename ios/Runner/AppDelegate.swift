import UIKit
import PushKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
            
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
                
        enableSendbirdChannels()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    
}

