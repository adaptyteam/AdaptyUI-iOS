//
//  AdaptyUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

import Adapty
import SwiftUI

struct AdaptyUITextView: View {
    var text: AdaptyUI.RichText
    var properties: AdaptyUI.Element.Properties?

    init(_ text: AdaptyUI.RichText, _ properties: AdaptyUI.Element.Properties?) {
        self.text = text
        self.properties = properties
    }

    @available(iOS 15, *)
    private var attributedString: AttributedString {
        AttributedString(text.attributedString(tagConverter: nil))
    }

    private var plainString: String {
        text.attributedString(tagConverter: nil).string
    }

    var body: some View {
        if #available(iOS 15, *) {
            Text(attributedString)
        } else {
            // TODO: implement
            Text(plainString)
        }
    }
}

// TODO: remove before release
@testable import Adapty

extension AdaptyUI.Color {
    static let testRed = AdaptyUI.Color(data: 0xFF0000FF)
}

extension AdaptyUI.RichText.ParagraphAttributes {
    static var test: Self {
        .init(horizontalAlign: .left, firstIndent: 0.0, indent: 0.0, bulletSpace: nil, bullet: nil)
    }
}

extension AdaptyUI.RichText.TextAttributes {
    static var testTitle: Self {
        .init(font: .default, size: 24.0, color: .color(.testRed), background: nil, strike: false, underline: false)
    }

    static var testBody: Self {
        .init(font: .default, size: 15.0, color: .color(.testRed), background: nil, strike: false, underline: false)
    }
}

extension AdaptyUI.RichText {
    static var testBodyShort: Self {
        .init(items: [.text("Hello world!", .testBody)], fallback: nil)
    }

    static var testBodyLong: Self {
        .init(items: [
            .text("Hello world!", .testTitle),
            .paragraph(.test),
            .text("Hello world!", .testBody),
        ], fallback: nil)
    }
}

#Preview {
    AdaptyUITextView(.testBodyLong, nil)
}
