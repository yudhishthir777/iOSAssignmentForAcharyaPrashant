//
//  ImageCache.swift
//  iOS Assignment
//
//  Created by Yudhishthir Singh Rathore on 22/04/24.
//

import Foundation
import UIKit

class ImageCache {
    
    static let shared = ImageCache()
    
    func set(image: UIImage, key: String) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            return
        }
        cacheImage(data: data, key: key)
    }
    
    func cacheImage(data: Data, key: String) {
        let fileURL = cacheFileUrl(key)
        do {
            try data.write(to: fileURL, options: Data.WritingOptions.atomic)
        } catch let error {
            print("Error write file \(error.localizedDescription)")
        }
    }
    
    
    func cacheFileUrl(_ fileName: String) -> URL {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cacheURL.appendingPathComponent(fileName)
    }
    
    func getImage(of key: String) -> UIImage? {
        if let image = kImageInCache.object(forKey: key as NSString) {
            return image
        }
        let fileURL = cacheFileUrl(key)
        do {
            let data = try Data(contentsOf: fileURL)
            let image = UIImage(data: data)
            return image
        } catch {
            print(error)
        }
        return nil
    }
    
}
