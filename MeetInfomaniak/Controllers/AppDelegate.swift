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
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        window?.rootViewController?.beginAppearanceTransition(false, animated: false)
        window?.rootViewController?.endAppearanceTransition()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        window?.rootViewController?.beginAppearanceTransition(true, animated: false)
        window?.rootViewController?.endAppearanceTransition()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let jitisiOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL(string: "https://meet.infomaniak.com")
        }
        JitsiMeet.sharedInstance().defaultConferenceOptions = jitisiOptions
        return true
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let hash = URLComponents(url: url, resolvingAgainstBaseURL: true)?.url?.absoluteString.replacingOccurrences(of: "kmeet://", with: "") {
            launchFromLink(hash: hash)
        }
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            if let hash = URLComponents(url: url, resolvingAgainstBaseURL: true)?.path.replacingOccurrences(of: "/", with: "") {
                launchFromLink(hash: hash)
            }
        }
        return true
    }

    func launchFromLink(hash: String) {
        let emptyHash = hash.count == 0
        let joinViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! JoinViewController
        joinViewController.shouldAutoJoin = !emptyHash
        joinViewController.roomId = emptyHash ? nil : String(hash)
        self.window?.rootViewController = joinViewController
        self.window?.makeKeyAndVisible()
    }

}

