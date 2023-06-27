//
//  AdaptyButtonComponentView.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import Adapty
import UIKit

extension CAShapeLayer {
    static func circleLayer(in rect: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.backgroundColor = UIColor.clear.cgColor

        let radius = min(rect.height, rect.width) / 2.0

        layer.path = UIBezierPath(arcCenter: .init(x: rect.midX, y: rect.midY),
                                  radius: radius,
                                  startAngle: 0.0,
                                  endAngle: .pi * 2.0,
                                  clockwise: true).cgPath

        return layer
    }
}

extension CAGradientLayer {
    static func create(_ asset: any LinarGradientAsset) -> CAGradientLayer {
        let layer = CAGradientLayer()

        layer.colors = asset.values.map { $0.1.cgColor }
        layer.locations = asset.values.map { NSNumber(floatLiteral: $0.0) }
        layer.startPoint = CGPoint(x: asset.startPoint.0, y: asset.startPoint.1)
        layer.endPoint = CGPoint(x: asset.endPoint.0, y: asset.endPoint.1)

        return layer
    }
}

extension TextComponent {
    var attributedString: NSAttributedString? {
        let text = value ?? ""
        let color = uiColor ?? .darkText
        let font = uiFont ?? .systemFont(ofSize: 15)

        return NSAttributedString(string: text,
                                  attributes: [
                                      NSAttributedString.Key.foregroundColor: color,
                                      NSAttributedString.Key.font: font,
                                  ])
    }
}

final class AdaptyButtonComponentView: UIButton {
    private let component: any ButtonComponent
    private let onTap: () -> Void

    init(component: any ButtonComponent, onTap: @escaping () -> Void) {
        self.component = component
        self.onTap = onTap

        super.init(frame: .zero)

        layer.masksToBounds = true

        setAttributedTitle(component.text?.attributedString, for: .normal)

//        setTitle(component.text?.value, for: .normal)
//        setTitleColor(component.text?.uiColor, for: .normal)

        addTarget(self, action: #selector(buttonDidTouchUp), for: .touchUpInside)

        translatesAutoresizingMaskIntoConstraints = false

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
        onTap()
    }
}
