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
                return;
               }

               // If the success is true, the permission is given and notifications will be delivered.
           }
       }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // Store token until user is connected with Sendbird
        remoteNotificationToken = deviceToken;
        
    }

    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        SendBirdCall.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        DispatchQueue.main.async {
            let payload = [ "message": error.localizedDescription]
            callsChannel?.invokeMethod("error", arguments: payload)
        }
    }
    
}
