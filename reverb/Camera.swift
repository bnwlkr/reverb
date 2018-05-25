//
//  Camera.swift
//  reverb
//
//  Created by Ben Walker on 2018-05-09.
//  Copyright © 2018 Ben Walker. All rights reserved.
//

import UIKit
import AVFoundation

class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    

    let session = AVCaptureSession()
    let context = CIContext()
    let videoOut = AVCaptureVideoDataOutput()
    let dataOutputQueue = DispatchQueue(label: "video data queue",
                                        qos: .userInitiated,
                                        attributes: [],
                                        autoreleaseFrequency: .workItem)
    var backCam: AVCaptureDevice?
    var frontCam: AVCaptureDevice?
    var currentCam: AVCaptureDevice?
    var latest: UIImage?
    var delegate: CameraDelegate?
    var videoView: UIView!
    var orientationLock = false
    var _outputSize: CGSize?
    var outputSize: CGSize? {
        set {
        if _outputSize == nil { _outputSize=newValue }
        }
        get { return _outputSize }
    }
    private var _orientation: AVCaptureVideoOrientation!
    var orientation: AVCaptureVideoOrientation! {
        set {
            if orientationLock {return}
            _orientation = newValue
        } get { return _orientation }
    }
    

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            self.latest = image
            self.delegate?.cameraStream(image)
        }

    }
    
    func setup (videoView: UIView) {
        self.videoView = videoView
        setupCaptureSession()
        setupDevices()
        setupIO(device: currentCam!)
    }
    
    func start () {
        session.startRunning()
    }
    
    func stop () {
        session.stopRunning()
    }
    
    func switchCam () {
        session.removeInput(session.inputs[0])
        if currentCam?.position == .back {
            currentCam = frontCam
        } else {
            currentCam = backCam
        }
        do {
            session.addInput(try AVCaptureDeviceInput(device: currentCam!))
            setupConnection(mode: currentCam!.position)
        } catch {print(error)}
    }
    
    func setOrientation () {
        switch (UIDevice.current.orientation) {
        case .portrait:
            orientation = .portrait
        case .landscapeLeft:
            orientation = .landscapeLeft
        case .landscapeRight:
            orientation = .landscapeRight
        default:
            orientation = .portrait
        }
    }
    
    
    func setupCaptureSession() {
        session.sessionPreset = .high
        
    }
    
    func setupDevices () {
        let disc = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        for device in disc.devices {
            if device.position == .front {
                frontCam = device
            } else if device.position == .back {
                backCam = device
            }
        }
        currentCam = backCam // default
    }
    
    func setupConnection (mode: AVCaptureDevice.Position) {
        let connection = videoOut.connection(with: .video)!
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        if mode == .front { connection.isVideoMirrored=true }
        connection.videoOrientation = .portrait
    }
    



    func setupIO (device: AVCaptureDevice) {
        do {
            let deviceInput = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(deviceInput) {  session.addInput(deviceInput) }
            if session.canAddOutput(videoOut) { session.addOutput(videoOut) }
            videoOut.setSampleBufferDelegate(self, queue: dataOutputQueue)
            setupConnection(mode: device.position)
        } catch {print(error)}
    }

    func focus (touchPoint: UITouch) {
        let screenSize = videoView.bounds.size
        let x = touchPoint.location(in: videoView).y / screenSize.height
        let y = 1.0 - touchPoint.location(in: videoView).x / screenSize.width
        let focusPoint = CGPoint(x: x, y: y)

        if let device = backCam {
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            }
            catch {print(error)}
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
}

protocol  CameraDelegate {
    func cameraStream (_ image: UIImage)
}


