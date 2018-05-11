//
//  ShiftConstructor.swift
//  shift
//
//  Created by Ben Walker on 2018-05-10.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit
import CoreFoundation
import MobileCoreServices

class ShiftConstructor: NSObject {
    private var images = [UIImage]()
    var delegate: ShiftConstructorDelegate?
    
    func add(image: UIImage) {
        images.append(image)
        if (images.count == NUM_IMAGES) {
            delegate?.shiftConstructorFull()
        }
    }

    func clear () {
        images.removeAll()
    }
    
    func display () -> UIImage  {
        let duration = Double(NUM_IMAGES*2)/Double(FPS)
        return UIImage.animatedImage(with: images.reflect(), duration: duration)!
    }
}

protocol ShiftConstructorDelegate {
    func shiftConstructorFull ()
}

extension Array {
    func reflect () -> Array<Element> {
        var ret = Array<Element>()
        ret.append(contentsOf: self)
        for i in (0..<self.count).reversed() {
            ret.append(self[i])
        }
        return ret
    }
}
