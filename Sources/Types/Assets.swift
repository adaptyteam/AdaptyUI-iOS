//
//  Assets.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import Adapty
import UIKit

protocol ColorAsset {
    var uiColor: UIColor { get }
}

protocol FontAsset {
    var uiFont: UIFont { get }
    var uiColor: UIColor? { get }
}

protocol LinarGradientAsset {
    associatedtype ColorType

    typealias Point = (Double, Double)
    typealias Value = (Double, ColorType)

    var startPoint: Point { get }
    var endPoint: Point { get }
    var values: [Value] { get }
}

protocol ImageAsset {
    var uiImage: UIImage? { get }
}

// MARK: - AdaptyUI

extension AdaptyUI.Color: ColorAsset {
    var uiColor: UIColor { .init(red: red, green: green, blue: blue, alpha: alpha) }
}

extension AdaptyUI.Font: FontAsset {
    private var conertedWeight: UIFont.Weight {
        switch style {
        case "bold":
            return .bold
        case "medium":
            return .medium
        default:
            return .regular
        }
    }

    var uiFont: UIFont { .systemFont(ofSize: defaultSize ?? 15.0, weight: conertedWeight) }
    var uiColor: UIColor? { defaultColor?.uiColor }
}

extension AdaptyUI.Image: ImageAsset {
    var uiImage: UIImage? { UIImage(data: data) }
}
