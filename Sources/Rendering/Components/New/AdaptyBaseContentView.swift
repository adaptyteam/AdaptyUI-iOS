//
//  AdaptyBaseContentView.swift
//
//
//  Created by Alexey Goncharov on 29.6.23..
//

import UIKit

enum ContentLayout {
    case basic(multiplier: CGFloat)
    case transparent
    case flat
}

final class AdaptyBaseContentView: UIView {
    let layout: ContentLayout
    let shape: ShapeComponent

    init(layout: ContentLayout, shape: ShapeComponent) {
        self.layout = layout
        self.shape = shape

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Mask & Background

    private func updateMask() {
        switch shape.mask {
        case .rect:
            layer.cornerRadius = shape.rectCornerRadius ?? 0.0
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .curveUp:
            layer.mask = CAShapeLayer.curveUpShapeLayer(in: bounds)
        case .curveDown:
            layer.mask = CAShapeLayer.curveDownShapeLayer(in: bounds)
        case .circle:
            break
        }

        layer.masksToBounds = true
    }

    private var gradientLayer: CAGradientLayer?

    private func updateBackground() {
        switch shape.background {
        case let .color(color):
            backgroundColor = color.uiColor
        case let .gradient(gradient):
            backgroundColor = .clear
            if let gradientLayer {
                gradientLayer.frame = bounds
            } else {
                let gradientLayer = CAGradientLayer.create(gradient)
                gradientLayer.frame = bounds
                layer.insertSublayer(gradientLayer, at: 0)
                self.gradientLayer = gradientLayer
            }
        default:
            break
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        updateMask()
        updateBackground()
    }

    private var contentInset: UIEdgeInsets = .zero
    private var contentTopConstraint: NSLayoutConstraint!
    private var contentBottomConstraint: NSLayoutConstraint!

    func updateSafeArea(_ insets: UIEdgeInsets) {
        switch layout {
        case .basic:
            contentBottomConstraint.constant = -(insets.bottom + contentInset.bottom)
        case .transparent, .flat:
            contentTopConstraint.constant = insets.top + contentInset.top
            contentBottomConstraint.constant = -(insets.bottom + contentInset.bottom)
        }
    }

    func layoutContent(_ view: UIView, inset: UIEdgeInsets) {
        contentInset = inset

        contentTopConstraint = view.topAnchor.constraint(equalTo: topAnchor,
                                                         constant: inset.top)
        contentBottomConstraint = view.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                               constant: -inset.bottom)

        addSubview(view)
        addConstraints([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset.left),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset.right),
            contentTopConstraint,
            contentBottomConstraint,
        ])
    }
}

extension AdaptyInterfaceBilder {
    static func layoutContentView(
        _ contentView: AdaptyBaseContentView,
        on scrollView: UIScrollView) {
//            contentView.translatesAutoresizingMaskIntoConstraints = false
//            contentView.backgroundColor = .white
        scrollView.addSubview(contentView)

        switch contentView.layout {
        case let .basic(multiplier):
            let spacerView = UIView()
            spacerView.translatesAutoresizingMaskIntoConstraints = false
            spacerView.backgroundColor = .clear

            scrollView.addSubview(spacerView)
            scrollView.addConstraints([
                spacerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                spacerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                spacerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                spacerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor,
                                                   multiplier: multiplier),
            ])

            scrollView.addConstraints([
                contentView.topAnchor.constraint(equalTo: spacerView.bottomAnchor),

                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            ])
        case .transparent:
            scrollView.addConstraints([
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),

                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            ])
        case .flat:
            scrollView.addConstraints([
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),

                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor,
                                                    multiplier: 1.0),
            ])
        }
    }
}
