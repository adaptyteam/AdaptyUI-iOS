//
//  Text+RichText.swift
//
//
//  Created by Aleksey Goncharov on 20.3.24..
//

import Adapty
import UIKit

extension AdaptyUI.RichText.Item {
    var uiFont: UIFont? {
        switch self {
        case let .text(_, attr), let .tag(_, attr): attr?.uiFont
        default: nil
        }
    }
}

extension Array where Element == AdaptyUI.RichText.Item {
    func closestItemFont(at index: Int) -> UIFont? {
        if let prevItemFont = self[safe: index - 1]?.uiFont { return prevItemFont }
        if let nextItemFont = self[safe: index + 1]?.uiFont { return nextItemFont }
        if let prevItemRecursiveFont = closestItemFont(at: index - 1) { return prevItemRecursiveFont }
        if let nextItemRecursiveFont = closestItemFont(at: index + 1) { return nextItemRecursiveFont }
        return nil
    }
}

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

        for i in 0 ..< items.count {
            let item = items[i]

            switch item {
            case let .text(value, attr):
                result.append(.fromText(value,
                                        attributes: attr,
                                        paragraphStyle: paragraphStyle))
            case let .tag(value, attr):
                let replacementValue = tagConverter?(value) ?? value
                // TODO: replace tag
                result.append(.fromText(replacementValue,
                                        attributes: attr,
                                        paragraphStyle: paragraphStyle))
            case let .paragraph(attr):
                if result.length > 0 {
                    result.append(.newLine(paragraphStyle: paragraphStyle))
                }

                paragraphStyle = attr?.paragraphStyle
            case let .image(value, attr):
                guard let value else { break }

                let font = items.closestItemFont(at: i) ?? .systemFont(ofSize: 15)

                result.append(.fromImage(value,
                                         attributes: attr,
                                         font: font,
                                         paragraphStyle: paragraphStyle))
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
        font: UIFont,
        paragraphStyle: NSParagraphStyle?
    ) -> NSAttributedString {
        guard let attachment = value.formAttachment(font: font, attributes: attributes) else {
            return NSAttributedString(string: "")
        }

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
    func formAttachment(
        font: UIFont,
        attributes: AdaptyUI.RichText.ImageInTextAttributes?
    ) -> NSTextAttachment? {
        guard case let .raster(data) = self, var image = UIImage(data: data) else {
            return nil
        }

        if let tint = attributes?.tint?.asColor {
            image = image
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(tint.uiColor, renderingMode: .alwaysOriginal)
        }

        let height = font.capHeight
        let width = height / image.size.height * image.size.width

        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = .init(x: 0, y: 0, width: width, height: height)
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
