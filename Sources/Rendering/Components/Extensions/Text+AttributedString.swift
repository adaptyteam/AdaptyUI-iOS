//
//  Text+AttributedString.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.Text {
    var attributedString: NSAttributedString? {
        let text = value ?? ""
        let color = uiColor ?? .darkText
        let font = uiFont ?? .systemFont(ofSize: 15)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = horizontalAlign.textAlignment

        let attributedString = NSMutableAttributedString()
        
//        if let image = bullet?.uiImage {
//            paragraphStyle.firstLineHeadIndent = 10.0
//            paragraphStyle.headIndent = 0
//            
//            let imageSize = CGSize(width: 16, height: 16)
//            let imageAttachment = NSTextAttachment()
//            imageAttachment.image = image
//            imageAttachment.bounds = .init(x: 0,
//                                           y: (font.capHeight - imageSize.height).rounded(.down) / 2.0,
//                                           width: imageSize.width,
//                                           height: imageSize.height)
//            
//            attributedString.append(NSAttributedString(attachment: imageAttachment))
//            
//            let padding = NSTextAttachment()
//            padding.bounds = CGRect(x: 0, y: 0, width: 8, height: 0)
//                        
//            attributedString.append(NSAttributedString(attachment: padding))
//        }
        
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
