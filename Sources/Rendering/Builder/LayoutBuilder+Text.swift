//
//  LayoutBuilder+Text.swift
//
//
//  Created by Alexey Goncharov on 8.8.23..
//

import Adapty
import UIKit

extension LayoutBuilder {
    func layoutText(_ text: AdaptyUI.СompoundText, in stackView: UIStackView) throws {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = text.attributedString()
        label.numberOfLines = 0

        stackView.addArrangedSubview(label)
    }
}

extension LayoutBuilder {
    func layoutProgressView(_ view: AdaptyActivityIndicatorView, on superview: UIView) {
        superview.addSubview(view)
        superview.addConstraints([
            view.topAnchor.constraint(equalTo: superview.topAnchor),
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        ])
    }
}
