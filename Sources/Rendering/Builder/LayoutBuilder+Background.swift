//
//  File.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import UIKit

final class AdaptyBackgroundComponentView: UIImageView {
    private let background: BackgroundTBU

    init(background: BackgroundTBU) {
        self.background = background

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFill

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var gradientLayer: CAGradientLayer?

    private func setupView() {
        switch background {
        case let .color(color):
            backgroundColor = color.uiColor
            image = nil
        case let .image(img):
            backgroundColor = nil
            image = img.uiImage
        case let .gradient(gradient):
            backgroundColor = nil
            image = nil

            let gradientLayer = CAGradientLayer.create(gradient)
            layer.insertSublayer(gradientLayer, at: 0)
            self.gradientLayer = gradientLayer
        }
    }
}

extension LayoutBuilder {
    func layoutBackground(_ backgroundView: AdaptyBackgroundComponentView,
                          on view: UIView) {
        view.addSubview(backgroundView)
        view.addConstraints([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
        ])
    }
}
