//
//  ApiFetcher.swift
//  MeetInfomaniak
//
//  Created by Philippe Weidmann on 11.08.20.
//  Copyright © 2020 Philippe Weidmann. All rights reserved.
//

import Foundation

class ApiFetcher {
    
    public static func getRoomNameFromCode(_ code: String, completion: @escaping (ApiResponse<CodeRoomName>?, Error?) -> Void) {
        let request = URLRequest(url: URL(string: "https://welcome.infomaniak.com/api/components/meet/conference/\(code)")!)

        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, sessionError) in
            if let response = response as? HTTPURLResponse {
                if response.isSuccessful() && data != nil && data!.count > 0 {
                    do {
                        let apiToken = try JSONDecoder().decode(ApiResponse<CodeRoomName>.self, from: data!)
                        completion(apiToken, nil)
                    } catch {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, sessionError ?? NSError(domain: "ApiError", code: response.statusCode, userInfo: nil))
                }
            } else {
                completion(nil, sessionError)
            }
        }.resume()
    }
}

extension HTTPURLResponse {
    func isSuccessful() -> Bool {
        return statusCode >= 200 && statusCode <= 299
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
                .joined(separator: "&")
                .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
