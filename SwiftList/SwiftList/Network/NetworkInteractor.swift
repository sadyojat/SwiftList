//
//  NetworkInteractor.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import Foundation

class NetworkInteractor {

    func fetch(_ type: CallType) async throws -> [any DataModelProtocol] {
        guard let url = URL(string: type.resolvedUrlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        switch type {
            case .posts:
                return try JSONDecoder().decode([Post].self, from: data)
            case .photos:
                return try JSONDecoder().decode([Photo].self, from: data)
            case .albums(_, let callType):
                if case .photos = callType {
                    return try JSONDecoder().decode([Photo].self, from: data)
                } else {
                    return try JSONDecoder().decode([Album].self, from: data)
                }
        }
    }
    
}
