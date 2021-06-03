//
//  AppDelegate.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import UIKit
import JitsiMeetSDK
/* strip bitcode before pusing: xcrun bitcode_strip -r WebRTC.framework/WebRTC -o WebRTC.framework/WebRTC*/

let baseServerURL = "https://kmeet.infomaniak.com"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationWillEnterForeground(_ application: UIApplication) {
        window?.rootViewController?.beginAppearanceTransition(true, animated: false)
        window?.rootViewController?.endAppearanceTransition()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let jitisiOptions = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL(string: baseServerURL)
            builder.videoMuted = true
            builder.welcomePageEnabled = false
            builder.setFeatureFlag("recording.enabled", withBoolean: false)
            builder.setFeatureFlag("video-share.enabled", withBoolean: false)
            builder.setFeatureFlag("live-streaming.enabled", withBoolean: false)
        }
        JitsiMeet.sharedInstance().defaultConferenceOptions = jitisiOptions


        window?.rootViewController = UINavigationController(rootViewController: InitialViewController.instantiate())
        window?.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        launchFromLink(url: url)
        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            launchFromLink(url: url)
        }
        return true
    }

    func launchFromLink(url: URL) {
        let navigationController = UINavigationController()
        let joinViewController = JoinViewController.instantiate()
        joinViewController.joining = true
        joinViewController.joinUrl = URL(string: url.absoluteString.replacingOccurrences(of: "kmeet://", with: "https://"))
        navigationController.setViewControllers([InitialViewController.instantiate(), joinViewController], animated: false)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }

}
