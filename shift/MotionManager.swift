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

class MotionManager: NSObject, CLLocationManagerDelegate {
    let ROT_THRESH = 0.3
    var locationManager = CLLocationManager()
    var motionManager = CMMotionManager()
    var delegate: MotionManagerDelegate?
    
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
            if (abs((motionManager.gyroData?.rotationRate.y)!) < ROT_THRESH) {
                delegate?.motionManagerSample()
            }
        }
    }
}

protocol MotionManagerDelegate {
    func motionManagerSample()
}
