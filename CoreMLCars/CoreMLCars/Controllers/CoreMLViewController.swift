//
//  CoreMLViewController.swift
//  CoreMLCars
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 26/02/2018.
//  Copyright © 2018 acsanchezcu. All rights reserved.
//

import UIKit
import AVFoundation

class CoreMLViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var predictionLabel: UILabel!
    
    // MARK: - Properties
    
    private let coremlApi = CoreMLApi()
    private var cameraView: CameraView?
    
    // MARK: - Override
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let cameraView = cameraView else { return }
        
        cameraView.changeOrientation(UIDevice.current.orientation)
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCameraView()
    }
    
    // MARK: - Private Methods
    
    private func setupCameraView() {
        let cameraView = CameraView(delegate: self)
        
        view.addSubview(cameraView)
        
        view.sendSubview(toBack: cameraView)
        
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        cameraView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        cameraView.startSession()
        
        self.cameraView = cameraView
    }

    private func prediction(for pixelBuffer: CVPixelBuffer) {
        guard let data = coremlApi.prediction(pixelBuffer: pixelBuffer) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.predictionLabel?.text = "\(data.0)\n\(data.1)"
        }
    }
}

// MARK: - CameraViewDelegate

extension CoreMLViewController: CameraViewDelegate {
    
    func cameraView(cameraView: CameraView, pixelBuffer: CVPixelBuffer) {
        prediction(for: pixelBuffer)
    }
}
