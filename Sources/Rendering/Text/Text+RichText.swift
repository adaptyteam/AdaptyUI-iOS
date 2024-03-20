//
//  Text+RichText.swift
//
//
//  Created by Aleksey Goncharov on 20.3.24..
//

import Adapty
import UIKit

extension AdaptyUI.RichText {
    func attributedString(
        paragraph: AdaptyUI.RichText.ParagraphStyle = .init(),
        kern: CGFloat? = nil,
        tagConverter: AdaptyUI.CustomTagConverter?,
        productTagConverter: AdaptyUI.ProductTagConverter? = nil
    ) -> NSAttributedString {
        guard !isEmpty else { return NSAttributedString() }

        var result = NSMutableAttributedString(string: "")
        var paragraph = NSMutableAttributedString(string: "")

        for item in items {
            switch item {
            case let .text(value, attributes):
                paragraph.append(.fromText(value, attributes: attributes))
            case let .tag(value, attributes):
                let replacementValue = tagConverter?(value) ?? value
//                if text.hasTags {
//                    resultText = resultText.replaceCustomTags(converter: tagConverter, fallback: text.fallback)
//                }
//
//                if let productTagConverter = productTagConverter {
//                    if let convertedText = resultText.replaceProductTags(converter: productTagConverter) {
//                        resultText = convertedText
//                    } else {
//                        return nil
//                    }
//                }
                
                // TODO: replace tag
                paragraph.append(.fromText(replacementValue, attributes: attributes))
            case let .paragraph(attr):

                if let paragraphStyle = attr?.paragraphStyle {
                    paragraph.addAttributes(
                        [NSAttributedString.Key.paragraphStyle: paragraphStyle],
                        range: NSRange(location: 0, length: paragraph.length)
                    )
                }
                // TODO: add newline?
                result.append(paragraph)
                paragraph = NSMutableAttributedString(string: "")
            case let .image(image, imageInTextAttributes):
                // TODO: support image
                break
            }
        }

        return result
    }
}

extension NSAttributedString {
    static func fromText(
        _ value: String,
        attributes: AdaptyUI.RichText.TextAttributes?
    ) -> NSAttributedString {
        let foregroundColor = attributes?.uiColor ?? .darkText

        let result = NSMutableAttributedString(
            string: value,
            attributes: [
                NSAttributedString.Key.foregroundColor: foregroundColor,
                NSAttributedString.Key.font: attributes?.font?.uiFont ?? .systemFont(ofSize: 15),
            ]
        )

        if let background = attributes?.background?.asColor {
            result.addAttributes([
                NSAttributedString.Key.backgroundColor: background.uiColor,
            ], range: NSRange(location: 0, length: result.length))
        }

        if let strike = attributes?.strike, strike {
            result.addAttributes([
                NSAttributedString.Key.strikethroughColor: foregroundColor,
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single,
            ], range: NSRange(location: 0, length: result.length))
        }

        if let underline = attributes?.underline, underline {
            result.addAttributes([
                NSAttributedString.Key.underlineColor: foregroundColor,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single,
            ], range: NSRange(location: 0, length: result.length))
        }

        return result
    }
}

extension AdaptyUI.RichText.ParagraphAttributes {
    var paragraphStyle: NSParagraphStyle {
        let result = NSMutableParagraphStyle()
        result.firstLineHeadIndent = firstIndent ?? 0.0
        result.headIndent = indent ?? 0.0
        result.alignment = horizontalAlign?.textAlignment ?? .natural
        return result
    }
}

extension AdaptyUI.HorizontalAlign {
    var textAlignment: NSTextAlignment {
        switch self {
        case .left: return .natural
        case .center: return .center
        case .right: return .right
        case .fill: return .center // TODO: inspect
        }
    }
}
