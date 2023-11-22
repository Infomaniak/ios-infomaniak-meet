//
//  ApiResponse.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 11.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

enum ApiResult: String, Codable {
    case success
    case error
}

class ApiResponse<ResponseContent: Codable>: Codable {
    let result: ApiResult
    let data: ResponseContent
}
