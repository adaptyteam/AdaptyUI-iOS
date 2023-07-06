//
//  File.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import UIKit
import Adapty

class TemplateLayoutBuilderTransparent: LayoutBuilder {
    private let background: AdaptyUI.Filling
    private let contentShape: AdaptyUI.Shape
    private let purchaseButton: AdaptyUI.Button
    private let closeButton: AdaptyUI.Button?
    
    init(background: AdaptyUI.Filling,
         contentShape: AdaptyUI.Shape,
         purchaseButton: AdaptyUI.Button,
         closeButton: AdaptyUI.Button?) {
        self.background = background
        self.contentShape = contentShape
        self.purchaseButton = purchaseButton
        self.closeButton = closeButton
    }

    private weak var contentViewComponentView: AdaptyBaseContentView?
    private weak var closeButtonComponentView: AdaptyButtonComponentView?

    func onCloseButtonPressed(_ callback: @escaping () -> Void) {
        closeButtonComponentView?.onTap = callback
    }

    func buildInterface(on view: UIView) {
        let backgroundView = AdaptyBackgroundComponentView(background: background)
        layoutBackground(backgroundView, on: view)

        let scrollView = AdaptyBaseScrollView()
        AdaptyInterfaceBilder.layoutScrollView(scrollView, on: view)

        let contentView = AdaptyBaseContentView(
            layout: .transparent,
            shape: contentShape
        )

        layoutContentView(contentView, on: scrollView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 64.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView, inset: UIEdgeInsets(top: 48,
                                                                 left: 24,
                                                                 bottom: 24,
                                                                 right: 24))

        let continueButtonView = AdaptyButtonComponentView(component: purchaseButton)
        stackView.addArrangedSubview(continueButtonView)
        stackView.addConstraint(
            continueButtonView.heightAnchor.constraint(equalToConstant: 58.0)
        )

        contentViewComponentView = contentView

        if let component = closeButton {
            let closeButton = AdaptyButtonComponentView(component: component)
            layoutCloseButton(closeButton, on: view)
            closeButtonComponentView = closeButton
        }
    }

    func viewDidLayoutSubviews(_ view: UIView) {
        contentViewComponentView?.updateSafeArea(view.safeAreaInsets)
    }

    // MARK: - Layout

    private func layoutContentView(_ contentView: AdaptyBaseContentView,
                                   on scrollView: UIScrollView) {
        scrollView.addSubview(contentView)

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
