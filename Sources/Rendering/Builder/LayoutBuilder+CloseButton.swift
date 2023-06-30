//
//  LayoutBuilder+CloseButton.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import UIKit

extension LayoutBuilder {
    func layoutCloseButton(
        _ button: AdaptyButtonComponentView,
        on superview: UIView
    ) {
        superview.addSubview(button)
        superview.addConstraints([
            button.widthAnchor.constraint(equalToConstant: 40.0),
            button.heightAnchor.constraint(equalToConstant: 40.0),
            button.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: 16.0),
        ])

        switch button.component.align {
        case .leading:
            button.leadingAnchor.constraint(
                equalTo: superview.leadingAnchor,
                constant: 16.0
            ).isActive = true
        case .trailing:
            button.trailingAnchor.constraint(
                equalTo: superview.trailingAnchor,
                constant: -16.0
            ).isActive = true
        default:
            button.centerXAnchor.constraint(
                equalTo: superview.centerXAnchor
            ).isActive = true
        }
    }
}
