//
//  AdaptyProductPlaceholderComponent.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Adapty
import UIKit

class AdaptyProductPlaceholderComponent: UIView {
    private let color: AdaptyUI.Color

    init(color: AdaptyUI.Color) {
        self.color = color

        super.init(frame: .zero)

        setupView()
        setupConstraints()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var underlayView: UIView!

    private func setupView() {
        let underlayView = UIView()
        underlayView.translatesAutoresizingMaskIntoConstraints = false
        underlayView.backgroundColor = color.uiColor
        underlayView.layer.masksToBounds = true
        underlayView.layer.cornerRadius = 8.0

        addSubview(underlayView)

        self.underlayView = underlayView
    }

    private func setupConstraints() {
        addConstraints([
            underlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlayView.heightAnchor.constraint(equalToConstant: 64.0),
            heightAnchor.constraint(equalToConstant: 74.0),
        ])
    }
}
