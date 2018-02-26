//
//  CoreMLApi.swift
//  CoreMLCars
//
//  Created by Sanchez Custodio, Abel (Cognizant) on 26/02/2018.
//  Copyright © 2018 acsanchezcu. All rights reserved.
//

import Foundation
import AVFoundation
import CoreMedia
import UIKit

struct CoreMLApi {
    
    // MARK: - Properties
    
    private let model = CarRecognition()
    
    // Data size to be recognized by model
    private let size = CGSize(width: 224, height: 224)
    
    // MARK: - Public methods
    
    func prediction(pixelBuffer: CVPixelBuffer) -> (String,Double)? {
        // Fix the orientation of the pixelBuffer
        let fixedImage = UIImage(pixelBuffer: pixelBuffer)?.fixedOrientation()

        guard let pixelBuffer = fixedImage?.pixelBuffer(),
            let resizePixelBuffer = resizePixelBuffer(pixelBuffer, width: Int(size.width), height: Int(size.height)),
            let prediction = try? model.prediction(data: resizePixelBuffer),
            let max = prediction.prob.values.max(),
            let key = prediction.prob.keysForValue(value: max).first else { return nil }
        
        return (key, max)
    }
}
