//
//  ViewController.swift
//  shift
//
//  Created by Ben Walker on 2018-05-09.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit


let SAMPLE_INTERVAL = 0.1
let NUM_IMAGES = 5
let FPS = 20

class CamViewController: UIViewController, CameraDelegate , ShiftConstructorDelegate {

    @IBOutlet weak var top: UIImageView!
    @IBOutlet weak var bottom: UIImageView!
    let camera = Camera()
    let shifter = ShiftConstructor()
    var locked = false
    @IBOutlet weak var test: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.delegate = self
        shifter.delegate = self
        camera.setup()
        top.alpha = 0.3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera.start()
    }
    
    func cameraStream(_ image: UIImage) {
        if (!locked) { bottom.image = image }
    }
    
    func shiftConstructorFull () {
        camera.stop()
        locked = true
        top.image = nil
        bottom.image = shifter.display()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!locked) {
            let next = camera.latest!
            top.image = next
            shifter.add(image: next)
        } else {
            shifter.clear()
            camera.start()
            locked = false
        }
    }
    
}

