// I take no credit for the code contained herein. It is an amalgam of SO posts.

import AVFoundation
import UIKit
import Photos

enum Social  {
    case facebook
    case instagram
}

class MediaManager: NSObject, UIDocumentInteractionControllerDelegate {
    func save (settings: RenderSettings, images: [UIImage], orientation: AVCaptureVideoOrientation, completion: @escaping (URL?) -> ()) {
        let imageAnimator = ImageAnimator(renderSettings: settings)
        let rotatedImages = rotateImages(with: orientation, images: images)
        imageAnimator.images = rotatedImages.reflect().repeated(times: 10)
        imageAnimator.save(completion: completion)
    }
    
    func rotateImages (with orientation: AVCaptureVideoOrientation, images: [UIImage]) -> [UIImage] {
        var angle:CGFloat = 0
        var ret = [UIImage]()
        switch(orientation) {
        case .landscapeLeft:
            angle = CGFloat(-Double.pi/2)
        case .landscapeRight:
            angle = CGFloat(Double.pi/2)
        default: break
        }
        for image in images { ret.append(image.rotatedBy(radians: angle)) }
        return ret
    }
}


struct RenderSettings {
    
    init(orientation: AVCaptureVideoOrientation, fps: Int32, outSize: CGSize) {
        self.fps = fps
        switch (orientation) {
        case .portrait:
           self.width = outSize.width
           self.height = outSize.height
        default:
            self.width = outSize.height
            self.height = outSize.width
            
        }
    }
    var fps: Int32!
    var width: CGFloat!
    var height: CGFloat!
    var videoFilename = "render"
    var videoFilenameExt = "mp4"
    var avCodecKey = AVVideoCodecType.h264
    
    var size: CGSize {
        return CGSize(width: width, height: height)
    }
    
    var outputURL: URL {
        let fileManager = FileManager.default
        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return tmpDirURL.appendingPathComponent(videoFilename).appendingPathExtension(videoFilenameExt)
        }
        fatalError("URLForDirectory() failed")
    }
}

class ImageAnimator {
    static let kTimescale: Int32 = 600
    
    let settings: RenderSettings
    let videoWriter: VideoWriter
    var images: [UIImage]!
    
    var frameNum = 0
    
    class func saveToLibrary(videoURL: URL, completion: @escaping (URL?)->()) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            var placeHolder: PHObjectPlaceholder!
            PHPhotoLibrary.shared().performChanges({
                placeHolder = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)?.placeholderForCreatedAsset
            }, completionHandler: {success, error in
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [placeHolder.localIdentifier], options: nil).firstObject
                asset?.getURL(completionHandler: completion)
            })
        }
    }
    
    class func removeFileAtURL(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
        } catch {print(error)}
    }
    
    init(renderSettings: RenderSettings) {
        settings = renderSettings
        videoWriter = VideoWriter(renderSettings: settings)
    }

    
    func save(completion: @escaping (URL?)->Void) {
        ImageAnimator.removeFileAtURL(fileURL: settings.outputURL)
        videoWriter.start()
        videoWriter.render(appendPixelBuffers: appendPixelBuffers) {
            ImageAnimator.saveToLibrary(videoURL: self.settings.outputURL, completion:  completion)
        }
        
    }
    
    func appendPixelBuffers(writer: VideoWriter) -> Bool {
        
        let frameDuration = CMTimeMake(Int64(ImageAnimator.kTimescale / settings.fps), ImageAnimator.kTimescale)
        
        while !images.isEmpty {
            
            if writer.isReadyForData == false {
                // Inform writer we have more buffers to write.
                return false
            }
            let image = images.removeFirst()
            let presentationTime = CMTimeMultiply(frameDuration, Int32(frameNum))
            let success = videoWriter.addImage(image: image, withPresentationTime: presentationTime)
            if success == false {
                fatalError("addImage() failed")
            }
            
            frameNum+=1
        }
        return true
    }
    
}

class VideoWriter {
    
    let renderSettings: RenderSettings
    var videoWriter: AVAssetWriter!
    var videoWriterInput: AVAssetWriterInput!
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!
    
    var isReadyForData: Bool {
        return videoWriterInput?.isReadyForMoreMediaData ?? false
    }
    
    class func pixelBufferFromImage(image: UIImage, pixelBufferPool: CVPixelBufferPool, size: CGSize) -> CVPixelBuffer {
        
        var pixelBufferOut: CVPixelBuffer?
        
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &pixelBufferOut)
        if status != kCVReturnSuccess {
            fatalError("CVPixelBufferPoolCreatePixelBuffer() failed")
        }
        let pixelBuffer = pixelBufferOut!
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        context!.clear(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let horizontalRatio = size.width / image.size.width
        let verticalRatio = size.height / image.size.height
        let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit
        let newSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        let x = newSize.width < size.width ? (size.width - newSize.width) / 2 : 0
        let y = newSize.height < size.height ? (size.height - newSize.height) / 2 : 0
        context!.draw(image.cgImage!, in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
    
    init(renderSettings: RenderSettings) {
        self.renderSettings = renderSettings
    }
    
    func start() {
        
        let avOutputSettings: [String: Any] = [
            AVVideoCodecKey: renderSettings.avCodecKey,
            AVVideoWidthKey: NSNumber(value: Float(renderSettings.width)),
            AVVideoHeightKey: NSNumber(value: Float(renderSettings.height))
        ]
        
        func createPixelBufferAdaptor() {
            let sourcePixelBufferAttributesDictionary = [
                kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.width)),
                kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.height))
            ]
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput,
                                                                      sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        }
        
        func createAssetWriter(outputURL: URL) -> AVAssetWriter {
            guard let assetWriter = try? AVAssetWriter(url: outputURL, fileType: .mp4) else {
                fatalError("AVAssetWriter() failed")
            }
            
            guard assetWriter.canApply(outputSettings: avOutputSettings, forMediaType: AVMediaType.video) else {
                fatalError("canApplyOutputSettings() failed")
            }
            
            return assetWriter
        }
        
        videoWriter = createAssetWriter(outputURL: renderSettings.outputURL)
        videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: avOutputSettings)
        
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }
        else {
            fatalError("canAddInput() returned false")
        }
        createPixelBufferAdaptor()
        if videoWriter.startWriting() == false {
            fatalError("startWriting() failed")
        }
        videoWriter.startSession(atSourceTime: kCMTimeZero)
        precondition(pixelBufferAdaptor.pixelBufferPool != nil, "nil pixelBufferPool")
    }
    
    func render(appendPixelBuffers: @escaping (VideoWriter)->Bool, completion: @escaping ()->Void) {
        
        precondition(videoWriter != nil, "Call start() to initialze the writer")
        
        let queue = DispatchQueue(label: "mediaInputQueue")
        videoWriterInput.requestMediaDataWhenReady(on: queue) {
            let isFinished = appendPixelBuffers(self)
            if isFinished {
                self.videoWriterInput.markAsFinished()
                self.videoWriter.finishWriting() {
                    DispatchQueue.main.async() {
                        completion()
                    }
                }
            }
            else {}
        }
    }
    
    func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
        precondition(pixelBufferAdaptor != nil, "Call start() to initialze the writer")
        let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, pixelBufferPool: pixelBufferAdaptor.pixelBufferPool!, size: renderSettings.size)
        return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }
}




