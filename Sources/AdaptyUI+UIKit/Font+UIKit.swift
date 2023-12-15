//
//  Font+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

extension UIFont.Weight {
    static func fromInteger(_ value: Int) -> UIFont.Weight {
        switch value {
        case ..<150: return .ultraLight
        case ..<250: return .thin
        case ..<350: return .light
        case ..<450: return .regular
        case ..<550: return .medium
        case ..<650: return .semibold
        case ..<750: return .bold
        case ..<850: return .heavy
        default: return .black
        }
    }
}

extension UIFont {
    static func customFont(
        ofSize size: CGFloat,
        name: String,
        weight: Int,
        italic: Bool
    ) -> UIFont {
        var attributes = [UIFontDescriptor.AttributeName: Any]()
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = UIFont.Weight.fromInteger(weight)

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = name

        var testDescr = UIFontDescriptor(fontAttributes: attributes)

        var symbolicTraits: UIFontDescriptor.SymbolicTraits = []

        if italic {
            symbolicTraits = symbolicTraits.union(.traitItalic)
        }

        testDescr = testDescr.withSymbolicTraits(symbolicTraits) ?? testDescr

        return UIFont(descriptor: testDescr, size: size)
    }
}

extension AdaptyUI.Font {
    static let systemFontReservedName = "adapty_system"
    
    var uiColor: UIColor? { defaultColor?.uiColor }

    var uiFont: UIFont {
        let size = defaultSize ?? 15.0

        if !alias.isEmpty, let font = UIFont(name: alias, size: size) {
            return font
        }

        if familyName == Self.systemFontReservedName {
            if italic {
                return .italicSystemFont(ofSize: size)
            } else {
                return .systemFont(ofSize: size, weight: .fromInteger(weight ?? 400))
            }
        }

        return .customFont(ofSize: size,
                           name: familyName,
                           weight: weight ?? 400,
                           italic: italic)
    }
}
