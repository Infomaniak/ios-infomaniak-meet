//
//  RoomCodeChecker.swift
//  MeetInfomaniak
//
//  Created by Philippe on 13.08.2024.
//  Copyright © 2024 Philippe Weidmann. All rights reserved.
//

import Foundation

struct RoomCodeChecker {
    private let roomCodeRegex = try! NSRegularExpression(pattern: #"^(\d{3}-\d{4}-\d{3}|\d{10})$"#)

    func isRoomCode(text: String) -> Bool {
        roomCodeRegex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
            .count > 0
    }
}
