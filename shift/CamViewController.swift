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

class CamViewController: UIViewController , ShiftConstructorDelegate, CameraDelegate {
 
    let clacks = [#imageLiteral(resourceName: "clack0"), #imageLiteral(resourceName: "clack1"), #imageLiteral(resourceName: "clack2"), #imageLiteral(resourceName: "clack3")]
    @IBOutlet weak var torch: UIButton!
    @IBOutlet weak var exit: UIButton!
    @IBOutlet weak var bottom: UIImageView!
    @IBOutlet weak var top: UIImageView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var clack: UIButton!
    var num = 0
    
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
        shifter.delegate = self
        camera.delegate = self
        camera.setup(videoView: view)
        top.alpha = 0.6
        preview.isHidden=true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera.start()
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
    
    func cameraStream(_ image: UIImage) {
        if (!locked) { bottom.image = image }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        camera.focus(touchPoint: touches.first!)
    }
    
    @IBAction func exitPreview(_ sender: UIButton) {
        clack.setImage(clacks[0], for: .normal)
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
        num += 1
        clack.setImage(clacks[num], for: .normal)
        clack.setNeedsDisplay()
        sleep(1)
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


