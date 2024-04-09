//
//  AdaptyUI+ElementProperties.swift
//
//
//  Created by Aleksey Goncharov on 3.4.24..
//

import Adapty
import SwiftUI

extension AdaptyUI.Point {
    var unitPoint: UnitPoint { UnitPoint(x: x, y: y) }
}

extension AdaptyUI.ColorGradient.Item {
    var gradientStop: Gradient.Stop { Gradient.Stop(color: color.swiftuiColor, location: p) }
}

struct AdaptyUIGradient: View {
    var gradient: AdaptyUI.ColorGradient

    init(_ gradient: AdaptyUI.ColorGradient) {
        self.gradient = gradient
    }

    var body: some View {
        switch gradient.kind {
        case .linear:
            LinearGradient(
                stops: gradient.items.map { $0.gradientStop },
                startPoint: gradient.start.unitPoint,
                endPoint: gradient.end.unitPoint
            )
        case .conic:
            // TODO: check implementation
            AngularGradient(
                gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                center: .center,
                angle: .degrees(360)
            )
        case .radial:
            // TODO: check implementation
            RadialGradient(
                gradient: .init(stops: gradient.items.map { $0.gradientStop }),
                center: .center,
                startRadius: 0.0,
                endRadius: 1.0
            )
        }
    }
}

// TODO: check decoration option
// TODO: check inlinable
extension View {
    @ViewBuilder
    func applyingProperties(_ props: AdaptyUI.Element.Properties?) -> some View {
        // TODO: fix typo frsme
        // TODO: fix typo decorastor

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
        .offset(x: props?.offset.x ?? 0.0, y: props?.offset.y ?? 0.0)
        .background(props?.decorastor?.background)
        .border(props?.decorastor?.border)
        .padding(props?.padding)
    }

    @ViewBuilder
    func padding(_ insets: AdaptyUI.EdgeInsets?) -> some View {
        if let insets {
            padding(.leading, insets.left)
                .padding(.top, insets.top)
                .padding(.trailing, insets.right)
                .padding(.bottom, insets.bottom)
        } else {
            self
        }
    }

    @ViewBuilder
    func background(_ filling: AdaptyUI.Filling?) -> some View {
        switch filling {
        case let .color(color):
            background(color.swiftuiColor)
        case let .colorGradient(gradient):
            background(AdaptyUIGradient(gradient))
        case let .image(imageData):
            self // TODO: implement
        case nil:
            self
        }
    }

    @ViewBuilder
    func border(_ border: AdaptyUI.Border?) -> some View {
        if let border, let color = border.filling.asColor?.swiftuiColor {
            self.border(color, width: border.thickness)
        } else {
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
