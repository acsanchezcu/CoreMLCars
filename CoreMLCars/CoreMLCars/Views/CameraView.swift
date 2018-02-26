//
//  CameraView.swift
//  CoreMLCars
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 26/02/2018.
//  Copyright © 2018 acsanchezcu. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewDelegate {
    func cameraView(cameraView: CameraView, pixelBuffer: CVPixelBuffer)
}

class CameraView: UIView {

    // MARK: - Properties

    var delegate: CameraViewDelegate?
    
    private lazy var session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard let captureDevice = AVCaptureDevice.default(for: .video),
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return session }
        
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        return session
    }()
    
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = {
        let cameraLayer = AVCaptureVideoPreviewLayer(session: self.session)

        cameraLayer.videoGravity = .resizeAspectFill
        
        return cameraLayer
    }()
    
    // MARK: - Override
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update the frame of the layer
        cameraLayer.frame = frame
    }
    
    // MARK: - Init
    
    init(delegate: CameraViewDelegate) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        
        layer.addSublayer(cameraLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func startSession() {
        session.startRunning()
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    func changeOrientation(_ orientation: UIDeviceOrientation) {
        switch orientation {
        case .portrait:
            cameraLayer.connection?.videoOrientation = .portrait
        case .landscapeLeft:
            cameraLayer.connection?.videoOrientation = .landscapeRight
        case .landscapeRight:
            cameraLayer.connection?.videoOrientation = .landscapeLeft
        default:
            cameraLayer.connection?.videoOrientation = .portraitUpsideDown
        }
    }
}

extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate
{
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        delegate?.cameraView(cameraView: self, pixelBuffer: pixelBuffer)
    }
    
}
