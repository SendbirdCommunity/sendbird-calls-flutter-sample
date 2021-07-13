//
//  SendbirdManager.swift
//  Runner
//
//  Created by jasonkoo on 7/13/21.
//

import Foundation
import Flutter
import SendBirdCalls

let ERROR_CODE: String = "Sendbird Calls"
var directCall : DirectCall?

func initSendbirdChannels(appDelegate: FlutterAppDelegate){
    return initSendbirdChannels(appDelegate: appDelegate, callDelegate: nil)
}

func initSendbirdChannels(appDelegate: FlutterAppDelegate, callDelegate: DirectCallDelegate?){
    // Set up Flutter Platform Channels
    
    let controller : FlutterViewController = appDelegate.window?.rootViewController as! FlutterViewController
    let callsChannel = FlutterMethodChannel(name: "com.sendbird.calls/method",
                                            binaryMessenger: controller.binaryMessenger)
    callsChannel.setMethodCallHandler({

        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

        switch call.method {
            case "init":
                initSendbird(call: call) { (connected) -> () in
                        result(connected)
                }
            case "direct_call":
                guard let args = call.arguments as? [String: Any] else {
                    result(FlutterError(code: ERROR_CODE, message: "FlutterMethodCall argument invalid", details: "Not expected [String:Any] type found: \(type(of:call.arguments))"))
                    return
                }
                guard let calleeId = args["callee_id"] as? String else {
                    result(FlutterError(code: ERROR_CODE, message: "Required FlutterMethodCall argument missing", details: "callee_id key-value missing"))
                    return
                }
                directCall = makeDirectCall(calleeId: calleeId, callDelegate: callDelegate) { directCall, error in
                    guard let e = error else {
                        return
                    }
                    result(FlutterError(code: ERROR_CODE, message: e.description, details: "\(e.errorCode)"))
                }
            case "answer_call":
                result(FlutterMethodNotImplemented)
//                answerDirectCall()
            case "end_direct_call":
                directCall?.end()
            default: result(FlutterMethodNotImplemented)
        }
    })
    
    GeneratedPluginRegistrant.register(with: appDelegate)
}

func initSendbird(call: FlutterMethodCall, completion: @escaping (Bool) -> ()) {
    // Initialize Sendbird calls from Flutter
    
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
    
    // Optional access token
    let accessToken = args["user_access_token"] as? String
    
    SendBirdCall.configure(appId: APP_ID)
    SBCLogger.setLoggerLevel(.info)
    let params = AuthenticateParams(userId: userId, accessToken: accessToken)
    
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

func makeDirectCall(calleeId: String, callDelegate: DirectCallDelegate?, callCompletion: @escaping DirectCallHandler) -> DirectCall? {
    let params = DialParams(calleeId: calleeId, callOptions: CallOptions())
    let directCall = SendBirdCall.dial(with: params, completionHandler: callCompletion)
    directCall?.delegate = callDelegate
    return directCall
}

func answerDirectCall(){
    
}
