//
//  ViewController.swift
//  shift
//
//  Created by Ben Walker on 2018-05-09.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit
import CoreImage

let NUM_IMAGES = 4
let FPS = 15

class CamViewController: UIViewController, CameraDelegate , ShiftConstructorDelegate {

    @IBOutlet weak var top: UIImageView!
    @IBOutlet weak var bottom: UIImageView!
    let camera = Camera()
    let shifter = ShiftConstructor()
    var locked = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.delegate = self
        shifter.delegate = self
        camera.setup()
        top.alpha = 0.6
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
            top.image = shifter.applyFilter(image1: CIImage(image: next)!, filterName: "CIEdges")
            shifter.add(image: next)
        } else {
            shifter.clear()
            camera.start()
            locked = false
        }
    }
    
    
}


