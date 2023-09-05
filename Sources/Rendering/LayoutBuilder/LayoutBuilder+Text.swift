//
//  LayoutBuilder+Text.swift
//
//
//  Created by Alexey Goncharov on 8.8.23..
//

import Adapty
import UIKit

extension LayoutBuilder {
    func layoutText(_ text: AdaptyUI.CompoundText,
                    paragraph: AdaptyUI.Text.ParagraphStyle? = nil,
                    in stackView: UIStackView) throws {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = text.attributedString(paragraph: paragraph ?? .init())
        label.numberOfLines = 0

        stackView.addArrangedSubview(label)
    }
}
