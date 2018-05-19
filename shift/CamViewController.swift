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
    
    

    @IBOutlet weak var savingView: UIActivityIndicatorView!
    @IBOutlet weak var focusView: UIImageView!
    @IBOutlet weak var savedView: UIVisualEffectView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var torch: UIButton!
    @IBOutlet weak var bottom: UIImageView!
    @IBOutlet weak var top: UIImageView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var clack: UIButton!
    var activityView: UIActivityViewController!
    let camera = Camera()
    let mediaManager = MediaManager()
    let shifter = ShiftConstructor()
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
        savingView.stopAnimating()
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
        focusView.center = touches.first!.location(in: cameraView)
        UIView.animate(withDuration: 0.2, animations: {
            self.focusView.alpha=1.0
        }) {_ in
            UIView.animate(withDuration: 0.5, animations: {
                self.focusView.alpha=0.0
            })
        }
    }
    
    @IBAction func exitPreview(_ sender: UIButton) {
        if (torchOn) {
            torchOn=false
            torch(nil)
        }
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
        clack.setImage(clacks[shifter.frames.count+1], for: .normal)
        let next = camera.latest!
        top.image = shifter.applyFilter(image1: CIImage(image: next)!, filterName: "CIEdges")
        delay(0.001, closure: {self.shifter.add(image: next)})
    }
    
    @IBAction func share(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            _save(completion: { url in
                self.displaySaved({
                if let path = url {
                    let assetPath: String = path.path
                    let instaPath = "instagram://library?AssetPath=" + assetPath
                    let instaPathURL = URL(string: instaPath)!
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(instaPathURL) {
                            UIApplication.shared.open(instaPathURL)
                        } else {
                            UIApplication.shared.open(URL(string: "https://www.instagram.com")!)
                        }
                    }
                }
                }, true)
            })
            
            break
        case 1:
            _save(completion: { url in
                self.displaySaved({
                let fbPath = URL(string: "fb://profile")
                    DispatchQueue.main.async {
                        if UIApplication.shared.canOpenURL(fbPath!) {
                            UIApplication.shared.open(fbPath!)
                        } else {
                            UIApplication.shared.open(URL(string: "https://www.facebook.com")!)
                        }
                    }
                }, true)
                })
            
        default:
            break
        }
    }
    
    func _save(completion: @escaping (URL?)->()) {
        savingView.startAnimating()
        let settings = RenderSettings(fps: Int32(FPS), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        mediaManager.save(settings: settings, images: shifter.frames, completion: completion)
    }
    
    @IBAction func save(_ sender: Any) {
        _save(completion: {_ in
            self.displaySaved({}, false)
        })
    }
    
    
    func displaySaved (_ completion: @escaping ()->(), _ share: Bool) {
        DispatchQueue.main.async {
            self.savingView.stopAnimating()
            UIView.animate(withDuration: 0.5, animations: {
                self.savedView.alpha=1.0
            }) {_ in
                if share {
                    self.savedView.alpha=0
                    completion()
                } else {
                    UIView.animate(withDuration: 2.0, animations: {
                        self.savedView.alpha=0.0
                    })
                }
            }
            
        }
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


