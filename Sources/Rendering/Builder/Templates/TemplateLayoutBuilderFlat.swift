//
//  TemplateLayoutBuilderFlat.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

class TemplateLayoutBuilderFlat: LayoutBuilder {
    private let background: AdaptyUI.Filling
    private let contentShape: AdaptyUI.Shape
    private let coverImage: AdaptyUI.Shape
    private let coverImageHeightMultilpyer: CGFloat
    private let titleRows: AdaptyUI.СompoundText?
    private let featuresBlock: AdaptyUI.FeaturesBlock?
    private let productsBlock: AdaptyUI.ProductsBlock
    private let purchaseButton: AdaptyUI.Button
    private let footerBlock: AdaptyUI.FooterBlock?
    private let closeButton: AdaptyUI.Button?
    private let initialProducts: [ProductInfo]
    
    init(
        background: AdaptyUI.Filling,
        contentShape: AdaptyUI.Shape,
        coverImage: AdaptyUI.Shape,
        coverImageHeightMultilpyer: CGFloat,
        titleRows: AdaptyUI.СompoundText?,
        featuresBlock: AdaptyUI.FeaturesBlock?,
        productsBlock: AdaptyUI.ProductsBlock,
        purchaseButton: AdaptyUI.Button,
        footerBlock: AdaptyUI.FooterBlock?,
        closeButton: AdaptyUI.Button?,
        initialProducts: [ProductInfo]
    ) {
        self.background = background
        self.contentShape = contentShape
        self.coverImage = coverImage
        self.coverImageHeightMultilpyer = coverImageHeightMultilpyer
        self.titleRows = titleRows
        self.featuresBlock = featuresBlock
        self.productsBlock = productsBlock
        self.purchaseButton = purchaseButton
        self.footerBlock = footerBlock
        self.closeButton = closeButton
        self.initialProducts = initialProducts
    }

    private weak var contentViewComponentView: AdaptyBaseContentView?
    private weak var productsComponentView: ProductsComponentView?
    private weak var continueButtonComponentView: AdaptyButtonComponentView?

    private var onActionCallback: ((AdaptyUI.ButtonAction) -> Void)?

    var productsView: ProductsComponentView? { productsComponentView }
    var continueButton: AdaptyButtonComponentView? { continueButtonComponentView }

    func onAction(_ callback: @escaping (AdaptyUI.ButtonAction) -> Void) {
        onActionCallback = callback
    }

    func buildInterface(on view: UIView) throws {
        let backgroundView = AdaptyBackgroundComponentView(background: background)
        layoutBackground(backgroundView, on: view)

        let scrollView = AdaptyBaseScrollView()
        AdaptyInterfaceBilder.layoutScrollView(scrollView, on: view)

        let contentView = AdaptyBaseContentView(
            layout: .flat,
            shape: contentShape
        )

        layoutContentView(contentView, on: scrollView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView, inset: UIEdgeInsets(top: 48,
                                                                 left: 24,
                                                                 bottom: 24,
                                                                 right: 24))

        let imageView = AdaptyTitleImageComponentView(shape: coverImage)

        layoutTitleImageView(imageView,
                             on: stackView,
                             superView: view,
                             multiplier: coverImageHeightMultilpyer)

        if let titleRows {
            try layoutText(titleRows, in: stackView)
        }

        if let featuresBlock {
            try layoutFeaturesBlock(featuresBlock, in: stackView)
        }

        productsComponentView = try layoutProductsBlock(productsBlock,
                                                        initialProducts: initialProducts,
                                                        in: stackView)

        let continueButtonPlaceholder = UIView()
        continueButtonPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        continueButtonPlaceholder.backgroundColor = .clear

        stackView.addArrangedSubview(continueButtonPlaceholder)
        stackView.addConstraint(
            continueButtonPlaceholder.heightAnchor.constraint(equalToConstant: 58.0)
        )

        let continueButtonView = AdaptyButtonComponentView(component: purchaseButton)
        layoutContinueButton(continueButtonView,
                             placeholder: continueButtonPlaceholder,
                             on: view)

        continueButtonComponentView = continueButtonView
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
//            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor,
//                                                multiplier: 1.0),
        ])
    }
}
