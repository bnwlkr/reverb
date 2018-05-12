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



