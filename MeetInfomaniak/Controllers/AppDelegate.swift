//
//  AppDelegate.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit
import JitsiMeet

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let jitisiOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL(string: "https://meet.infomaniak.com")
        }
        JitsiMeet.sharedInstance().defaultConferenceOptions = jitisiOptions
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            if let hash = url.absoluteString.split(separator: "/").last {
                let joinViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! JoinViewController
                joinViewController.roomId = String(hash)
                self.window?.rootViewController = joinViewController
                self.window?.makeKeyAndVisible()
            }
        }
        return true
    }

}

