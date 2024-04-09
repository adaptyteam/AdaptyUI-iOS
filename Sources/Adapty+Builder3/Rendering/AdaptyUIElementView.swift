//
//  AdaptyUIElementView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

extension AdaptyUI.Element: View {
    public var body: some View {
        switch self {
        case let .space(count):
            if count > 0 {
                ForEach(0 ..< count, id: \.self) { _ in
                    Spacer()
                }
            }
        case let .stack(stack, properties):
            stack.applyingProperties(properties)
        case let .text(text, properties):
            text.applyingProperties(properties)
        case let .image(image, properties):
            AdaptyUIImageView(image)
                .applyingProperties(properties)
        case let .button(button, properties):
            button.applyingProperties(properties)
        case let .unknown(value, properties):
            AdaptyUIUnknownElementView(value: value)
                .applyingProperties(properties)
        }
    }
}
