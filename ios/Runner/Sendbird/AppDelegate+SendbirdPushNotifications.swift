//
//  AppDelegate+PushNotifications.swift
//  Runner
//
//  Created by jasonkoo on 9/10/21.
//

import UIKit
import SendBirdCalls

var remoteNotificationToken: Data?

extension AppDelegate {

    
    func enableSendbirdPushNotifications(_ application: UIApplication) {
           
            application.registerForRemoteNotifications()

           let center = UNUserNotificationCenter.current()
           center.requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
               guard error == nil else {
                   // Handle error while requesting permission for notifications.
                   
                   print("AppDelegate+SendbirdPushNotifications: enableSendbirdPushNotifications: ERROR: \(error as AnyObject)")
                   DispatchQueue.main.async {
                       let payload = [ "message": "enableSendbird Error: \(String(describing: error))"]
                       callsChannel?.invokeMethod("error", arguments: payload)
                   }
                return;
               }

               // If the success is true, the permission is given and notifications will be delivered.
               print("AppDelegate+SendbirdPushNotifications: authorization successful: \(success)")

           }
       }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // Store token until user is connected with Sendbird
        remoteNotificationToken = deviceToken;
        
        print("AppDelegate+SendbirdPushNotifications: didRegisterForRemoteNotificationsWithDeviceToken: deviceToken: \(deviceToken as AnyObject)")

    }

    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("AppDelegate+SendbirdPushNotifications: didReceiveRemoteNotification: userInfo: \(userInfo as AnyObject)")
        
        SendBirdCall.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("AppDelegate+SendbirdPushNotifications: didFailToRegisterForRemoteNotifications: ERROR: \(error as AnyObject)")

        DispatchQueue.main.async {
            let payload = [ "message": error.localizedDescription]
            callsChannel?.invokeMethod("error", arguments: payload)
        }
    }
    
}
