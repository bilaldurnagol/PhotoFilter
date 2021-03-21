//
//  ImageEditHandler.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 5.03.2021.
//

import UIKit
import Photos

class ImageEditHandler {
    
    static let shared = ImageEditHandler()
    
    func fetchPhotos(completion: @escaping (PHAsset) -> ()) {
        PHPhotoLibrary.requestAuthorization({status in
            if status == .authorized {
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                let asset = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
                asset.enumerateObjects({asset, count, _ in
                    completion(asset)
                })
            }
        })
    }
}
