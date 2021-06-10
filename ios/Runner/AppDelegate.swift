import UIKit
import Flutter
import SendBirdCalls

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    
    func initSendbird(call: FlutterMethodCall, completion: @escaping (Bool) -> ()) {
        
        guard let args = call.arguments as? Dictionary<String, Any> else {
            return
        }
        
        guard let APP_ID = args["app_id"] as? String else {
            completion(false)
            return
        }
        
        guard let userId = args["user_id"] as? String else {
            completion(false)
            return
        }
        
//        let APP_ID = "885C2616-DBF8-4BDC-9178-4A1A662614E3"
        SendBirdCall.configure(appId: APP_ID)
        SBCLogger.setLoggerLevel(.info)
        let params = AuthenticateParams(userId: userId, accessToken: "TOKEN")
        
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

            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

            guard call.method == "init" else { return }
        
            self.initSendbird(call: call) { (connected) -> () in
                    result(connected)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

