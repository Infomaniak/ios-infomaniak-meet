//
//  UIConstants.swift
//  MeetInfomaniak
//
//  Created by Matthieu on 01.10.2024.
//  Copyright © 2024 Philippe Weidmann. All rights reserved.
//

import UIKit
import SwiftUI

public class UIConstants {
    
    static let buttonsRadius: CGFloat = 16

    public static func openURL(_ url: URL, from viewController: UIViewController) {
        #if ISEXTENSION
        viewController.extensionContext?.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }
}
