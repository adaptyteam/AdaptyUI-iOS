//
//  AdaptyUI+UIColor.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Adapty
import UIKit

extension AdaptyUI.Color {
    var uiColor: UIColor { UIColor(red: red, green: green, blue: blue, alpha: alpha) }
}
