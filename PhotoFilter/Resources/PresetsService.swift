//
//  Presets.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 25.03.2021.
//

import UIKit
import CoreImage
import RxSwift
import RxCocoa

class PresetsService {
    static let shared = PresetsService()
    private var context: CIContext
    
    init() {
        self.context = CIContext()
    }
    
    func applyPresets(to inputImage: UIImage, presets: Presets) -> Observable<UIImage> {
        
        return Observable<UIImage>.create {[weak self] observer in
            self?.presetsFilter(inputImage: inputImage, presets: presets, completion: {image in
                observer.onNext(image)
            })
            return Disposables.create()
        }
    }
    
    
    private func presetsFilter(inputImage: UIImage, presets: Presets, completion: @escaping ((UIImage) ->())) {
        guard let filter = CIFilter(name: presets.preset.presetsName) else {return}
        
        if let sourceImage = CIImage(image: inputImage) {
            filter.setValue(sourceImage, forKey: kCIInputImageKey)
            if let cgImg = context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
                let processedImage = UIImage(cgImage: cgImg, scale: inputImage.scale, orientation: inputImage.imageOrientation)
               completion(processedImage)
            }
        }
    }
}
