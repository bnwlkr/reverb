//
//  Extensions.swift
//  shift
//
//  Created by Ben Walker on 2018-05-12.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import Foundation
import UIKit


extension CountableClosedRange {
    func topEdge (value: Bound) -> Bool {
        return value==self.upperBound
    }
    func bottomEdge (value: Bound) -> Bool {
        return value==self.lowerBound
    }
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
    
    func repeated (times: Int) -> Array<Element> {
        var ret = Array<Element>()
        for _ in 0..<times {
            ret.append(contentsOf: self)
        }
        return ret
    }
}


