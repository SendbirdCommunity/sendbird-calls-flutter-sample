import UIKit
import Flutter
import SendBirdCalls

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    
    func initSendbird(args: Any, completion: @escaping (Bool) -> ()) {
        let APP_ID = "885C2616-DBF8-4BDC-9178-4A1A662614E3"
        SendBirdCall.configure(appId: APP_ID)
        SBCLogger.setLoggerLevel(.info)
        let params = AuthenticateParams(userId: "UserA", accessToken: "TOKEN")
        
        SendBirdCall.authenticate(with: params) { (user, error) in
            
            guard let user = user, error == nil else {
                // Handle error.
                print("Error")
                completion(false)
                return
            }
            completion(true)
            print(user)
        }
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let callsChannel = FlutterMethodChannel(name: "com.sendbird.calls/method",
                                                binaryMessenger: controller.binaryMessenger)
        callsChannel.setMethodCallHandler({
            //May Need @escaping for async.
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            // Handle battery messages.
            guard call.method == "init" else { return }
            if let args = call.arguments {
                print(args)
                self.initSendbird(args: args) { (connected) -> () in
                    result(connected)
                }
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

