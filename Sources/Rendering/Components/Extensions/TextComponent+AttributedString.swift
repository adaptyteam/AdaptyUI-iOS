//
//  TextComponent+AttributedString.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import UIKit

extension TextComponent {
    var attributedString: NSAttributedString? {
        let text = value ?? ""
        let color = uiColor ?? .darkText
        let font = uiFont ?? .systemFont(ofSize: 15)

        return NSAttributedString(string: text,
                                  attributes: [
                                      NSAttributedString.Key.foregroundColor: color,
                                      NSAttributedString.Key.font: font,
                                  ])
    }
}
