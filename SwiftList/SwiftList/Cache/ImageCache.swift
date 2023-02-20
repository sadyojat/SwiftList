//
//  ImageCache.swift
//  SwiftList
//
//  Created by Alok Irde on 2/19/23.
//

import Foundation
import UIKit

class ImageCache {

    let cache = NSCache<NSString, UIImage>()

    func image(for key: NSString) -> UIImage? {
        cache.object(forKey: key)
    }

    func setImage(_ image: UIImage, for key: NSString) {
        cache.setObject(image, forKey: key)
    }
}
