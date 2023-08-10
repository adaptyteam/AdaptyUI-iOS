//
//  Font+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

extension AdaptyUI.Font {
    private var conertedWeight: UIFont.Weight {
        switch style.lowercased() {
        case "black", "w900": return .black
        case "heavy", "w800": return .heavy
        case "bold", "w700": return .bold
        case "semibold", "w600": return .semibold
        case "medium", "w500": return .medium
        case "regular", "w400": return .regular
        case "light", "w300": return .light
        case "ultralight", "w200": return .ultraLight
        case "thin", "w100": return .thin
        default: return .regular
        }
    }

    var uiFont: UIFont { .systemFont(ofSize: defaultSize ?? 15.0, weight: conertedWeight) }
    var uiColor: UIColor? { defaultColor?.uiColor }
}
