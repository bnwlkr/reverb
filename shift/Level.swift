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
    let maxDiff = 0.5
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.maxWidth = frame.width/2.0
    }
    
    func start () {
        firstRefUpdate=true
       motion.deviceMotionUpdateInterval = 0.5
        motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {motion, error in
            let roll = motion!.attitude.roll
            if self.firstRefUpdate {
                self.ref=motion!.attitude.roll
                self.firstRefUpdate=false
            }
            else {
                let diff = min(self.maxDiff, self.ref-roll)
                let perc = diff/self.maxDiff
                
                if perc > 0.0 {
                    self.frame = CGRect(x: UIScreen.main.bounds.width/2, y: self.bounds.maxY, width: self.maxWidth*CGFloat(perc), height: self.frame.height)
                } else {
                    
                }
                
                
                
                
                
            }
        })
       
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

}
