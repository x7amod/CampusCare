//
//  ImageCacheManager.swift
//  CampusCare
//
//  Created on 27/12/2025.
//

import UIKit

/// Manages image caching using NSCache for memory-efficient image storage
final class ImageCacheManager {
    
    // MARK: - Singleton
    
    static let shared = ImageCacheManager()
    
    // MARK: - Properties
    
    private let cache = NSCache<NSString, UIImage>()
    private let session: URLSession
    
    // MARK: - Initializer
    
    private init() {
        // Configure cache limits
        cache.countLimit = 100 // Max 100 images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
        
        // Configure URL session
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    
    /// Retrieve image from cache
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    /// Store image in cache
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    /// Download image from URL, check cache first
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = image(forKey: urlString) {
            print("[ImageCache] ✅ Cache hit for: \(urlString)")
            completion(cachedImage)
            return
        }
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            print("[ImageCache] ❌ Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        print("[ImageCache] 📡 Downloading image from: \(urlString)")
        
        // Download image
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("[ImageCache] ❌ Download error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("[ImageCache] ❌ Failed to create image from data")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the downloaded image
            self?.setImage(image, forKey: urlString)
            print("[ImageCache] ✅ Downloaded and cached image")
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
        
        task.resume()
    }
    
    /// Clear all cached images
    func clearCache() {
        cache.removeAllObjects()
        print("[ImageCache] 🗑️ Cache cleared")
    }
}
