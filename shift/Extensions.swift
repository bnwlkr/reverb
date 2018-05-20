//
//  Extensions.swift
//  shift
//
//  Created by Ben Walker on 2018-05-12.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import Foundation
import UIKit
import Photos



extension Array {
    func reflect () -> Array<Element> {
        var ret = Array<Element>()
        ret.append(contentsOf: self)
        for i in (0..<self.count).reversed() {
            ret.append(self[i])
        }
        return ret
    }
    
    func repeated (times: Int) -> Array<Element> {
        var ret = Array<Element>()
        for _ in 0..<times {
            ret.append(contentsOf: self)
        }
        return ret
    }
}

extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}

extension UIView {
    func rotate (to: UIDeviceOrientation) {
        UIView.animate(withDuration: 0.5, animations: {
            var angle: CGFloat = 0.0
            switch (to) {
            case .landscapeLeft:
                angle = CGFloat(Double.pi/2);
            case .landscapeRight:
                angle = CGFloat(-Double.pi/2);
            default:
                angle = 0.0
            }
            self.transform = CGAffineTransform(rotationAngle: angle)
        })
    }
}

extension UIImage {
    func imageRotatedByDegrees(radians: CGFloat) -> UIImage {
        
        let rotatedViewBox = UIView(frame: CGRect(x: 0,y: 0, width: self.size.width, height: self.size.height))
        rotatedViewBox.transform = CGAffineTransform(rotationAngle: radians)
        let rotatedSize = rotatedViewBox.frame.size
        
        UIGraphicsBeginImageContext(rotatedViewBox.frame.size)
        let bitmap = UIGraphicsGetCurrentContext()!
        
        bitmap.translateBy(x: rotatedSize.width, y: rotatedSize.height)
        bitmap.rotate(by: radians)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        
        return newImage
    }
}



extension PHAsset {
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

