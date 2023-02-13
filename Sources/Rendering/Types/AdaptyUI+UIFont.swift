//
//  AdaptyUI+UIFont.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Adapty
import UIKit

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
    
    func uiFont(overrideSize: Double? = nil) -> UIFont? {
        .systemFont(ofSize: overrideSize ?? defaultSize ?? 15.0, weight: conertedWeight)
    }
}
