//
//  AppDelegate+SendbirdFlutter.swift
//  Runner
//
//  Created by jasonkoo on 9/22/21.
//

import Foundation

extension AppDelegate {
    
    func enableSendbirdFlutter(_ application: UIApplication) {
        enableSendbirdPushNotifications(application)
        enableSendbirdVoIP()
        enableSendbirdChannels()
    }
}
