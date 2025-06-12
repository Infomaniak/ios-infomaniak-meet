//
//  Font+Extension.swift
//  MeetInfomaniak
//
//  Created by Matthieu on 11.06.2025.
//  Copyright © 2025 Philippe Weidmann. All rights reserved.
//

import Foundation
import SwiftUI

public extension Font {
    enum Meet {
        /// Figma name: *Titre H2*
        public static let title2 = Font.dynamicTypeSizeFont(size: 18, weight: .semibold, relativeTo: .title2)
        /// Figma name: *Body Medium*
        public static let headline = Font.dynamicTypeSizeFont(size: 16, weight: .medium, relativeTo: .headline)
        /// Figma name: *Body Regular*
        public static let body = Font.dynamicTypeSizeFont(size: 16, weight: .regular, relativeTo: .body)
    }
}
