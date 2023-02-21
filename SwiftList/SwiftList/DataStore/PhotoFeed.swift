//
//  PhotoFeed.swift
//  SwiftList
//
//  Created by Alok Irde on 2/20/23.
//

import Combine
import Collections
import Foundation

class PhotoFeed: ObservableObject {
    static let shared = PhotoFeed()
    let networkInteractor = NetworkInteractor()
    private init() {}
    private var photos = [Photo]() {
        didSet {
            var newDict = OrderedDictionary<PhotoVM.ID, PhotoVM>()
            for p in photos {
                newDict[p.id] = p.convertToViewModel()
            }
            photoViewModels = newDict
        }
    }

    @Published private(set) var photoViewModels = OrderedDictionary<PhotoVM.ID, PhotoVM>()

    func load() async {
        guard let photos = try? await networkInteractor.fetch(.photos) as? [Photo] else {
            return
        }
        self.photos = photos
    }
}
