//
//  File.swift
//  
//
//  Created by Alexey Goncharov on 6.7.23..
//

import Adapty
import UIKit

extension AdaptyUI.Color {
    var uiColor: UIColor { .init(red: red, green: green, blue: blue, alpha: alpha) }
}

extension AdaptyUI.Font {
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

extension AdaptyUI.Image {
    var uiImage: UIImage? { UIImage(data: data) }
}


extension AdaptyUI.Text {
    var uiFont: UIFont? {
        guard let font = font?.uiFont else { return nil }
        
        if let size {
            return font.withSize(size)
        } else {
            return font
        }
    }

    var uiColor: UIColor? { fill?.asColor?.uiColor }
}

extension AdaptyUI.TextRow {
    var uiColor: UIColor? { fill?.asColor?.uiColor }
}

extension AdaptyUI.TextRows {
    var uiFont: UIFont? { font?.uiFont }
}
