//
//  Assets.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 12.04.21.
//  Copyright © 2021 Philippe Weidmann. All rights reserved.
//

import SwiftUI
import UIKit

enum Assets {
    static let infomaniakTintColor = UIColor(named: "infomaniakTint")!
    static let textColor = UIColor(named: "textColor")!
    static let outlineColor = UIColor(named: "outlineColor")!
    static let infoIcon = UIImage(named: "ic_info")!
}

extension Assets {
    enum SwiftUIColor {
        static let infomaniakTintColor = Color("infomaniakTint")
        static let textColor = Color("textColor")
        static let backgroundColor = Color("backgroundColor")
        static let outlineColor = Color("outlineColor")
    }
}
