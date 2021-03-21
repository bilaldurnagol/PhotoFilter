//
//  PHAsset+Extensions.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 5.03.2021.
//
import UIKit
import Photos

extension PHAsset {
    func assetToImage() -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: self,
                             targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight),
                             contentMode: .aspectFit,
                             options: option,
                             resultHandler: {(result, info) -> Void in
                                guard let result = result else {return}
                                image = result
                             })
        return image
    }
}

