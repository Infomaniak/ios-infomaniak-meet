//
//  UpdateVersionBridgeViewController.swift
//  MeetInfomaniak
//
//  Created by Matthieu on 06.06.2025.
//  Copyright © 2025 Philippe Weidmann. All rights reserved.
//

import DesignSystem
import SwiftUI
import VersionChecker

enum UpdateVersionBridgeViewController {
    public static func instantiate() -> UIViewController {
        @Environment(\.openURL) var openURL

        let swiftUIView = UpdateVersionView(image: Image("laptop-stars-rocket")) { willUpdate in
            if willUpdate {
                openURL(Constants.appStore)
            }
        }

        return UIHostingController(rootView: ScrollView { swiftUIView })
    }
}
