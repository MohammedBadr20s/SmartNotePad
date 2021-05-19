//
//  UIImage+Extension.swift
//  SmartNotePad
//
//  Created by GoKu on 19/05/2021.
//

import UIKit
extension UIImage {
    func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        if let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) {
            let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
            
            let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                      kCGImageSourceShouldCacheImmediately: false,
                                      kCGImageSourceCreateThumbnailWithTransform: true,
                                      kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary

            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) else { return #imageLiteral(resourceName: "image")}
            
            return UIImage(cgImage: downsampledImage)
        } else {
            return #imageLiteral(resourceName: "icons8-full_image")
        }
        
        
    }
}
func deleteImageFromLocal(imageName: String) {
    if imageName != "" {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
            
        }
    }
    
}
