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

class CamViewController: UIViewController , ShiftConstructorDelegate, CameraDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var torch: UIButton!
    @IBOutlet weak var bottom: UIImageView!
    @IBOutlet weak var top: UIImageView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var clack: UIButton!
    let camera = Camera()
    let mediaManager = MediaManager()
    let shifter = ShiftConstructor()
    var numFrames = 0
    var locked = false
    var torchOn = false
    let clacks = [#imageLiteral(resourceName: "shift0"), #imageLiteral(resourceName: "shift1"), #imageLiteral(resourceName: "shift2"), #imageLiteral(resourceName: "shift3")]
    
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
        setButtonShadows()
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
    }
    
    func cameraStream(_ image: UIImage) {
        if (!locked) { bottom.image = image }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        camera.focus(touchPoint: touches.first!)
    }
    
    @IBAction func exitPreview(_ sender: UIButton) {
        if (torchOn) {
            torchOn=false
            torch(nil)
        }
        numFrames=0
        clack.setImage(clacks[0], for: .normal)
        preview.isHidden=true
        cameraView.isHidden=false
        shifter.clear()
        camera.start()
        locked = false
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
 
    @IBAction func switchCam(_ sender: UIButton) {
        camera.switchCam()
    }
    
    @IBAction func clack(_ sender: UIButton) {
        numFrames += 1
        clack.setImage(clacks[numFrames], for: .normal)
        let next = camera.latest!
        top.image = shifter.applyFilter(image1: CIImage(image: next)!, filterName: "CIEdges")
        delay(0.001, closure: {self.shifter.add(image: next)})
    }
    
    @IBAction func share(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            mediaManager.storeForSharing(to: .instagram, images: shifter.frames, completion: {
                url in
                let instagramController = UIDocumentInteractionController.init(url: url)
                instagramController.uti = "com.instagram.exclusivegram"
                instagramController.delegate = self
                instagramController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
            })
        case 1:
            break
        default:
            break
        }
    }
    
    @IBAction func save(_ sender: Any) {
        let settings = RenderSettings(fps: Int32(FPS), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, url: URL(fileURLWithPath: "fuckoff"))
        mediaManager.save(settings: settings, images: shifter.frames)
    }
    
    @IBAction func torch(_ sender: UIButton?) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if torchOn==false { device.torchMode = .on
                    torch.setImage(#imageLiteral(resourceName: "flashon"), for: .normal)
                    torchOn=true
                }
                else {
                    device.torchMode = .off
                    torch.setImage(#imageLiteral(resourceName: "flash"), for: .normal)
                    torchOn=false
                }
                device.unlockForConfiguration()
            } catch { print("Torch could not be used") }
        } else { print("Torch is not available") }
    }
    
    func setButtonShadows  () {
        for button in buttons {
            button.layer.shadowOpacity = 0.2
            button.layer.shadowRadius = 0.8
        }
    }
    
    
    
    
    
}


