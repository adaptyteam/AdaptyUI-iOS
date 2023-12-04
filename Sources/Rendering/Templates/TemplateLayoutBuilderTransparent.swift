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
    private let titleRows: AdaptyUI.CompoundText?
    private let featuresBlock: AdaptyUI.FeaturesBlock?
    private let productsBlock: AdaptyUI.ProductsBlock
    private let purchaseButton: AdaptyUI.Button
    private let purchaseButtonOfferTitle: AdaptyUI.CompoundText?
    private let footerBlock: AdaptyUI.FooterBlock?
    private let closeButton: AdaptyUI.Button?
    private let initialProducts: [ProductInfoModel]
    private let tagConverter: AdaptyUI.Text.CustomTagConverter?

    private let scrollViewDelegate = AdaptyCompoundScrollViewDelegate()

    init(
        background: AdaptyUI.Filling,
        contentShape: AdaptyUI.Shape,
        titleRows: AdaptyUI.CompoundText?,
        featuresBlock: AdaptyUI.FeaturesBlock?,
        productsBlock: AdaptyUI.ProductsBlock,
        purchaseButton: AdaptyUI.Button,
        purchaseButtonOfferTitle: AdaptyUI.CompoundText?,
        footerBlock: AdaptyUI.FooterBlock?,
        closeButton: AdaptyUI.Button?,
        initialProducts: [ProductInfoModel],
        tagConverter: AdaptyUI.Text.CustomTagConverter?
    ) {
        self.background = background
        self.contentShape = contentShape
        self.titleRows = titleRows
        self.featuresBlock = featuresBlock
        self.productsBlock = productsBlock
        self.purchaseButton = purchaseButton
        self.purchaseButtonOfferTitle = purchaseButtonOfferTitle
        self.footerBlock = footerBlock
        self.closeButton = closeButton
        self.initialProducts = initialProducts
        self.tagConverter = tagConverter
    }

    private weak var activityIndicatorComponentView: AdaptyActivityIndicatorView?
    private weak var contentViewComponentView: AdaptyBaseContentView?
    private weak var productsComponentView: ProductsComponentView?
    private weak var continueButtonComponentView: AdaptyButtonComponentView?

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

    func continueButtonShowIntroCallToAction(_ show: Bool) {
        if show, let text = purchaseButtonOfferTitle {
            continueButtonComponentView?.updateContent(text)
        } else {
            continueButtonComponentView?.resetContent()
        }
    }

    func buildInterface(on view: UIView) throws {
        let verticalOverscroll = 64.0

        scrollViewDelegate.behaviours.append(
            AdaptyLimitOverscrollScrollBehaviour(maxOffsetTop: verticalOverscroll,
                                                 maxOffsetBottom: verticalOverscroll)
        )

        let backgroundView = AdaptyBackgroundComponentView(background: background)
        layoutBackground(backgroundView, on: view)

        let scrollView = AdaptyBaseScrollView()
        scrollView.delegate = scrollViewDelegate
        layoutScrollView(scrollView, on: view)

        let contentView = AdaptyBaseContentView(
            layout: .transparent,
            shape: contentShape
        )

        layoutContentView(contentView,
                          topOverlap: verticalOverscroll,
                          bottomOverlap: verticalOverscroll,
                          on: scrollView)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView,
                                  inset: UIEdgeInsets(top: 48 + verticalOverscroll,
                                                      left: 20,
                                                      bottom: 24 + verticalOverscroll,
                                                      right: 20),
                                  layout: .bottomToTop)

        if let titleRows = titleRows {
            try layoutTitleRows(titleRows, tagConverter, in: stackView)
        }

        if let featuresBlock = featuresBlock {
            try layoutFeaturesBlock(featuresBlock, tagConverter, in: stackView)
        }

        productsComponentView = try layoutProductsBlock(
            productsBlock,
            initialProducts: initialProducts,
            tagConverter: tagConverter,
            in: stackView
        )

        let continueButtonView = AdaptyButtonComponentView(
            component: purchaseButton,
            tagConverter: tagConverter,
            addProgressView: true
        ) { [weak self] _ in
            self?.onContinueCallback?()
        }

        stackView.addArrangedSubview(continueButtonView)
        stackView.addConstraint(
            continueButtonView.heightAnchor.constraint(equalToConstant: 58.0)
        )

        continueButtonComponentView = continueButtonView
        contentViewComponentView = contentView

        if let footerBlock = footerBlock {
            let footerView = try AdaptyFooterComponentView(
                footerBlock: footerBlock,
                tagConverter: tagConverter,
                onTap: { [weak self] action in
                    self?.onActionCallback?(action)
                }
            )

            stackView.addArrangedSubview(footerView)
        }

        layoutTopGradientView(AdaptyGradientView(position: .top), on: view)

        if let closeButton = closeButton {
            let closeButtonView = AdaptyButtonComponentView(
                component: closeButton,
                tagConverter: tagConverter,
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
    }

    // MARK: - Layout

    private func layoutContentView(_ contentView: AdaptyBaseContentView,
                                   topOverlap: CGFloat,
                                   bottomOverlap: CGFloat,
                                   on scrollView: UIScrollView) {
        scrollView.addSubview(contentView)

        scrollView.addConstraints([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -topOverlap),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: bottomOverlap),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor,
                                                multiplier: 1.0,
                                                constant: topOverlap + bottomOverlap),
        ])
    }
}
