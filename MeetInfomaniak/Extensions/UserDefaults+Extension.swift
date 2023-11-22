//
//  UserDefaults+Extension.swift
//  Sherlock
//
//  Created by Philippe Weidmann on 07.04.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

extension UserDefaults {
    static func store(username: String) {
        UserDefaults.standard.set(username, forKey: "username")
    }

    static func getUsername() -> String? {
        return UserDefaults.standard.string(forKey: "username")
    }
}
