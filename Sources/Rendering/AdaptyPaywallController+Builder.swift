//
//  AdaptyPaywallController_Builder.swift
//
//
//  Created by Alexey Goncharov on 2023-01-19.
//

import Adapty
import UIKit

struct AdaptyInterfaceBilder {
    static func buildCloseButton(on superview: UIView, onTap: @escaping () -> Void) -> AdaptyCloseButton {
        let button = AdaptyCloseButton(onTap: onTap)

        superview.addSubview(button)
        superview.addConstraints([
            button.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 24.0),
            button.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: 16.0),
        ])

        return button
    }

    static func buildInProgressView(on superview: UIView) -> AdaptyActivityIndicatorView {
        let loadingView = AdaptyActivityIndicatorView(backgroundColor: .black.withAlphaComponent(0.6),
                                                      indicatorColor: .white)

        superview.addSubview(loadingView)
        superview.addConstraints([
            loadingView.topAnchor.constraint(equalTo: superview.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        ])

        return loadingView
    }

    static func buildCoverImageView(on superview: UIView, reader: AdaptyTemplateReader) throws -> UIImageView {
        let imageView = UIImageView(image: try reader.coverImage().uiImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        superview.addSubview(imageView)

        let hConstraintMult = imageView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.45)
        hConstraintMult.priority = .init(999.0)
        let hConstraintFix = imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 300.0)
        hConstraintFix.priority = .init(1000.0)

        superview.addConstraints([
            imageView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0.0),
            imageView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0.0),
            imageView.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0.0),

            hConstraintMult,
            hConstraintFix,
        ])

        return imageView
    }

    static func buildCoverImageGradient(on superview: UIView) -> AdaptyGradientViewComponent {
        let view = AdaptyGradientViewComponent()

        superview.addSubview(view)
        superview.addConstraints([
            view.topAnchor.constraint(equalTo: superview.topAnchor),
            view.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: 20.0),
            view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
        ])

        return view
    }

    static func buildScrollView(on superview: UIView, delegate: UIScrollViewDelegate?) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = delegate
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        superview.addSubview(scrollView)

        superview.addConstraints([
            scrollView.topAnchor.constraint(equalTo: superview.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
        ])

        return scrollView
    }

    static func buildCoverSpacerView(on scrollView: UIView, superview: UIView) -> UIView {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        scrollView.addSubview(view)

        scrollView.addConstraints([
            view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

        ])

        let hConstraintMult = view.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 0.45)
        hConstraintMult.priority = .init(999.0)
        let hConstraintFix = view.heightAnchor.constraint(greaterThanOrEqualToConstant: 300.0)
        hConstraintFix.priority = .init(1000.0)

        superview.addConstraints([
            hConstraintMult,
            hConstraintFix,
        ])

        return view
    }

    static func buildContentView(on scrollView: UIView, spacerView: UIView, reader: AdaptyTemplateReader) throws -> UIView {
        let view = UIView()

        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = try reader.contentBackgroundColor().uiColor
        view.layer.cornerRadius = 24.0
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        scrollView.addSubview(view)

        let bottomConstraint = view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        bottomConstraint.priority = UILayoutPriority(250.0)

        let centerYConstraint = view.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        centerYConstraint.priority = UILayoutPriority(250.0)

        scrollView.addConstraints([
            view.topAnchor.constraint(equalTo: spacerView.bottomAnchor, constant: -24.0),
            view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bottomConstraint,

            view.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            centerYConstraint,
        ])

        return view
    }

    static func buildBaseStackView(on superview: UIView) -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 24.0

        let widthPadding = stack.widthAnchor.constraint(equalTo: superview.widthAnchor, constant: -64.0)
        widthPadding.priority = .init(999.0)
        let widthGreater = stack.widthAnchor.constraint(greaterThanOrEqualToConstant: 280.0)
        widthGreater.priority = .init(1000.0)

        superview.addSubview(stack)
        superview.addConstraints([
            stack.topAnchor.constraint(equalTo: superview.topAnchor, constant: 24.0),
            stack.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -24.0),

            stack.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            widthPadding,
            widthGreater,
        ])

        return stack
    }

    static func buildMainInfoBlock(on stackView: UIStackView, reader: AdaptyTemplateReader) throws {
        let mainInfo = AdaptyMainInfoComponent(
            title: try reader.titleText(),
            textRows: try reader.featuresRows(),
            imageColor: try reader.colorSecondaryAccent().uiColor
        )

        stackView.addArrangedSubview(mainInfo)
    }

    static func buildProductsBlock(
        _ paywall: AdaptyPaywall,
        _ products: [AdaptyPaywallProduct]?,
        _ introductoryOffersEligibilities: [String: AdaptyEligibility]?,
        on stackView: UIStackView,
        useHaptic: Bool,
        selectedProductId: String?,
        reader: AdaptyTemplateReader,
        productsTitlesResolver: @escaping (AdaptyProduct) -> String,
        onProductSelected: @escaping (String) -> Void
    ) throws -> AdaptyProductsListComponent {
        let productsList = AdaptyProductsListComponent(
            paywall: paywall,
            products: products,
            productsTitlesResolver: productsTitlesResolver,
            introductoryOffersEligibilities: introductoryOffersEligibilities,
            underlayColor: try reader.colorProductButtonBackground(),
            accentColor: try reader.colorMainAccent(),
            titleColor: try reader.colorProductTitle(),
            subtitleColor: try reader.colorProductSubtitle(),
            priceColor: try reader.colorProductTitle(),
            priceSubtitleColor: try reader.colorProductPriceSubtitle(),
            tagText: try reader.textProductTag(),
            useHaptic: useHaptic,
            onProductSelected: onProductSelected
        )

        productsList.updateSelectedState(selectedProductId)

        stackView.addArrangedSubview(productsList)
        return productsList
    }

    static func buildContinueButton(
        on stackView: UIStackView,
        reader: AdaptyTemplateReader,
        onTap: @escaping () -> Void
    ) throws -> AdaptyContinueButton {
        let button = AdaptyContinueButton(text: try reader.purchaseButtonText(),
                                          color: try reader.colorMainAccent(),
                                          onTap: onTap)
        stackView.addArrangedSubview(button)
        return button
    }

    static func buildServiceButtons(
        on stackView: UIStackView,
        reader: AdaptyTemplateReader,
        onTerms: @escaping () -> Void,
        onPrivacy: @escaping () -> Void,
        onRestore: @escaping () -> Void
    ) throws -> AdaptyServiceButtonsComponent {
        let serviceComponent = AdaptyServiceButtonsComponent(
            termsText: try reader.termsButtonText(),
            privacyText: try reader.privacyButtonText(),
            restoreText: try reader.restoreButtonText(),
            onTerms: onTerms,
            onPrivacy: onPrivacy,
            onRestore: onRestore
        )

        stackView.addArrangedSubview(serviceComponent)

        return serviceComponent
    }
}
