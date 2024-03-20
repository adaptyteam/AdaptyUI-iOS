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

        let result = NSMutableAttributedString(string: "")
        var paragraphStyle: NSParagraphStyle?

        for item in items {
            switch item {
            case let .text(value, attributes):
                result.append(.fromText(value,
                                        attributes: attributes,
                                        paragraphStyle: paragraphStyle))
            case let .tag(value, attributes):
                let replacementValue = tagConverter?(value) ?? value
                // TODO: replace tag
                result.append(.fromText(replacementValue,
                                        attributes: attributes,
                                        paragraphStyle: paragraphStyle))
            case let .paragraph(attr):
                if result.length > 0 {
                    result.append(.newLine(paragraphStyle: paragraphStyle))
                }

                paragraphStyle = attr?.paragraphStyle
            case let .image(value, attributes):
                if let value {
                    result.append(.fromImage(value,
                                             attributes: attributes,
                                             paragraphStyle: paragraphStyle))
                }
            }
        }

        return result
    }
}

extension NSAttributedString {
    static func newLine(paragraphStyle: NSParagraphStyle?) -> NSAttributedString {
        NSMutableAttributedString(
            string: "\n",
            attributes: [
                .paragraphStyle: paragraphStyle ?? NSParagraphStyle(),
            ]
        )
    }

    static func fromText(
        _ value: String,
        attributes: AdaptyUI.RichText.TextAttributes?,
        paragraphStyle: NSParagraphStyle?
    ) -> NSAttributedString {
        let foregroundColor = attributes?.uiColor ?? .darkText

        let result = NSMutableAttributedString(
            string: value,
            attributes: [
                .foregroundColor: foregroundColor,
                .font: attributes?.font?.uiFont(size: attributes?.size) ?? .systemFont(ofSize: 15),
            ]
        )

        result.addAttributes(
            paragraphStyle: paragraphStyle,
            background: attributes?.background,
            strike: attributes?.strike,
            underline: attributes?.underline
        )

        return result
    }

    static func fromImage(
        _ value: AdaptyUI.Image,
        attributes: AdaptyUI.RichText.ImageInTextAttributes?,
        paragraphStyle: NSParagraphStyle?
    ) -> NSAttributedString {
        guard let attachment = value.formAttachment(attributes: attributes) else { return NSAttributedString(string: "") }

        let result = NSMutableAttributedString()
        result.append(NSAttributedString(attachment: attachment))

        result.addAttributes(
            paragraphStyle: paragraphStyle,
            background: attributes?.background,
            strike: attributes?.strike,
            underline: attributes?.underline
        )

        return result
    }
}

extension NSMutableAttributedString {
    func addAttributes(
        paragraphStyle: NSParagraphStyle?,
        background: AdaptyUI.Filling?,
        strike: Bool?,
        underline: Bool?
    ) {
        if let paragraphStyle {
            addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: length))
        }

        if let background = background?.asColor {
            addAttribute(.backgroundColor, value: background.uiColor, range: NSRange(location: 0, length: length))
        }

        if let strike, strike {
            addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: length))
        }

        if let underline, underline {
            addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: length))
        }
    }
}

extension AdaptyUI.Image {
    func formAttachment(attributes: AdaptyUI.RichText.ImageInTextAttributes?) -> NSTextAttachment? {
        guard case let .raster(data) = self, var image = UIImage(data: data) else {
            return nil
        }

        if let tint = attributes?.tint?.asColor {
            image = image
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(tint.uiColor, renderingMode: .alwaysOriginal)
        }

        let height = attributes?.size ?? image.size.height
        let width = height / image.size.height * image.size.width

//        let font = font?.uiFont ?? .systemFont(ofSize: 17.0)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = .init(x: 0,
                                       y: 0, // (font.capHeight - size.height).rounded(.down) / 2.0,
                                       width: width,
                                       height: height)
        return imageAttachment
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
