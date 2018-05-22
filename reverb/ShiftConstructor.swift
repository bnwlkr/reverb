//
//  ShiftConstructor.swift
//  reverb
//
//  Created by Ben Walker on 2018-05-10.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit
import CoreImage



class ShiftConstructor: NSObject {
    var frames = [UIImage]()
    var delegate: ShiftConstructorDelegate?
    let context = CIContext()
    let frameCount = 3
    let fps: Int32 = 18
    
    func add(image: UIImage) {
        frames.append(image)
        if (frames.count == frameCount) {
            delegate?.reverbConstructorFull()
        }
    }

    func clear () {
        frames.removeAll()
    }
    
    func display () -> UIImage  {
        let duration = Double(frameCount*2)/Double(fps)
        return UIImage.animatedImage(with: frames.reflect(), duration: duration)!
    }
    
    func topMap (image: CIImage) -> UIImage {
        let filter1 = CIFilter(name: "CIEdges")
        let filter2 = CIFilter(name: "CIColorMonochrome")
        filter1?.setValue(image, forKey: kCIInputImageKey)
        let result1 = (filter1?.outputImage)!
        filter2?.setValue(result1, forKey: kCIInputImageKey)
        filter2?.setValue(CIColor(red: 255, green: 255, blue: 255), forKey: kCIInputColorKey)
        let result2 = (filter2?.outputImage)!
        let cgImage = context.createCGImage(result2, from: result2.extent)
        return UIImage(cgImage: cgImage!)
    }

}

protocol ShiftConstructorDelegate {
    func reverbConstructorFull ()
}


