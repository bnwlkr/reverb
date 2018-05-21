//
//  Level.swift
//  shift
//
//  Created by Ben Walker on 2018-05-17.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit
import CoreMotion

class Level: UIView {
    let motion = CMMotionManager()
    var firstRefUpdate: Bool!
    var ref: Double!
    var maxWidth: CGFloat!
    let maxDiff = 1.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.maxWidth = frame.width/2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func start () {
        firstRefUpdate=true
        motion.deviceMotionUpdateInterval = 0.5
        motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {motion, error in
            if let roll = motion?.attitude.roll {
                if self.firstRefUpdate {
                    self.ref=roll
                    self.firstRefUpdate=false
                }
                else {
                    let diff = roll-self.ref
                    let diffNorm = min(max(diff, -self.maxDiff), self.maxDiff)
                    print (diffNorm)
                }
            }
        })
    }

}
