//
//  ImageCache.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import Foundation
import UIKit

class ImageCache {

    static let shared = ImageCache()

    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    func image(for key: String) async -> UIImage? {
        if let image = cache.object(forKey: key as NSString) {
            return image
        } else {
            return await downloadImage(from: key)
        }
    }

    func setImage(_ image: UIImage, for key: NSString) {
        cache.setObject(image, forKey: key)
    }

    private func downloadImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data)
                else {
            return nil
        }
        ImageCache.shared.setImage(image, for: urlString as NSString)
        return image
    }
}
