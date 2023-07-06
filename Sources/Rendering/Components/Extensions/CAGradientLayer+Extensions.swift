//
//  CAGradientLayer+Extensions.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.Point {
    var cgPoint: CGPoint { .init(x: x, y: y) }
}

extension CAGradientLayer {
    static func create(_ asset: AdaptyUI.ColorLinearGradient) -> CAGradientLayer {
        let layer = CAGradientLayer()

        layer.colors = asset.items.map { $0.color.uiColor.cgColor }
        layer.locations = asset.items.map { NSNumber(floatLiteral: $0.p) }
        layer.startPoint = asset.start.cgPoint
        layer.endPoint = asset.end.cgPoint

        return layer
    }
}
