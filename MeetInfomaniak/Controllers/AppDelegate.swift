//
//  AppDelegate.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 01.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import JitsiMeetSDK
import UIKit

let baseServerURL = "https://kmeet.infomaniak.com"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let jitisiOptions = JitsiMeetConferenceOptions.fromBuilder { builder in
            builder.serverURL = URL(string: baseServerURL)
            builder.setVideoMuted(true)

            builder.setFeatureFlag("settings.enabled", withBoolean: false)
            builder.setFeatureFlag("unsaferoomwarning.enabled", withBoolean: false)
            builder.setFeatureFlag("recording.enabled", withBoolean: false)
            builder.setFeatureFlag("video-share.enabled", withBoolean: false)
            builder.setFeatureFlag("live-streaming.enabled", withBoolean: false)
            builder.setConfigOverride("hideConferenceSubject", withBoolean: true)
        }
        JitsiMeet.sharedInstance().defaultConferenceOptions = jitisiOptions

        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var isReturningFromBackground = false

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        if let url = connectionOptions.urlContexts.first?.url
            ?? connectionOptions.userActivities.compactMap(\.webpageURL).first {
            launchFromLink(url: url)
        } else {
            window?.rootViewController = UINavigationController(rootViewController: InitialViewController.instantiate())
            window?.makeKeyAndVisible()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        guard isReturningFromBackground else { return }
        isReturningFromBackground = false
        window?.rootViewController?.beginAppearanceTransition(true, animated: false)
        window?.rootViewController?.endAppearanceTransition()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        isReturningFromBackground = true
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            launchFromLink(url: url)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let url = userActivity.webpageURL {
            launchFromLink(url: url)
        }
    }

    private func launchFromLink(url: URL) {
        let navigationController = UINavigationController()
        let joinViewController = JoinViewController.instantiate()
        joinViewController.joining = true
        joinViewController.joinUrl = URL(string: url.absoluteString.replacingOccurrences(of: "kmeet://", with: "https://"))
        navigationController.setViewControllers([InitialViewController.instantiate(), joinViewController], animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
