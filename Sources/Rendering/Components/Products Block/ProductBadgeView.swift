//
//  ProductBadgeView.swift
//
//
//  Created by Alexey Goncharov on 16.8.23..
//

import Adapty
import UIKit

class ProductBadgeView: UIView {
    let text: AdaptyUI.CompoundText
    let shape: AdaptyUI.Shape?

    init(
        text: AdaptyUI.CompoundText,
        shape: AdaptyUI.Shape?
    ) throws {
        self.text = text
        self.shape = shape

        super.init(frame: .zero)

        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false

        applyFilling(shape?.background)
        layer.applyShapeMask(shape?.type)

        let tagLabel = AdaptyInsetLabel()

        tagLabel.translatesAutoresizingMaskIntoConstraints = false
//        tagLabel.insets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
        tagLabel.attributedText = text.attributedString(kern: 0.2)

        addSubview(tagLabel)
        addConstraints([
            tagLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0),
            tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
            tagLabel.topAnchor.constraint(equalTo: topAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private var gradientLayer: CAGradientLayer?
    private var imageView: UIImageView?

    func applyFilling(_ filling: AdaptyUI.Filling?) {
        guard let filling = filling else {
            backgroundColor = .clear
            return
        }

        switch filling {
        case let .color(color):
            backgroundColor = color.uiColor
        case let .image(image):
            backgroundColor = .clear
            if let imageView = imageView {
                imageView.image = image.uiImage
            } else {
                let imageView = UIImageView(image: image.uiImage)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                addConstraints([
                    imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    imageView.topAnchor.constraint(equalTo: topAnchor),
                    imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
            }
        case let .colorGradient(gradient):
            if let gradientLayer = gradientLayer {
                gradientLayer.frame = bounds
            } else {
                let gradientLayer = CAGradientLayer.create(gradient)
                gradientLayer.frame = bounds
                layer.insertSublayer(gradientLayer, at: 0)
                self.gradientLayer = gradientLayer
            }
            backgroundColor = .clear
        }
    }
}
