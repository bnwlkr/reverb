//
//  ViewController.swift
//  shift
//
//  Created by Ben Walker on 2018-05-09.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit

class CamViewController: UIViewController, MotionManagerDelegate, CameraDelegate {
    @IBOutlet weak var imageView: UIImageView!
    
    let motion = MotionManager()
    let camera = Camera()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        motion.delegate = self
        camera.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera.start()
        motion.start()
    }

    func motionManagerSample() {
        //imageView.image = camera.latestImage
    }
    func test(_ image: UIImage) {
        imageView.image = image
    }
    
}

