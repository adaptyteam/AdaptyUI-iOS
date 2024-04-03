//
//  AdaptyUIUnknownElementView.swift
//
//
//  Created by Aleksey Goncharov on 3.4.24..
//

import Adapty
import SwiftUI

extension AdaptyUI {
    enum DebugElement: String {
        case circle
        case rectangle
    }
}

struct AdaptyUIUnknownElementView: View {
    var value: String
    var properties: AdaptyUI.Element.Properties?

    @ViewBuilder
    private func debugView(_ element: AdaptyUI.DebugElement) -> some View {
        switch element {
        case .circle: Circle()
        case .rectangle: Rectangle()
        }
    }

    var body: some View {
        if let debugElement = AdaptyUI.DebugElement(rawValue: value) {
            debugView(debugElement)
                .applyingProperties(properties)
        } else {
            Text("Unknown View \(value)")
                .applyingProperties(properties)
        }
    }
}

extension AdaptyUI.Element {
    var testCircle: Self {
        .unknown("circle", nil)
    }
    
    var testRectangle: Self {
        .unknown("rectangle", nil)
    }
}

#Preview {
    AdaptyUIUnknownElementView(value: AdaptyUI.DebugElement.circle.rawValue,
                               properties: nil)
}
