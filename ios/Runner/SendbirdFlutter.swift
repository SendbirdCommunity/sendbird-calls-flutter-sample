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
let callHandler = SendbirdCallHandler()
var callsChannel : FlutterMethodChannel?
var directCall : DirectCall?
var receivingDirectCall : DirectCall?

class SendbirdCallHandler : SendBirdCallDelegate, DirectCallDelegate {
    
    // SendbirdCallDelegate
    func didStartRinging(_ call: DirectCall) {
        // Inform Flutter layer
        DispatchQueue.main.async {
            callsChannel?.invokeMethod("direct_call_received", arguments: nil)
            receivingDirectCall = call
        }
    }

    // DirectCallDelegates
    func didConnect(_ call: DirectCall) {
        // Inform Flutter layer
        DispatchQueue.main.async {
            print("SendbirdFlutter: didConnect")
            callsChannel?.invokeMethod("direct_call_connected", arguments: nil)
        }
    }

    func didEnd(_ call: DirectCall) {
        // Inform Flutter layer
        DispatchQueue.main.async {
            callsChannel?.invokeMethod("direct_call_ended", arguments: nil)
        }
    }
}
    
func enableSendbirdChannels(appDelegate: FlutterAppDelegate){
    return initSendbirdChannels(appDelegate: appDelegate,
                                callDelegate: callHandler)
}

func initSendbirdChannels(appDelegate: FlutterAppDelegate,
                          callDelegate: DirectCallDelegate){
    
    // Set up Flutter Platform Channels
    
    let controller : FlutterViewController = appDelegate.window?.rootViewController as! FlutterViewController
    callsChannel = FlutterMethodChannel(name: "com.sendbird.calls/method",
                                            binaryMessenger: controller.binaryMessenger)
    callsChannel?.setMethodCallHandler({

        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

        switch call.method {
            case "init":
                initSendbird(call: call) { (connected) -> () in
                        result(connected)
                }
                return
            case "start_direct_call":
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
                return
            case "answer_direct_call":
                directCall = receivingDirectCall
                directCall?.accept(with: AcceptParams())
                result(true)
                return
            case "end_direct_call":
                directCall?.end()
                result(true)
                return
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
