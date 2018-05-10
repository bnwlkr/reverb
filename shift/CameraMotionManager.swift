//
//  CameraMotionManager.swift
//  shift
//
//  Created by Ben Walker on 2018-05-09.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class CameraMotionManager: NSObject, CLLocationManagerDelegate {
    let ROT_THRESH = 0.2
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    var delegate: CameraMotionManagerDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func start () {
        locationManager.startUpdatingHeading()
        motionManager.startGyroUpdates()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if (motionManager.isGyroAvailable) {
            if ((motionManager.gyroData?.rotationRate.y)! < ROT_THRESH) {
                delegate?.takePhoto()
            }
        }
    }
}

protocol CameraMotionManagerDelegate {
    func sample()
}
