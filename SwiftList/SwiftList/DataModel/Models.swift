//
//  Post.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import Foundation

struct Post: DataModelProtocol {
    let userId: Int
    var id: Int
    var title: String
    var body: String
    var isFavorite: Bool? = false
    var isMarkedForDeletion: Bool? = false
}


struct Photo: DataModelProtocol {
    let albumId: Int
    var id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
    var isFavorite: Bool? = false
}


struct Album: DataModelProtocol {
    let id: Int
    let userId: Int
    let title: String
}
