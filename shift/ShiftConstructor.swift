//
//  ShiftConstructor.swift
//  shift
//
//  Created by Ben Walker on 2018-05-10.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit
import CoreImage

class ShiftConstructor: NSObject {
    let FPS = 16
    var frames = [UIImage]()
    var delegate: ShiftConstructorDelegate?
    let context = CIContext()
    var frameCount = 4
    
    func add(image: UIImage) {
        frames.append(image)
        if (frames.count == frameCount) {
            delegate?.shiftConstructorFull()
        }
    }

    func clear () {
        frames.removeAll()
    }
    
    func display () -> UIImage  {
        let duration = Double(frameCount*2)/Double(FPS)
        return UIImage.animatedImage(with: frames.reflect(), duration: duration)!
    }
    
    func applyFilter (image1: CIImage, filterName: String) -> UIImage {
        let filter = CIFilter(name: filterName)
        filter?.setValue(image1, forKey: kCIInputImageKey)
        let result = (filter?.outputImage)!
        let cgImage = context.createCGImage(result, from: result.extent)
        return UIImage(cgImage: cgImage!)
    }
}

protocol ShiftConstructorDelegate {
    func shiftConstructorFull ()
}


