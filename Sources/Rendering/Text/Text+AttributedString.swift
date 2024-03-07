//
//  Text+AttributedString.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.HorizontalAlign {
    var textAlignment: NSTextAlignment {
        switch self {
        case .left: return .natural
        case .center: return .center
        case .right: return .right
        }
    }
}

extension AdaptyUI.Text {
    struct ParagraphStyle {
        let alignment: NSTextAlignment
        let lineSpacing: CGFloat
        let paragraphSpacing: CGFloat
        let firstLineHeadIndent: CGFloat
        let headIndent: CGFloat

        init(
            alignment: NSTextAlignment = .left,
            lineSpacing: CGFloat = 0.0,
            paragraphSpacing: CGFloat = 0.0,
            firstLineHeadIndent: CGFloat = 0.0,
            headIndent: CGFloat = 0.0
        ) {
            self.alignment = alignment
            self.lineSpacing = lineSpacing
            self.paragraphSpacing = paragraphSpacing
            self.firstLineHeadIndent = firstLineHeadIndent
            self.headIndent = headIndent
        }
    }
}

extension AdaptyUI.Text.ParagraphStyle {
    func copyWith(
        alignment: NSTextAlignment? = nil,
        lineSpacing: CGFloat? = nil,
        paragraphSpacing: CGFloat? = nil,
        firstLineHeadIndent: CGFloat? = nil,
        headIndent: CGFloat? = nil
    ) -> Self {
        AdaptyUI.Text.ParagraphStyle(
            alignment: alignment ?? self.alignment,
            lineSpacing: lineSpacing ?? self.lineSpacing,
            paragraphSpacing: paragraphSpacing ?? self.paragraphSpacing,
            firstLineHeadIndent: firstLineHeadIndent ?? self.firstLineHeadIndent,
            headIndent: headIndent ?? self.headIndent
        )
    }

    func toParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.alignment = alignment
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.firstLineHeadIndent = firstLineHeadIndent
        paragraphStyle.headIndent = headIndent

        return paragraphStyle
    }
}

extension AdaptyUI.Text {
    func calculatedWidth() -> CGFloat {
        value?.size(withAttributes: [
            NSAttributedString.Key.foregroundColor: uiColor ?? .darkText,
            NSAttributedString.Key.font: uiFont ?? .systemFont(ofSize: 15),
        ]).width ?? 0.0
    }

    func attributedString(
        paragraph: AdaptyUI.Text.ParagraphStyle,
        kern: CGFloat?,
        trailingPadding: CGFloat?
    ) -> NSAttributedString? {
        value?.attributedString(using: self, paragraph: paragraph, kern: kern, trailingPadding: trailingPadding)
    }
}

extension AdaptyUI.Text.Image {
    func formAttachment(font: AdaptyUI.Font?) -> NSTextAttachment? {
        guard case .raster(let data) = src, var image = UIImage(data: data) else { return nil }

        if let tint {
            image = image
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(tint.uiColor, renderingMode: .alwaysTemplate)
        }

        let font = font?.uiFont ?? .systemFont(ofSize: 17.0)
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = .init(x: 0,
                                       y: (font.capHeight - size.height).rounded(.down) / 2.0,
                                       width: size.width,
                                       height: size.height)
        return imageAttachment
    }

    func attributedString(
        paragraph: AdaptyUI.Text.ParagraphStyle,
        font: AdaptyUI.Font?,
        trailingPadding: CGFloat?
    ) -> NSAttributedString? {
        guard let attachment = formAttachment(font: font) else { return nil }

        let result = NSMutableAttributedString()
        result.append(NSAttributedString(attachment: attachment))

        if let trailingPadding, trailingPadding > 0.0 {
            let padding = NSTextAttachment()
            padding.bounds = CGRect(x: 0, y: 0, width: trailingPadding, height: 0)
            result.append(NSAttributedString(attachment: padding))
        }

        result.addAttribute(NSAttributedString.Key.paragraphStyle,
                            value: paragraph.toParagraphStyle(),
                            range: NSRange(location: 0, length: result.length))

        return result
    }
}

extension AdaptyUI.Text.Item {
    var isNewline: Bool {
        switch self {
        case .newline: return true
        default: return false
        }
    }

    var font: AdaptyUI.Font? {
        switch self {
        case let .text(text), let .textBullet(text): return text.font
        default: return nil
        }
    }

    var horizontalAlign: AdaptyUI.HorizontalAlign? {
        switch self {
        case let .text(text), let .textBullet(text): return text.horizontalAlign
        default: return nil
        }
    }

