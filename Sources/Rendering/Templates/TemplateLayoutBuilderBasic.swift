//
//  TemplateLayoutBuilderBasic.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

extension AdaptyUI.Shape {
    fileprivate var recommendedContentOverlap: CGFloat {
        switch type {
        case let .rectangle(cornerRadius): return cornerRadius.value ?? 0.0
        case .curveUp, .curveDown: return 1.5 * AdaptyBaseContentView.curveHeight
        case .circle: return 0.0
        }
    }
}

class TemplateLayoutBuilderBasic: LayoutBuilder {
    private let coverImage: AdaptyUI.Image
    private let coverImageHeightMultilpyer: CGFloat
    private let contentShape: AdaptyUI.Shape
    private let titleRows: AdaptyUI.CompoundText?
    private let featuresBlock: AdaptyUI.FeaturesBlock?
    private let productsBlock: AdaptyUI.ProductsBlock
    private let purchaseButton: AdaptyUI.Button
    private let closeButton: AdaptyUI.Button?
    private let footerBlock: AdaptyUI.FooterBlock?
    private let initialProducts: [ProductInfoModel]

    private let scrollViewDelegate = AdaptyCoverImageScrollDelegate()

    init(
        coverImage: AdaptyUI.Image,
        coverImageHeightMultilpyer: CGFloat,
        contentShape: AdaptyUI.Shape,
        titleRows: AdaptyUI.CompoundText?,
        featuresBlock: AdaptyUI.FeaturesBlock?,
        productsBlock: AdaptyUI.ProductsBlock,
        purchaseButton: AdaptyUI.Button,
        footerBlock: AdaptyUI.FooterBlock?,
        closeButton: AdaptyUI.Button?,
        initialProducts: [ProductInfoModel]
    ) {
        self.coverImage = coverImage
        self.coverImageHeightMultilpyer = coverImageHeightMultilpyer
        self.contentShape = contentShape
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
        let backgroundView = AdaptyBackgroundComponentView(background: contentShape.background)
        layoutBackground(backgroundView, on: view)

        let imageView = UIImageView(image: coverImage.uiImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        layoutCoverImageView(imageView,
                             on: view,
                             multiplier: coverImageHeightMultilpyer,
                             minHeight: 300.0)

        scrollViewDelegate.coverView = imageView

        let scrollView = AdaptyBaseScrollView()
        scrollView.delegate = scrollViewDelegate
        layoutScrollView(scrollView, on: view)

        let contentView = AdaptyBaseContentView(
            layout: .basic(multiplier: coverImageHeightMultilpyer),
            shape: contentShape
        )

        layoutContentView(
            contentView,
            multiplier: coverImageHeightMultilpyer,
            overlap: contentShape.recommendedContentOverlap,
            on: scrollView
        )

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24.0
        stackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutContent(stackView, inset: UIEdgeInsets(top: contentShape.recommendedContentOverlap,
                                                                 left: 24,
                                                                 bottom: 24,
                                                                 right: 24))

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

        let continueButtonView = AdaptyButtonComponentView(component: purchaseButton,
                                                           addProgressView: true) { [weak self] _ in
            self?.onContinueCallback?()
        }

        layoutContinueButton(continueButtonView,
                             placeholder: continueButtonPlaceholder,
                             on: view)

        continueButtonComponentView = continueButtonView
        contentViewComponentView = contentView

        if let footerBlock {
            let footerView = try AdaptyFooterComponentView(
                footerBlock: footerBlock,
                onTap: { [weak self] action in
                    self?.onActionCallback?(action)
                }
            )
            stackView.addArrangedSubview(footerView)
        }

        layoutTopGradientView(AdaptyGradientView(), on: view)

        if let closeButton {
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
    }

    // MARK: - Layout

    private func layoutContentView(_ contentView: AdaptyBaseContentView,
                                   multiplier: CGFloat,
                                   overlap: CGFloat,
                                   on scrollView: UIScrollView) {
        scrollView.addSubview(contentView)

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
            contentView.topAnchor.constraint(equalTo: spacerView.bottomAnchor,
                                             constant: -overlap),

            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor,
                                                multiplier: 1.0 - multiplier,
                                                constant: overlap + 32.0),
        ])
    }
}
