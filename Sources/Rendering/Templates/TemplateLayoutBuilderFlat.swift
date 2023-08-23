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
    private let titleRows: AdaptyUI.CompoundText?
    private let featuresBlock: AdaptyUI.FeaturesBlock?
    private let productsBlock: AdaptyUI.ProductsBlock
    private let purchaseButton: AdaptyUI.Button
    private let footerBlock: AdaptyUI.FooterBlock?
    private let closeButton: AdaptyUI.Button?
    private let initialProducts: [ProductInfoModel]

    private let scrollViewDelegate = AdaptyCompoundScrollViewDelegate()

    init(
        background: AdaptyUI.Filling,
        contentShape: AdaptyUI.Shape,
        coverImage: AdaptyUI.Shape,
        coverImageHeightMultilpyer: CGFloat,
        titleRows: AdaptyUI.CompoundText?,
        featuresBlock: AdaptyUI.FeaturesBlock?,
        productsBlock: AdaptyUI.ProductsBlock,
        purchaseButton: AdaptyUI.Button,
        footerBlock: AdaptyUI.FooterBlock?,
        closeButton: AdaptyUI.Button?,
        initialProducts: [ProductInfoModel]
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

    private weak var activityIndicatorComponentView: AdaptyActivityIndicatorView?
    private weak var contentViewComponentView: AdaptyBaseContentView?
    private weak var productsComponentView: ProductsComponentView?
    private weak var continueButtonComponentView: AdaptyButtonComponentView?
    private weak var scrollView: AdaptyBaseScrollView?

    var activityIndicator: AdaptyActivityIndicatorView? { activityIndicatorComponentView }
    var productsView: ProductsComponentView? { productsComponentView }
    var continueButton: AdaptyButtonComponentView? { continueButtonComponentView }

    private var onContinueCallback: (() -> Void)?
    private var onActionCallback: ((AdaptyUI.ButtonAction?) -> Void)?

    func addListeners(
        onContinue: @escaping () -> Void,
        onAction: @escaping (AdaptyUI.ButtonAction?) -> Void
    ) {
        onContinueCallback = onContinue
        onActionCallback = onAction
    }

    func buildInterface(on view: UIView) throws {
        scrollViewDelegate.behaviours.append(
            AdaptyLimitOverscrollScrollBehaviour()
        )

        let backgroundView = AdaptyBackgroundComponentView(background: background)
        layoutBackground(backgroundView, on: view)

        let scrollView = AdaptyBaseScrollView()
        scrollView.insetsLayoutMarginsFromSafeArea = false
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false

        scrollView.delegate = scrollViewDelegate
        layoutScrollView(scrollView, on: view)

        self.scrollView = scrollView

        let contentView = AdaptyBaseContentView(
            layout: .flat,
            shape: contentShape
        )

        layoutContentView(contentView, on: scrollView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView, inset: UIEdgeInsets(top: 0,
                                                                 left: 24,
                                                                 bottom: 24,
                                                                 right: 24))

        let imageView = AdaptyTitleImageComponentView(shape: coverImage)

        layoutTitleImageView(imageView,
                             on: stackView,
                             superView: view,
                             multiplier: coverImageHeightMultilpyer)

        if let titleRows = titleRows {
            try layoutText(titleRows,
                           paragraph: .init(paragraphSpacing: 4.0),
                           in: stackView)
        }

        if let featuresBlock = featuresBlock {
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

        let continueButtonView = AdaptyButtonComponentView(component: purchaseButton,
                                                           addProgressView: true) { [weak self] _ in
            self?.onContinueCallback?()
        }

        layoutContinueButton(continueButtonView,
                             placeholder: continueButtonPlaceholder,
                             on: view)

        continueButtonComponentView = continueButtonView
        contentViewComponentView = contentView

        if let footerBlock = footerBlock {
            let footerView = try AdaptyFooterComponentView(
                footerBlock: footerBlock,
                onTap: { [weak self] action in
                    self?.onActionCallback?(action)
                }
            )
            stackView.addArrangedSubview(footerView)
        }

        layoutTopGradientView(AdaptyGradientView(position: .top), on: view)

        let bottomShadeView = AdaptyGradientView(position: .bottom)
        layoutBottomGradientView(bottomShadeView, on: view)

        scrollViewDelegate.behaviours.append(
            AdaptyPurchaseButtonShadeBehaviour(
                button: continueButtonView,
                buttonPlaceholder: continueButtonPlaceholder,
                shadeView: bottomShadeView,
                baseView: view
            )
        )

        if let closeButton = closeButton {
            let closeButtonView = AdaptyButtonComponentView(
                component: closeButton,
                contentViewMargins: .closeButtonDefaultMargin,
                onTap: { [weak self] _ in
                    self?.onActionCallback?(.close)
                }
            )

            layoutCloseButton(closeButtonView, on: view)
        }

        let progressView = AdaptyActivityIndicatorView(backgroundColor: .black.withAlphaComponent(0.6),
                                                       indicatorColor: .white)
        layoutProgressView(progressView, on: view)
        activityIndicatorComponentView = progressView
    }

    func viewDidLayoutSubviews(_ view: UIView) {
        contentViewComponentView?.updateSafeArea(view.safeAreaInsets)

        if let scrollView = scrollView {
            scrollViewDelegate.scrollViewDidScroll(scrollView)
        }
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
