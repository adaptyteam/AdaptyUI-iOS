//
//  AdaptyUIStackView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

extension AdaptyUI.Stack {
    var alignment: Alignment {
        switch (verticalAlignment, horizontalAlignment) {
        case (.top, .left): .topLeading
        case (.top, .center): .top
        case (.top, .right): .topTrailing
        case (.center, .left): .leading
        case (.center, .center): .center
        case (.center, .right): .trailing
        case (.bottom, .left): .bottomLeading
        case (.bottom, .center): .bottom
        case (.bottom, .right): .bottomTrailing
        default: .center
        }
    }
}

extension AdaptyUI.HorizontalAlignment {
    var swiftuiValue: SwiftUI.HorizontalAlignment {
        switch self {
        case .left: .leading
        case .center: .center
        case .right: .trailing
        case .fill: .center
        }
    }
}

extension AdaptyUI.VerticalAlignment {
    var swiftuiValue: SwiftUI.VerticalAlignment {
        switch self {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        case .fill: .center
        }
    }
}

extension View {
    @ViewBuilder
    func fixedVerticalSizeIfFill(_ alignment: AdaptyUI.VerticalAlignment) -> some View {
        if alignment == .fill {
            fixedSize(horizontal: false, vertical: true)
        } else {
            self
        }
    }

    @ViewBuilder
    func fixedHorizontalSizeIfFill(_ alignment: AdaptyUI.HorizontalAlignment) -> some View {
        if alignment == .fill {
            fixedSize(horizontal: true, vertical: false)
        } else {
            self
        }
    }

    @ViewBuilder
    func infiniteHeightIfFill(_ alignment: AdaptyUI.VerticalAlignment) -> some View {
        if alignment == .fill {
            frame(maxHeight: .infinity)
        } else {
            self
        }
    }

    @ViewBuilder
    func infiniteWidthIfFill(_ alignment: AdaptyUI.HorizontalAlignment) -> some View {
        if alignment == .fill {
            frame(maxWidth: .infinity)
        } else {
            self
        }
    }
}

struct AdaptyUIStackView: View {
    var stack: AdaptyUI.Stack

    var body: some View {
        switch stack.type {
        case .vertical:
            VStack(alignment: stack.horizontalAlignment.swiftuiValue) {
                ForEach(0 ..< stack.elements.count, id: \.self) {
                    stack.elements[$0]
                        .infiniteWidthIfFill(stack.horizontalAlignment)
                }
            }
            .fixedHorizontalSizeIfFill(stack.horizontalAlignment)
        case .horizontal:
            HStack(alignment: stack.verticalAlignment.swiftuiValue) {
                ForEach(0 ..< stack.elements.count, id: \.self) {
                    stack.elements[$0]
                        .infiniteHeightIfFill(stack.verticalAlignment)
                }
            }
            .fixedVerticalSizeIfFill(stack.verticalAlignment)
        case .z:
            // TODO: implement fill-fill scenario
            ZStack(alignment: stack.alignment) {
                ForEach(0 ..< stack.elements.count, id: \.self) {
                    stack.elements[$0]
                }
            }
        }
    }
}

@testable import Adapty

extension AdaptyUI.Stack {
    static var testVStack: AdaptyUI.Stack {
        AdaptyUI.Stack(
            type: .vertical,
            horizontalAlignment: .fill,
            verticalAlignment: .center,
            elements: [
                .space(1),
                .text(.testBodyShort, nil),
                .space(1),
                .text(.testBodyLong, nil),
                .space(1),
            ]
        )
    }

    static var testHStack: AdaptyUI.Stack {
        AdaptyUI.Stack(
            type: .horizontal,
            horizontalAlignment: .left,
            verticalAlignment: .fill,
            elements: [
                .space(1),
                .text(.testBodyShort, nil),
                .space(1),
                .text(
                    .testBodyLong,
                    .init(
                        decorastor: .init(
                            shapeType: .rectangle(cornerRadius: .zero),
                            background: .color(.testGreen),
                            border: nil
                        ),
                        frsme: nil,
                        padding: .zero,
                        offset: .zero,
                        visibility: true,
                        transitionIn: []
                    )
                ),
                .space(1),
            ]
        )
    }

    static var testZStack: AdaptyUI.Stack {
        AdaptyUI.Stack(
            type: .z,
            horizontalAlignment: .right,
            verticalAlignment: .top,
            elements: [
                .text(
                    .testBodyLong,
                    .init(
                        decorastor: .init(
                            shapeType: .rectangle(cornerRadius: .zero),
                            background: .color(.testGreen),
                            border: nil
                        ),
                        frsme: nil,
                        padding: .zero,
                        offset: .zero,
                        visibility: true,
                        transitionIn: []
                    )
                ),
                .unknown("circle",
                         .init(
                             decorastor: nil,
                             frsme: .init(height: .point(32), width: .point(32),
                                          minHeight: nil, maxHeight: nil, minWidth: nil,
                                          maxWidth: nil),
                             padding: .zero,
                             offset: .init(x: 20, y: -20),
                             visibility: true,
                             transitionIn: []
                         )
                ),
            ]
        )
    }
}

#Preview {
//    AdaptyUIStackView(.testVStack, nil)
    AdaptyUIStackView(stack: .testHStack)
//    AdaptyUIStackView(.testZStack, nil)
}
