//
//  RangeSlider.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 8.03.2021.
//

import UIKit

class RangeSlider: UIControl {
    var minimumValue: CGFloat = 0
    var maximumValue: CGFloat = 1
    var thumbValue: CGFloat = 0.5
    
    private var previousLocation = CGPoint()
    
    var thumbImage = UIImage(systemName: "circle.fill")
    private let trackLayer = CALayer()
    private let thumbImageView = UIImageView()
    private let midImageView = UIImageView()
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        trackLayer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        layer.addSublayer(trackLayer)
        
        midImageView.image = thumbImage
        midImageView.tintColor = UIColor.white
        addSubview(midImageView)
        
        thumbImageView.image = thumbImage
        thumbImageView.tintColor = UIColor(red: 153/255, green: 135/255, blue: 49/255, alpha: 1.0)
        thumbImageView.layer.borderWidth = 2.0
        thumbImageView.layer.borderColor = UIColor.white.cgColor
        thumbImageView.layer.cornerRadius = thumbImageView.height/2
        addSubview(thumbImageView)
        
        updateLayerFrames()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLayerFrames() {
        trackLayer.frame = CGRect(x: 20, y: height/2, width: width - 40, height: 3)
        trackLayer.setNeedsDisplay()
        thumbImageView.frame = CGRect(origin: thumbOriginForValue(thumbValue),
                                      size: thumbImage!.size)
        midImageView.frame = CGRect(origin: startOriginForValue(0.5),
                                    size: CGSize(width: thumbImage!.size.width/2, height: thumbImage!.size.width/2))
        
    }
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = (trackLayer.bounds.width * value) + (thumbImage!.size.width / 2.0)
        let y = (bounds.height - thumbImage!.size.height) / 2.0
        return CGPoint(x: x, y: y)
    }
    private func startOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = (bounds.width * value) - (thumbImage!.size.width / 4.0)
        let y = (bounds.height - thumbImage!.size.height) / 2.0 + (thumbImage!.size.height / 4.0)
        return CGPoint(x: x, y: y)
    }
}

extension RangeSlider {
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        if thumbImageView.frame.contains(previousLocation) {
            thumbImageView.isHighlighted = true
        }
        return thumbImageView.isHighlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        
        previousLocation = location
        
        if thumbImageView.isHighlighted {
            thumbValue += deltaValue
            thumbValue = boundValue(thumbValue, toLowerValue: minimumValue,
                                    upperValue: maximumValue)
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        sendActions(for: .valueChanged)
        return true
    }
    
    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat,
                            upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbImageView.isHighlighted = false
    }
}
