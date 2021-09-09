//
//  AppDelegate+SendbirdFlutter.swift
//  Runner
//
//  Created by jasonkoo on 9/7/21.
//

import CallKit
import PushKit
import Flutter
import SendBirdCalls

let ERROR_CODE: String = "Sendbird Calls"
let VOIP_TOKEN_KEY : String = "SendbirdVOIP_token"

let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
var callsChannel : FlutterMethodChannel?
var directCall : DirectCall?
var receivingDirectCall : DirectCall?

extension AppDelegate: PKPushRegistryDelegate, SendBirdCallDelegate, DirectCallDelegate {
    
    func enableSendbirdChannels(){
        // To receive incoming call, you need to register VoIP push token
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]

        // Add the call delegate to the SendBirdCall SDK
        SendBirdCall.addDelegate(self, identifier: "flutter")

        // Setup the Flutter platform channles to receive calls from Dartside code
        let controller : FlutterViewController = self.window?.rootViewController as! FlutterViewController
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
                    directCall = makeDirectCall(calleeId: calleeId, callDelegate: self) { directCall, error in
                        guard let e = error else {
                            return
                        }
                        result(FlutterError(code: ERROR_CODE, message: e.description, details: "\(e.errorCode)"))
                    }
                    result(true)
                    return
                case "answer_direct_call":
                    receivingDirectCall?.accept(with: AcceptParams())
                    result(true)
                    return
                case "end_direct_call":
                    directCall?.end()
                    result(true)
                    return
                default: result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
    }
    
    // PKPushRegistryDelgates
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        SendBirdCall.registerVoIPPush(token: pushCredentials.token, unique: true) { error in
            guard error == nil else { return }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type, completionHandler: nil)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) { [weak self] uuid in
            guard uuid != nil else {
                let update = CXCallUpdate()
                update.remoteHandle = CXHandle(type: .generic, value: "invalid")
                let randomUUID = UUID()
                
                let providerConfiguration = CXProviderConfiguration(localizedName: "Sendbird Calls")
                if let image = UIImage(named: "icLogoSymbolInverse") {
                    providerConfiguration.iconTemplateImageData = image.pngData()
                }
                // Even if `.supportsVideo` has `false` value, SendBirdCalls supports video call.
                // However, it needs to be `true` if you want to make video call from native call log, so called "Recents"
                // and update correct type of call log in Recents
                providerConfiguration.supportsVideo = true
                providerConfiguration.maximumCallsPerCallGroup = 1
                providerConfiguration.maximumCallGroups = 1
                providerConfiguration.supportedHandleTypes = [.generic]
                
                // Set up ringing sound
                // If you want to set up other sounds such as dialing, reconnecting and reconnected, see `AppDelegate+SoundEffects.swift` file.
                 providerConfiguration.ringtoneSound = "Ringing.mp3"
                
                let provider = CXProvider(configuration: providerConfiguration)
                provider.reportNewIncomingCall(with: randomUUID, update: update) { [weak provider](error) in
                    provider?.reportCall(with: randomUUID, endedAt: Date(), reason: .failed)
                }
                completion()
                return
            }
            
            completion()
        }
    }
    
    // SendbirdCallDelegate
    func didStartRinging(_ call: DirectCall) {

        call.delegate = self
        receivingDirectCall = call

        // Use CXProvider to report the incoming call to the system
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let name = call.caller?.userId ?? "Unknown"
        let nickname = call.caller?.nickname ?? "Unknown"
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: name)
        update.hasVideo = call.isVideoCall
        update.localizedCallerName = name
        
        // Inform Flutter layer
        DispatchQueue.main.async {
            let payload = [ "caller_id": name,
                            "caller_nickname":nickname]
            callsChannel?.invokeMethod("direct_call_received", arguments: payload)
        }
    }
    
    func didEstablish(_ call: DirectCall) {
        // Inform Flutter layer
        DispatchQueue.main.async {
            callsChannel?.invokeMethod("direct_call_established", arguments: nil)
        }
    }

    // DirectCallDelegates
    func didConnect(_ call: DirectCall) {
        // Inform Flutter layer
        DispatchQueue.main.async {
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

// Call methods

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
