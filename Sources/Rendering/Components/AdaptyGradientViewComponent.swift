//
//  AdaptyGradientViewComponent.swift
//
//
//  Created by Alexey Goncharov on 2023-01-25.
//

import UIKit

class AdaptyGradientViewComponent: UIView {
    init() {
        super.init(frame: .zero)

        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var gradientLayer: CAGradientLayer!

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            CGColor(gray: 17.0 / 255.0, alpha: 0.26),
            CGColor(gray: 17.0 / 255.0, alpha: 0.0),
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = bounds

        layer.addSublayer(gradientLayer)

        self.gradientLayer = gradientLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
    }
}
