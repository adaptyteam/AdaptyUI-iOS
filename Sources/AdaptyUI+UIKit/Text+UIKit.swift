//
//  Text+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

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
