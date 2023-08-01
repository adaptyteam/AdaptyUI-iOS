//
//  File.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

class TemplateLayoutBuilderTransparent: LayoutBuilder {
    private let background: AdaptyUI.Filling
    private let contentShape: AdaptyUI.Shape
    private let titleRows: AdaptyUI.TextItems?
    private let featuresBlock: AdaptyUI.FeaturesBlock?
    private let productsBlock: AdaptyUI.ProductsBlock
    private let purchaseButton: AdaptyUI.Button
    private let footerBlock: AdaptyUI.FooterBlock?
    private let closeButton: AdaptyUI.Button?

    init(background: AdaptyUI.Filling,
         contentShape: AdaptyUI.Shape,
         titleRows: AdaptyUI.TextItems?,
         featuresBlock: AdaptyUI.FeaturesBlock?,
         productsBlock: AdaptyUI.ProductsBlock,
         purchaseButton: AdaptyUI.Button,
         footerBlock: AdaptyUI.FooterBlock?,
         closeButton: AdaptyUI.Button?) {
        self.background = background
        self.contentShape = contentShape
        self.titleRows = titleRows
        self.featuresBlock = featuresBlock
        self.productsBlock = productsBlock
        self.purchaseButton = purchaseButton
        self.footerBlock = footerBlock
        self.closeButton = closeButton
    }

    private weak var contentViewComponentView: AdaptyBaseContentView?

    private var onActionCallback: ((AdaptyUI.ButtonAction) -> Void)?

    func onAction(_ callback: @escaping (AdaptyUI.ButtonAction) -> Void) {
        onActionCallback = callback
    }

    func buildInterface(on view: UIView) throws {
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
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView,
                                  inset: UIEdgeInsets(top: 48,
                                                      left: 24,
                                                      bottom: 24,
                                                      right: 24),
                                  layout: .bottomToTop)

        if let titleRows {
            let titleRowsView = AdaptyTextItemsComponentView(textItems: titleRows)
            stackView.addArrangedSubview(titleRowsView)
        }

        if let featuresBlock {
            switch featuresBlock.type {
            case .list:
                guard let items = featuresBlock.items["list"]?.asTextItems else {
                    throw AdaptyUIError.componentNotFound("list")
                }

                let featuresListView = AdaptyTextItemsComponentView(textItems: items)
                stackView.addArrangedSubview(featuresListView)
            case .timeline:
                let featuresTimelineView = try AdaptyTimelineComponentView(block: featuresBlock)
                stackView.addArrangedSubview(featuresTimelineView)
            }
        }

        let productsView = try AdaptyProductsComponentView(productsBlock: productsBlock)
        stackView.addArrangedSubview(productsView)

        let continueButtonView = AdaptyButtonComponentView(component: purchaseButton)

        stackView.addArrangedSubview(continueButtonView)
        stackView.addConstraint(
            continueButtonView.heightAnchor.constraint(equalToConstant: 58.0)
        )

        contentViewComponentView = contentView

        if let footerBlock {
            let footerView = try AdaptyFooterComponentView(footerBlock: footerBlock)
            stackView.addArrangedSubview(footerView)
        }

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
