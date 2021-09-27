//
//  AppDelegate+PKPushRegistry.swift
//  Runner
//
//  Created by jasonkoo on 9/10/21.
//

import Foundation
import CallKit
import PushKit
import SendBirdCalls

let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)

extension AppDelegate: PKPushRegistryDelegate {
    
    func enableSendbirdVoIP(){
        
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [.voIP]
        
        print("AppDelegate + SendbirdVoIP: enableSendbirdVoIP: voipRegistry: \(voipRegistry as AnyObject)")

    }
    
    // PKPushRegistryDelgates
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {

        print("AppDelegate + SendbirdVoIP: pushRegistry: didUpdate w/ credentials: \(pushCredentials.token)")

        SendBirdCall.registerVoIPPush(token: pushCredentials.token, unique: true) { error in
            guard error != nil else {
                
                print("AppDelegate + SendbirdVoIP: enableSendbirdVoIP: didUpdate w/ credentials Sendbird registerVoIPush ERROR: \(String(describing: error))")

                DispatchQueue.main.async {
                    let payload = [ "message": "registerVoIPPush Error: \(String(describing: error))"]
                    callsChannel?.invokeMethod("error", arguments: payload)
                }
                return
            }
        }
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        
        print("AppDelegate + SendbirdVoIP: pushRegistry: didReceiveIncomingPushWith payload: \(payload as AnyObject) - no completion")

        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type, completionHandler: nil)
    }

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        print("AppDelegate + SendbirdVoIP: payload received: \(payload as AnyObject)")
        
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type) { uuid in
            guard uuid != nil else {

                print("AppDelegate + SendbirdVoIP: didReceiveIncomingPushWith payload. Sendbird has no uuid.")
                
                DispatchQueue.main.async {
                    let payload = [ "message": "no uuid returned when receiving push payload: \(payload.dictionaryPayload as AnyObject)"]
                    callsChannel?.invokeMethod("error", arguments: payload)
                }

                let update = CXCallUpdate()
                update.remoteHandle = CXHandle(type: .generic, value: "invalid")
                let randomUUID = UUID()

                let provider = sendbirdProvider()
                provider.reportNewIncomingCall(with: randomUUID, update: update) { [weak provider](error) in
                    provider?.reportCall(with: randomUUID, endedAt: Date(), reason: .failed)
                }
                completion()
                return
            }

            print("AppDelegate + SendbirdVoIP: didReceiveIncomingPushWith payload. Sendbird uuid: \(String(describing: uuid))")

            completion()
        }
    }
    
}

func sendbirdProvider() -> CXProvider {
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
    return provider
}