    func attributedString(
        bulletSpace: Double?,
        neighbourItemFont: AdaptyUI.Font?,
        paragraph: AdaptyUI.Text.ParagraphStyle,
        kern: CGFloat?,
        tagConverter: AdaptyUI.Text.CustomTagConverter?,
        productTagConverter: AdaptyUI.Text.ProductTagConverter?
    ) -> NSAttributedString? {
        switch self {
        case let .text(text):
            guard var resultText = text.value else {
                return nil
            }

            if text.hasTags {
                resultText = resultText.replaceCustomTags(converter: tagConverter, fallback: text.fallback)
            }

            if let productTagConverter = productTagConverter {
                if let convertedText = resultText.replaceProductTags(converter: productTagConverter) {
                    resultText = convertedText
                } else {
                    return nil
                }
            }

            return resultText.attributedString(using: text,
                                               paragraph: paragraph,
                                               kern: kern,
                                               trailingPadding: nil)
        case let .textBullet(text):
            return text.attributedString(
                paragraph: paragraph,
                kern: kern,
                trailingPadding: (bulletSpace ?? 0.0) - text.calculatedWidth()
            )
        case .newline:
            return NSAttributedString(string: "\n")
        case let .image(image):
            return image.attributedString(
                paragraph: paragraph,
                font: neighbourItemFont,
                trailingPadding: nil
            )
        case let .imageBullet(image):
            return image.attributedString(
                paragraph: paragraph,
                font: neighbourItemFont,
                trailingPadding: (bulletSpace ?? 0.0) - image.size.width
            )
        case let .space(width):
            let padding = NSTextAttachment()
            padding.bounds = CGRect(x: 0, y: 0, width: width, height: 0)
            return NSAttributedString(attachment: padding)
        }
    }
}

extension String {
    func attributedString(
        using text: AdaptyUI.CompoundText,
        paragraph: AdaptyUI.Text.ParagraphStyle = .init(),
        kern: CGFloat? = nil
    ) -> NSAttributedString {
        guard case let .text(text) = text.items.first else { return NSAttributedString(string: self) }
        return attributedString(using: text, paragraph: paragraph, kern: kern, trailingPadding: nil)
    }

    func attributedString(
        using text: AdaptyUI.Text,
        paragraph: AdaptyUI.Text.ParagraphStyle,
        kern: CGFloat?,
        trailingPadding: CGFloat?
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: self))

        if let trailingPadding = trailingPadding, trailingPadding > 0.0 {
            let padding = NSTextAttachment()
            padding.bounds = CGRect(x: 0, y: 0, width: trailingPadding, height: 0)
            result.append(NSAttributedString(attachment: padding))
        }

        result.addAttributes([
            NSAttributedString.Key.paragraphStyle: paragraph
                .copyWith(alignment: text.horizontalAlign.textAlignment)
                .toParagraphStyle(),
            NSAttributedString.Key.foregroundColor: text.uiColor ?? .darkText,
            NSAttributedString.Key.font: text.uiFont ?? .systemFont(ofSize: 15),
        ], range: NSRange(location: 0, length: result.length))

        if let kern = kern {
            result.addAttributes([
                NSAttributedString.Key.kern: kern,
            ], range: NSRange(location: 0, length: result.length))
        }

        return result
    }
}

extension AdaptyUI.CompoundText {
    func attributedString(
        paragraph: AdaptyUI.Text.ParagraphStyle = .init(),
        kern: CGFloat? = nil,
        tagConverter: AdaptyUI.Text.CustomTagConverter?,
        productTagConverter: AdaptyUI.Text.ProductTagConverter? = nil
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for i in 0 ..< items.count {
            let item = items[i]

            let previousItem = i > 0 ? items[i - 1] : nil
            let nextItem = i < items.count - 1 ? items[i + 1] : nil

            let neighbourAlign = nextItem?.horizontalAlign ?? previousItem?.horizontalAlign

            if let attributedString = item.attributedString(
                bulletSpace: bulletSpace,
                neighbourItemFont: nextItem?.font ?? previousItem?.font,
                paragraph: paragraph.copyWith(alignment: neighbourAlign?.textAlignment,
                                              headIndent: paragraph.headIndent + CGFloat(bulletSpace ?? 0.0)),
                kern: kern,
                tagConverter: tagConverter,
                productTagConverter: productTagConverter
            ) {
                if i > 0 && item.isBullet && !(previousItem?.isNewline ?? true) {
                    result.append(NSAttributedString(string: "\n"))
                }

                result.append(attributedString)
            }
        }

        return result
    }
}
