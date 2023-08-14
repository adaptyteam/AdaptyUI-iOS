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

extension UIEdgeInsets {
    static let closeButtonDefaultMargin: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 16)
}

final class AdaptyButtonComponentView: UIButton {
    let component: AdaptyUI.Button
    let onTap: (AdaptyUI.ButtonAction?) -> Void

    private var gradientLayer: CAGradientLayer?
    private var contentView: UIView?

    init(component: AdaptyUI.Button,
         contentView: UIView? = nil,
         contentViewMargins: UIEdgeInsets? = nil,
         addProgressView: Bool = false,
         onTap: @escaping (AdaptyUI.ButtonAction?) -> Void) {
        self.component = component
        self.onTap = onTap

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true

        if let contentView {
            setupContentView(contentView, contentViewMargins)
        } else if let title = component.normal?.title?.attributedString() {
            setAttributedTitle(title, for: .normal)

            contentEdgeInsets = contentViewMargins ?? .zero
            titleLabel?.numberOfLines = 0
        }

        if addProgressView,
           case let .text(text) = component.normal?.title?.items.first(where: {
               guard case .text = $0 else { return false }
               return true
           }) {
            setAttributedTitle(NSAttributedString(string: ""), for: .disabled)
            setupActivityIndicator(color: text.fill?.asColor?.uiColor ?? .white)
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

    private weak var progressView: UIActivityIndicatorView?

    private func setupActivityIndicator(color: UIColor) {
        let progressView = UIActivityIndicatorView(style: .medium)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.color = color
        progressView.isHidden = true
        addSubview(progressView)

        addConstraints([
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        self.progressView = progressView
    }

    func updateContent(_ text: AdaptyUI.СompoundText?) {
        contentView?.removeFromSuperview()
        contentView = nil

        setAttributedTitle(text?.attributedString(), for: .normal)

        if #available(iOS 15.0, *) {
            var configuration: UIButton.Configuration = .borderless()
            configuration = .bordered()
            configuration.contentInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)

            self.configuration = configuration
        } else {
            contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
            titleEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        }
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

    private func updateShapeBorder(_ border: AdaptyUI.Shape.Border?) {
        layer.borderColor = border?.filling.asColor?.uiColor.cgColor
        layer.borderWidth = border?.thickness ?? 0.0
    }

    private func updateShapeMask(_ type: AdaptyUI.ShapeType?) {
        layer.applyShapeMask(type)
    }

    @objc
    private func buttonDidTouchUp() {
        onTap(component.action)
    }

    func updateInProgress(_ inProgress: Bool) {
        guard let progressView = progressView else { return }

        progressView.isHidden = !inProgress
        isEnabled = !inProgress

        if inProgress {
            progressView.startAnimating()
        } else {
            progressView.stopAnimating()
        }
    }
}
