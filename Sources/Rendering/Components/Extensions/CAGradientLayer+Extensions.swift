//
//  CAGradientLayer+Extensions.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import UIKit

extension CAGradientLayer {
    static func create(_ asset: any LinarGradientAsset) -> CAGradientLayer {
        let layer = CAGradientLayer()

        layer.colors = asset.values.map { $0.1.cgColor }
        layer.locations = asset.values.map { NSNumber(floatLiteral: $0.0) }
        layer.startPoint = CGPoint(x: asset.startPoint.0, y: asset.startPoint.1)
        layer.endPoint = CGPoint(x: asset.endPoint.0, y: asset.endPoint.1)

        return layer
    }
}
