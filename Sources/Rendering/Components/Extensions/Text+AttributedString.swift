//
//  Text+AttributedString.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.Text {
    struct ParagraphStyle {
        let alignment: NSTextAlignment
        let lineSpacing: CGFloat
        let paragraphSpacing: CGFloat
        let firstLineHeadIndent: CGFloat
        let headIndent: CGFloat

        init(
            alignment: NSTextAlignment = .center,
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

    func attributedString(paragraph: AdaptyUI.Text.ParagraphStyle,
                          trailingPadding: CGFloat?) -> NSAttributedString? {
        guard let value = value else { return nil }

        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: value))

        if let trailingPadding, trailingPadding > 0.0 {
            let padding = NSTextAttachment()
            padding.bounds = CGRect(x: 0, y: 0, width: trailingPadding, height: 0)
            result.append(NSAttributedString(attachment: padding))
        }

        result.addAttributes([
            NSAttributedString.Key.paragraphStyle: paragraph
                .copyWith(alignment: horizontalAlign.textAlignment)
                .toParagraphStyle(),
            NSAttributedString.Key.foregroundColor: uiColor ?? .darkText,
            NSAttributedString.Key.font: uiFont ?? .systemFont(ofSize: 15),
        ], range: NSRange(location: 0, length: result.length))

        return result
    }
}

extension AdaptyUI.Text.Image {
    func formAttachment(font: AdaptyUI.Font?) -> NSTextAttachment? {
        guard let data, var image = UIImage(data: data) else { return nil }

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
        paragraph: AdaptyUI.Text.ParagraphStyle
    ) -> NSAttributedString? {
        switch self {
        case let .text(text):
            return text.attributedString(
                paragraph: paragraph,
                trailingPadding: nil
            )
        case let .textBullet(text):
            return text.attributedString(
                paragraph: paragraph,
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

extension AdaptyUI.СompoundText {
    func attributedString(
        overridingValue: String? = nil,
        appendingNewLine: Bool = false,
        paragraph: AdaptyUI.Text.ParagraphStyle = .init()
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
                                              headIndent: paragraph.headIndent + CGFloat(bulletSpace ?? 0.0))
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
