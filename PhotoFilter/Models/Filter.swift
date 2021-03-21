//
//  Filter.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 9.03.2021.
//

import Foundation
import CoreImage
import Photos
import UIKit

struct FilterMenu {
    let icon: UIImage?
    let name: Filters
}


enum Filters: String {
    case Brightness, Contrast, Saturation, Sharpen, Exposure, Highlight, Shadow, Straighten, Crop
    
    var filterName: String {
        switch self {
        case .Brightness:
            return "CIColorControls"
        case .Contrast:
            return "CIColorControls"
        case .Saturation:
            return "CIColorControls"
        case .Sharpen:
            return "CISharpenLuminance"
        case .Exposure:
            return "CIExposureAdjust"
        case .Highlight:
            return "CIHighlightShadowAdjust"
        case .Shadow:
            return "CIHighlightShadowAdjust"
        case .Straighten:
            return "CIStraightenFilter"
        case .Crop:
            return "CICrop"
        }
    }
    
    var filterKey: String {
        switch self {
        case .Brightness:
            return "inputBrightness"
        case .Contrast:
            return "inputContrast"
        case .Saturation:
            return "inputSaturation"
        case .Sharpen:
            return "inputSharpness"
        case .Exposure:
            return "inputEV"
        case .Highlight:
            return "inputHighlightAmount"
        case .Shadow:
            return "inputShadowAmount"
        case .Straighten:
            return "inputAngle"
        case .Crop:
            return "inputRectangle"
        }
    }
    
    var def: Float {
        switch self {
        case .Brightness:
            return 0.0
        case .Contrast:
            return 1.0
        case .Saturation:
            return 1.0
        case .Sharpen:
            return 0.4
        case .Exposure:
            return 0.5
        case .Highlight:
            return 1.0
        case .Shadow:
            return 0.0
        case .Straighten:
            return 0.0
        case .Crop:
            return 0.0
        }
    }
    
    var min: Float {
        switch self {
        case .Brightness:
            return 0.0
        case .Contrast:
            return 0.9
        case .Saturation:
            return 0.5
        case .Sharpen:
            return 0.4
        case .Exposure:
            return 0.5
        case .Highlight:
            return 0.0
        case .Shadow:
            return 0.0
        case .Straighten:
            return -0.5
        case .Crop:
            return 0.0
        }
    }
    
    var max: Float {
        switch self {
        case .Brightness:
            return 1.0
        case .Contrast:
            return 1.1
        case .Saturation:
            return 1.5
        case .Sharpen:
            return 1.0
        case .Exposure:
            return 1.5
        case .Highlight:
            return 1.0
        case .Shadow:
            return 1.0
        case .Straighten:
            return 0.5
        case .Crop:
            return 0.0
        }
    }
}
