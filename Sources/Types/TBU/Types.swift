//
//  Types.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import Foundation

enum BackgroundTBU {
    case color(ColorAsset)
    case image(ImageAsset)
    case gradient(any LinarGradientAsset)
}

enum MaskTBU {
    case circle
    case rect
    case curveUp
    case curveDown
}

enum AlignTBU {
    case leading
    case center
    case trailing
    case fill
}
