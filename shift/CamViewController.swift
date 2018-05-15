//
//  ViewController.swift
//  shift
//
//  Created by Ben Walker on 2018-05-09.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CamViewController: UIViewController, CameraDelegate , ShiftConstructorDelegate {
    @IBOutlet weak var torch: UIButton!
    @IBOutlet weak var exit: UIButton!
    @IBOutlet weak var plus: UIButton!
    @IBOutlet weak var minus: UIButton!
    @IBOutlet weak var top: UIImageView!
    @IBOutlet weak var bottom: UIImageView!
    @IBOutlet weak var frameDisplay: UILabel!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var cameraView: UIView!
    
    
    var stepper: Stepper!
    let camera = Camera()
    let mediaManager = MediaManager()
    let shifter = ShiftConstructor()
    var locked = false
    var torchOn = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.delegate = self
        shifter.delegate = self
        camera.setup(videoView: view)
        stepper = Stepper(incButton: plus, decButton: minus, label: frameDisplay)
        top.alpha = 0.6
        preview.isHidden=true
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
        preview.isHidden=false
        cameraView.isHidden=true
        bottom.image = shifter.display()
        let settings = RenderSettings(fps: 18, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        mediaManager.save(settings: settings, images: shifter.frames)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        camera.focus(touchPoint: touches.first!)
    }

    @IBAction func frameUp(_ sender: UIButton) {
        stepper.increment()
        shifter.frameCount=stepper.value
    }
    
    @IBAction func frameDown(_ sender: UIButton) {
        stepper.decrement()
        shifter.frameCount=stepper.value
    }
    
    @IBAction func exitPreview(_ sender: UIButton) {
        preview.isHidden=true
        cameraView.isHidden=false
        shifter.clear()
        camera.start()
        locked = false
    }
    
 
    @IBAction func switchCam(_ sender: UIButton) {
        camera.switchCam()
    }
    @IBAction func clack(_ sender: UIButton) {
        let next = camera.latest!
        top.image = shifter.applyFilter(image1: CIImage(image: next)!, filterName: "CIEdges")
        shifter.add(image: next)
    }
    
   
    
    
    @IBAction func torch(_ sender: UIButton) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if torchOn==false { device.torchMode = .on
                    torchOn=true
                }
                else {
                    device.torchMode = .off
                    torchOn=false
                }
                device.unlockForConfiguration()
            } catch { print("Torch could not be used") }
        } else { print("Torch is not available") }
    }
    
    
    
    
    
}


