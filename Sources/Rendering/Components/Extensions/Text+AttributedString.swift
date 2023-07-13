//
//  Text+AttributedString.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.Text {
    func attributedString(appendingNewLine: Bool = false) -> NSAttributedString {
        let text = (value ?? "") + (appendingNewLine ? "\n" : "")
        
        let color = uiColor ?? .darkText
        let font = uiFont ?? .systemFont(ofSize: 15)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = horizontalAlign.textAlignment

        let attributedString = NSMutableAttributedString()
        
        if let image = bullet?.uiImage {
            let imageSize = CGSize(width: 16, height: 16)
            let imagePadding = 8.0
            
//            paragraphStyle.paragraphSpacing = 10.0
            paragraphStyle.lineSpacing = 0.0
            paragraphStyle.firstLineHeadIndent = 0.0
            paragraphStyle.headIndent = imageSize.width + imagePadding
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = image
            imageAttachment.bounds = .init(x: 0,
                                           y: (font.capHeight - imageSize.height).rounded(.down) / 2.0,
                                           width: imageSize.width,
                                           height: imageSize.height)

            attributedString.append(NSAttributedString(attachment: imageAttachment))
            
            let padding = NSTextAttachment()
            padding.bounds = CGRect(x: 0, y: 0, width: imagePadding, height: 0)

            attributedString.append(NSAttributedString(attachment: padding))
        }
        
        attributedString.append(NSAttributedString(string: text))
        attributedString.addAttributes([
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.font: font,
        ], range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
        
//        return NSAttributedString(string: text,
//                                  attributes: [
//                                      NSAttributedString.Key.paragraphStyle: paragraphStyle,
//                                      NSAttributedString.Key.foregroundColor: color,
//                                      NSAttributedString.Key.font: font,
//                                  ])
    }
}

extension AdaptyUI.TextItems {
    func attributedString() -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        for i in 0 ..< items.count {
            result.append(items[i].attributedString(appendingNewLine: i < items.count - 1))
        }
        
        return result
    }
}
