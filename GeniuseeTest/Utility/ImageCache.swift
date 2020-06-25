//
//  ImageCache.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 24.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import UIKit

class ImageCache {
    
    private let cache = NSCache<NSString, UIImage>()
    private var observer: NSObjectProtocol!

    static let shared = ImageCache()

    private init() {
        // make sure to purge cache on memory pressure
        observer = NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { [weak self] notification in
            self?.cache.removeAllObjects()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(observer as Any)
    }

    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func save(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
