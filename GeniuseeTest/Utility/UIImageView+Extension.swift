//
//  ImageLoader.swift
//  GeniuseeTest
//
//  Created by Alina Bohuslavska on 24.06.2020.
//  Copyright © 2020 Alina Bohuslavska. All rights reserved.
//

import UIKit

extension UIImageView {
    
    private static var taskKey = 0
    private static var urlKey = 0
    
    private var currentTask: URLSessionTask? {
        get { return objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionTask }
        set { objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var currentURL: URL? {
        get { return objc_getAssociatedObject(self, &UIImageView.urlKey) as? URL }
        set { objc_setAssociatedObject(self, &UIImageView.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func loadImageAsync(with urlString: String?) {
        // cancel prior task, if any
        weak var oldTask = currentTask
        currentTask = nil
        oldTask?.cancel()
        
        // reset imageview's image
        self.image = nil
        
        // allow supplying of `nil` to remove old image and then return immediately
        guard let urlString = urlString else { return }
        
        // check cache
        if let cachedImage = ImageCache.shared.image(forKey: urlString) {
            self.image = cachedImage
            return
        }
        
        // download
        let url = URL(string: urlString)!
        currentURL = url
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.currentTask = nil
            
            //error handling
            if let error = error {
                // don't bother reporting cancelation errors
                if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorCancelled {
                    return
                }
                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else {
                print("unable to extract image")
                return
            }
            
            ImageCache.shared.save(image: downloadedImage, forKey: urlString)
            
            if url == self?.currentURL {
                DispatchQueue.main.async {
                    self?.image = downloadedImage
                }
            }
        }
        
        // save and start new task
        currentTask = task
        task.resume()
    }
    
}
