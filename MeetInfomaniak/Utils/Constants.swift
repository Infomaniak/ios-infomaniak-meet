//
//  Constants.swift
//  MeetInfomaniak
//
//  Created by Matthieu on 01.10.2024.
//  Copyright © 2024 Philippe Weidmann. All rights reserved.
//

import Foundation

public struct URLConstants {

    public static let appStore = URLConstants(urlString: "https://apps.apple.com/ch/app/infomaniak-kmeet/id1505940319")
    
    private var urlString: String

    public var url: URL {
        guard let url = URL(string: urlString) else {
            fatalError("Invalid URL")
        }
        return url
    }
}
