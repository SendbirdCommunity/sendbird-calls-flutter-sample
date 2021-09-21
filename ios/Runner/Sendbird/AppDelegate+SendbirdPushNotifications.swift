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

                return;
               }

               // If the success is true, the permission is given and notifications will be delivered.
           }
       }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // Store token until user is connected with Sendbird
        remoteNotificationToken = deviceToken;
        
        print("application: didRegisterForRemoteNotificationsWithDeviceToken: deviceToken: \(deviceToken as AnyObject)")

    }

    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("application: didReceiveRemoteNotification: userInfo: \(userInfo as AnyObject)")

//        DispatchQueue.main.async {
//            let payload = [ "message": "didReceiveRemoteNotification userInfo: \(String(describing: userInfo as AnyObject))"]
//            callsChannel?.invokeMethod("error", arguments: payload)
//        }
        
        SendBirdCall.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("application: didFailToRegisterForRemoteNotifications: ERROR: \(error as AnyObject)")

//        DispatchQueue.main.async {
//            let payload = [ "message": error.localizedDescription]
//            callsChannel?.invokeMethod("error", arguments: payload)
//        }
    }
    
}
