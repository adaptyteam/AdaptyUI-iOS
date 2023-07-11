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
    
    private var onActionCallback: ((AdaptyUI.ButtonAction) -> Void)?
    
    func onAction(_ callback: @escaping (AdaptyUI.ButtonAction) -> Void) {
        onActionCallback = callback
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

        if let closeButton {
            let closeButtonView = AdaptyButtonComponentView(component: closeButton)
            closeButtonView.onTap = { [weak self] _ in
                self?.onActionCallback?(.close)
            }
            
            layoutCloseButton(closeButtonView, on: view)
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
