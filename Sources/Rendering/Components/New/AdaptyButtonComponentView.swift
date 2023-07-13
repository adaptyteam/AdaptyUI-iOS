//
//  AdaptyButtonComponentView.swift
//
//
//  Created by Alexey Goncharov on 27.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.Button {
    func getStateShape(_ isSelected: Bool) -> AdaptyUI.Shape? {
        if isSelected, let selected {
            return selected.shape
        } else {
            return normal?.shape
        }
    }
}

final class AdaptyButtonComponentView: UIButton {
    let component: AdaptyUI.Button

    var onTap: ((AdaptyUI.ButtonAction?) -> Void)?

    private var gradientLayer: CAGradientLayer?
    private var contentView: UIView?

    init(component: AdaptyUI.Button,
         contentView: UIView? = nil,
         contentViewMargins: UIEdgeInsets? = nil) {
        self.component = component

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true

        if let contentView {
            setupContentView(contentView, contentViewMargins)
        } else if let title = component.normal?.title?.asText?.attributedString() {
            setAttributedTitle(title, for: .normal)
        }

        addTarget(self, action: #selector(buttonDidTouchUp), for: .touchUpInside)

        let shape = component.getStateShape(false)

        updateShapeMask(shape?.type)
        updateShapeBackground(shape?.background)
        updateShapeBorder(shape?.border)
    }

    private func setupContentView(_ view: UIView, _ margins: UIEdgeInsets?) {
        if let contentView {
            contentView.removeFromSuperview()
        }
        
        view.isUserInteractionEnabled = false

        addSubview(view)
        addConstraints([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margins?.left ?? 0.0),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(margins?.right ?? 0.0)),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(margins?.bottom ?? 0.0)),
            view.topAnchor.constraint(equalTo: topAnchor, constant: margins?.top ?? 0.0),
        ])

        contentView = view
    }

    func updateContent(_ textItems: AdaptyUI.TextItems?) {
        contentView?.removeFromSuperview()
        contentView = nil

        setAttributedTitle(textItems?.asText?.attributedString(), for: .normal)
    }

    func updateContent(_ view: UIView, margins: UIEdgeInsets?) {
        setupContentView(view, margins)
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

        let shape = component.getStateShape(isSelected)

        updateShapeMask(shape?.type)
        updateShapeBackground(shape?.background)
        updateShapeBorder(shape?.border)
    }

    private func updateShapeBackground(_ filling: AdaptyUI.Filling?) {
        guard let filling else {
            backgroundColor = .clear
            return
        }

        switch filling {
        case let .color(color):
            backgroundColor = color.uiColor
        case let .image(image):
            if currentBackgroundImage == nil {
                setBackgroundImage(image.uiImage, for: .normal)
            }
            backgroundColor = .clear
        case let .colorLinearGradient(gradient):
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

    private func updateShapeBorder(_ border: AdaptyUI.Shape.Border?) {
        layer.borderColor = border?.filling.asColor?.uiColor.cgColor
        layer.borderWidth = border?.thickness ?? 0.0
    }

    private func updateShapeMask(_ type: AdaptyUI.ShapeType?) {
        guard let type else {
            backgroundColor = .clear
            layer.mask = nil
            return
        }

        switch type {
        case let .rectangle(cornerRadius):
            // TODO: support corners
            layer.cornerRadius = cornerRadius.value ?? 0.0
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
        onTap?(component.action)
    }
}
