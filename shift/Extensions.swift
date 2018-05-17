//
//  Extensions.swift
//  shift
//
//  Created by Ben Walker on 2018-05-12.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import Foundation
import UIKit


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

