//
//  FilterServices.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 9.03.2021.
//

import Foundation
import CoreImage
import UIKit
import RxSwift
import RxCocoa

class FiltersService {
    
    static let shared = FiltersService()
    
    private var context: CIContext
    
    init() {
        self.context = CIContext()
    }
    
    func applyFilter(to inputImage: UIImage, value: Float, filter: Filters) -> Observable<UIImage> {
        
        return Observable<UIImage>.create { observer in
            
            self.applyFilter(to: inputImage, value: value, myFilter: filter) { filteredImage in
                observer.onNext(filteredImage)
            }
            return Disposables.create()
        }
    }
    
    private func applyFilter(to inputImage: UIImage, value: Float, myFilter: Filters, completion: @escaping ((UIImage) -> ())) {
        
        let filter = CIFilter(name: myFilter.filterName)!
        filter.setValue(value, forKey: myFilter.filterKey)
        
        if let sourceImage = CIImage(image: inputImage) {
            
            filter.setValue(sourceImage, forKey: kCIInputImageKey)
            
            if let cgimg = self.context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
                
                let processedImage = UIImage(cgImage: cgimg, scale: inputImage.scale, orientation: inputImage.imageOrientation)
                completion(processedImage)
            }
        }
    }
    
    func rotateImage(to image: UIImage,orientation: UIImage.Orientation, comletion: @escaping ((UIImage) -> ())) {
        if let sourceImage = CIImage(image: image) {
            if let cgImg = context.createCGImage(sourceImage, from: sourceImage.extent) {
                let processedImage = UIImage(cgImage: cgImg, scale: image.scale, orientation: orientation)
                comletion(processedImage)
            }
        }
    }
}

extension FiltersService {
    func cropImage(inputImage: UIImage, inputImageView: UIImageView, cropRect: CGRect, completion: @escaping (UIImage) ->())
    {
        let imageWidth = inputImage.size.width
        let imageHeight = inputImage.size.height
        let imageViewWidth = inputImageView.width
        let imageViewHeight = inputImageView.height
        
        let imageViewScale = max(imageWidth / imageViewWidth,
                                 imageHeight / imageViewHeight)
        var cropZone = CGRect()
        // Scale cropRect to handle images larger than shown-on-screen size
        if imageHeight>imageWidth {
            cropZone = CGRect(x: cropRect.origin.x*imageViewScale,
                              y: cropRect.origin.y*imageViewScale,
                              width: cropRect.size.width * imageViewScale,
                              height: cropRect.size.height * imageViewScale)
        } else {
            cropZone = CGRect(x: cropRect.origin.x*imageViewScale,
                              y: cropRect.origin.y/imageViewScale,
                              width: cropRect.size.width * imageViewScale,
                              height: cropRect.size.height * imageViewScale)
        }
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropZone)
        else { return }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        completion(croppedImage)
    }
}
