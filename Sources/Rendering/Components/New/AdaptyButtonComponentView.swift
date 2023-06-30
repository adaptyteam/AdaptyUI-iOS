//
//  AdaptyButtonComponentView.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import Adapty
import UIKit

final class AdaptyButtonComponentView: UIButton {
    let component: any ButtonComponent
    
    var onTap: (() -> Void)?

    init(component: any ButtonComponent) {
        self.component = component

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true

        setAttributedTitle(component.text?.attributedString, for: .normal)
        addTarget(self, action: #selector(buttonDidTouchUp), for: .touchUpInside)

        updateShapeBackground()
        updateShapeMask()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(
                withDuration: 0.25,
                delay: 0,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: {
                    self.alpha = self.isHighlighted ? 0.5 : 1
                },
                completion: nil)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateShapeMask()
        updateShapeBackground()
    }

    private var gradientLayer: CAGradientLayer?

    private func updateShapeBackground() {
        guard let background = component.shape?.background else {
            backgroundColor = .clear
            return
        }

        switch background {
        case let .color(color):
            backgroundColor = color.uiColor
        case let .image(image):
            setBackgroundImage(image.uiImage, for: .normal)
            backgroundColor = .clear
        case let .gradient(gradient):
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

    private func updateShapeMask() {
        guard let mask = component.shape?.mask else {
            backgroundColor = .clear
            layer.mask = nil
            return
        }

        switch mask {
        case .rect:
            layer.cornerRadius = component.shape?.rectCornerRadius ?? 0.0
        case .circle:
            layer.mask = CAShapeLayer.circleLayer(in: bounds)
            layer.mask?.backgroundColor = UIColor.red.cgColor
            break
        default:
            break
        }
    }

    @objc
    private func buttonDidTouchUp() {
        onTap?()
    }
}
