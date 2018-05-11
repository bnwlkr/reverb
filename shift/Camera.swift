//
//  Camera.swift
//  shift
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
    var preview: AVCaptureVideoPreviewLayer?
    var latest: UIImage?
    var delegate: CameraDelegate?
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let image = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            self.latest = image
            self.delegate?.cameraStream(image)
        }
    }
    
    func setup () {
        setupCaptureSession()
        setupDevice()
        setupIO()
        setupPreviewLayer()
    }
    
    func start () {
        session.startRunning()
    }
    
    func stop () {
        session.stopRunning()
    }
    
    func setupCaptureSession() {
        session.sessionPreset = .high
    }
    
    func setupDevice () {
        backCam = AVCaptureDevice.default(for: AVMediaType.video)
    }
    
    func setupIO () {
        do {
            let deviceInput = try AVCaptureDeviceInput(device: backCam!)
            if session.canAddInput(deviceInput) {  session.addInput(deviceInput) }
            if session.canAddOutput(videoOut) { session.addOutput(videoOut) }
            videoOut.setSampleBufferDelegate(self, queue: dataOutputQueue)
            guard let connection = videoOut.connection(with: .video) else { return }
            guard connection.isVideoOrientationSupported else { return }
            guard connection.isVideoMirroringSupported else { return }
            connection.videoOrientation = .portrait

        } catch {print(error)}
    }
    
    func setupPreviewLayer () {
        
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


