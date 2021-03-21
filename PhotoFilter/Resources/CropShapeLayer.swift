//
//  CropShapeLayer.swift
//  TestProject
//
//  Created by Bilal Durnagöl on 16.03.2021.
//

import UIKit
import RxSwift
import RxCocoa

class CropShapeLayer: UIView {
    var imageView = UIImageView()
    var image = UIImage()
    var ratio = CGFloat()
    let shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor =  UIColor.clear.cgColor
        shapeLayer.fillRule = CAShapeLayerFillRule.evenOdd
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 3
        return shapeLayer
    }()
    override var frame: CGRect {
        didSet {
            let startPoint = imagePoint()
            ratio = 1/1
            doSetup(startX: startPoint.minX, startY: startPoint.minY)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(shapeLayer)
        doSetup(startX: 0.0, startY: 0.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = layer.bounds
    }
    func doSetup(startX: CGFloat, startY: CGFloat) {
        let crop = cropFrame()
        let endX: CGFloat = startX + crop.width
        let endY: CGFloat = startY + crop.height
        
        let imageStartPoint = CGPoint(x: startX, y: startY)
        let imageEndPoint = CGPoint(x: endX, y: endY)
        
        let imageRect = rect(from: imageStartPoint, to: imageEndPoint)
        
        let imagePath = UIBezierPath(rect: imageRect)
        let cropBounds = imagePath.bounds
        let imageBounds = imagePoint()
        if imageBounds.contains(cropBounds) {
            shapeLayer.path = imagePath.cgPath
        }

    }
    func imagePoint() -> CGRect {
        let imageViewScale = max(image.size.width/imageView.frame.width,
                                 image.size.height/imageView.frame.height)
        let imageStartX: CGFloat = (imageView.frame.width - image.size.width/imageViewScale)/2
        let imageStartY: CGFloat = (imageView.frame.height - image.size.height/imageViewScale)/2
        let imageEndX: CGFloat = imageStartX + image.size.width/imageViewScale
        let imageEndY: CGFloat = imageStartY + image.size.height/imageViewScale
        
        let startPoint = CGPoint(x: imageStartX, y: imageStartY)
        let endPoint = CGPoint(x: imageEndX, y: imageEndY)
        return rect(from: startPoint, to: endPoint)
    }

    
    // cropshapelayer width and height
    func cropFrame() -> CGRect {
        var cropHeight:CGFloat = 0.0
        var cropWidht:CGFloat = 0.0
        let imageHeight = imagePoint().height
        let imageWidht = imagePoint().width
            if ratio >= 1 {
                cropWidht = imageWidht
                cropHeight = 1/ratio*cropWidht
                if cropHeight > imageHeight {
                    let differenceHeight = cropHeight - imageHeight
                    cropWidht = cropWidht - ratio*differenceHeight
                    cropHeight = cropHeight - differenceHeight
                }
            } else {
                cropHeight = imageHeight
                cropWidht = ratio*cropHeight
                if cropWidht > imageWidht {
                    let differenceWidht = cropWidht - imageWidht
                    cropHeight =  cropHeight - 1/ratio*differenceWidht
                    cropWidht = cropWidht - differenceWidht
                }
            }
        
        return CGRect(x: 0, y: 0, width: cropWidht, height: cropHeight)
    }
}
extension CropShapeLayer {
    func rect(from: CGPoint, to: CGPoint) -> CGRect {
        return CGRect(x: min(from.x, to.x),
                      y: min(from.y, to.y),
                      width: abs(to.x - from.x),
                      height: abs(to.y - from.y))
    }
}
