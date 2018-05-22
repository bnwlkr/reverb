//
//  Level.swift
//  reverb
//
//  Created by Ben Walker on 2018-05-17.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit
import CoreMotion

class Level: NSObject {
    let motion = CMMotionManager()
    let greenRange = -0.1...0.1
    var view: UIImageView!
    
    convenience init(imageView: UIImageView) {
        self.init()
        self.view = imageView
    }
    
    
    func start () {
        motion.deviceMotionUpdateInterval = 0.1
        motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: {motion, error in
            var met: Double = 0.0
            switch (UIDevice.current.orientation) {
            case .landscapeLeft:
                met = (motion?.attitude.pitch)! + Double.pi/2
            case .landscapeRight:
                met = (motion?.attitude.pitch)! - Double.pi/2
            default:
                met = (motion?.attitude.roll)!
            }
            
            DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.view.transform = CGAffineTransform(rotationAngle: CGFloat(met))
                    })
                }
            var rangeMet: Double = 0.0
            switch (UIDevice.current.orientation) {
                case .landscapeLeft:
                     rangeMet = met-Double.pi/2
                case .landscapeRight:
                    rangeMet = met+Double.pi/2
                default:
                    rangeMet = met
            }
            if self.greenRange ~= rangeMet {
                self.view.image = #imageLiteral(resourceName: "levelgreen")
            } else {
                self.view.image = #imageLiteral(resourceName: "levelred")
            }
        })
    }

}
