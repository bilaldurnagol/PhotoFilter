//
//  Presets.swift
//  PhotoFilter
//
//  Created by Bilal Durnagöl on 25.03.2021.
//

import Foundation

struct Presets {
    var name: String
    var preset: Preset
}

enum Preset {
    case Chrome, Fade, Instant, Mono, Noir, Process, Tonal, Transfer
    
    var presetsName: String {
        switch self {
        case .Chrome:
            return "CIPhotoEffectChrome"
        case .Fade:
            return "CIPhotoEffectFade"
        case .Instant:
            return "CIPhotoEffectInstant"
        case .Mono:
            return "CIPhotoEffectMono"
        case .Noir:
            return "CIPhotoEffectNoir"
        case .Process:
            return "CIPhotoEffectProcess"
        case .Tonal:
            return "CIPhotoEffectTonal"
        case .Transfer:
            return "CIPhotoEffectTransfer"
        }
    }
}
