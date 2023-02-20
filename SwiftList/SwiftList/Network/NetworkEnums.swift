//
//  NetworkEnums.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import Foundation

enum APIError: Error {
    case URLError
    case remoteUrlUnreachable(error: String)
    case responseError(error: String)
    case unknown
}

indirect enum CallType {
    case photos
    case posts
    case albums(id: Int? = nil, caseType: CallType? = nil)

    var resolvedUrlString: String {
        switch self {
            case .photos:
                return "https://jsonplaceholder.typicode.com/photos"
            case .posts:
                return "https://jsonplaceholder.typicode.com/posts"
            case .albums(let id, let callType):
                if case .photos = callType, let id = id {
                    return "https://jsonplaceholder.typicode.com/albums/\(id.self)/photos"
                } else {
                    return "https://jsonplaceholder.typicode.com/albums"
                }
        }
    }
}
