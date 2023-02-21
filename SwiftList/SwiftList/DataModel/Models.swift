//
//  Post.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import Foundation
import UIKit

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

    func convertToViewModel() -> PhotoVM {
        PhotoVM(
            albumId: self.albumId,
            id: self.id,
            title: self.title,
            url: self.url,
            thumbnailUrl: self.thumbnailUrl
        )
    }
}

class PhotoVM: Identifiable {
    let networkInteractor = NetworkInteractor()
    // data model information
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String

    // view state information
    var thumbnailImage: UIImage?
    private (set) var image: UIImage?

    init(albumId: Int, id: Int, title: String, url: String, thumbnailUrl: String,
         thumbnailImage: UIImage? = nil, image: UIImage? = nil) {
        self.albumId = albumId
        self.id = id
        self.title = title
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.thumbnailImage = thumbnailImage
        self.image = image
    }
}

struct Album: DataModelProtocol {
    let id: Int
    let userId: Int
    let title: String
}
