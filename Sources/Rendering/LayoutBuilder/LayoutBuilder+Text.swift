//
//  LayoutBuilder+Text.swift
//
//
//  Created by Alexey Goncharov on 8.8.23..
//

import Adapty
import UIKit

extension LayoutBuilder {
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }

    func layoutTitleRows(_ text: AdaptyUI.CompoundText,
                         in stackView: UIStackView) throws {
        let lines = text.items.filter { !$0.isNewline }

        let rowsStackView = UIStackView()
        rowsStackView.axis = .vertical
        rowsStackView.spacing = 4.0

        for i in 0 ..< lines.count {
            let line = lines[i]

            let label = i == 0 ? Self.createTitleLabel() : Self.createSubtitleLabel()
            label.attributedText = line.attributedString(bulletSpace: 0.0,
                                                         neighbourItemFont: nil,
                                                         paragraph: .init(),
                                                         kern: nil,
                                                         tagConverter: nil)

            label.lineBreakMode = .byTruncatingTail

            rowsStackView.addArrangedSubview(label)
        }

        stackView.addArrangedSubview(rowsStackView)
    }

    func layoutText(_ text: AdaptyUI.CompoundText,
                    paragraph: AdaptyUI.Text.ParagraphStyle? = nil,
                    numberOfLines: Int = 0,
                    in stackView: UIStackView) throws {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = numberOfLines
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.attributedText = text.attributedString(paragraph: paragraph ?? .init())
        label.lineBreakMode = .byTruncatingTail

        stackView.addArrangedSubview(label)
    }
}
