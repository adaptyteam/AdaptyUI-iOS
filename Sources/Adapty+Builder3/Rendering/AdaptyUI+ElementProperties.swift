//
//  AdaptyUI+ElementProperties.swift
//
//
//  Created by Aleksey Goncharov on 3.4.24..
//

import Adapty
import SwiftUI

// TODO: check decoration option
// TODO: check inlinable
extension View {
    @ViewBuilder
    func applyingProperties(_ props: AdaptyUI.Element.Properties?) -> some View {
        frame(
            width: props?.frsme?.width?.points(),
            height: props?.frsme?.height?.points()
        )
        .frame(
            minWidth: props?.frsme?.minWidth?.points(),
            maxWidth: props?.frsme?.maxWidth?.points(),
            minHeight: props?.frsme?.minHeight?.points(),
            maxHeight: props?.frsme?.maxHeight?.points()
        )
        .background(props?.decorastor?.background)
    }

    @ViewBuilder
    func background(_ background: AdaptyUI.Filling?) -> some View {
        switch background {
        case let .color(color):
            self.background(color.swiftuiColor)
        case let .colorGradient(colorGradient):
            self // TODO: implement
        case let .image(imageData):
            self // TODO: implement
        case nil:
            self
        }
    }
}

// TODO: move out
extension AdaptyUI.Color {
    var swiftuiColor: Color { Color(red: red, green: green, blue: blue, opacity: alpha) }
}

extension AdaptyUI.Unit {
    public func points(screenInPoints: CGFloat = 1024.0) -> CGFloat {
        switch self {
        case let .point(value): value
        case let .screen(value): value * screenInPoints
        }
    }
}