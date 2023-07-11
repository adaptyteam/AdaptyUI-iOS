//
//  AdaptyProductsListComponent.swift
//
//
//  Created by Alexey Goncharov on 2023-01-19.
//

import Adapty
import UIKit

class AdaptyProductsListComponent: UIStackView {
    private var selectedProductId: String?

    private let productsCount: Int
    private var products: [AdaptyPaywallProduct]?
    private let productsTitlesResolver: (AdaptyProduct) -> String
    private var introductoryOffersEligibilities: [String: AdaptyEligibility]?
    private let underlayColor: AdaptyUI.Color
    private let accentColor: AdaptyUI.Color
    private let titleColor: AdaptyUI.Color
    private let subtitleColor: AdaptyUI.Color
    private let priceColor: AdaptyUI.Color
    private let priceSubtitleColor: AdaptyUI.Color
    private let tagText: AdaptyUI.Text?
    private let useHaptic: Bool

    private let onProductSelected: ((String) -> Void)?

    init(productsCount: Int,
         products: [AdaptyPaywallProduct]?,
         productsTitlesResolver: @escaping (AdaptyProduct) -> String,
         introductoryOffersEligibilities: [String: AdaptyEligibility]?,
         underlayColor: AdaptyUI.Color,
         accentColor: AdaptyUI.Color,
         titleColor: AdaptyUI.Color,
         subtitleColor: AdaptyUI.Color,
         priceColor: AdaptyUI.Color,
         priceSubtitleColor: AdaptyUI.Color,
         tagText: AdaptyUI.Text?,
         useHaptic: Bool,
         onProductSelected: @escaping (String) -> Void) {
        self.productsCount = productsCount
        self.products = products
        self.productsTitlesResolver = productsTitlesResolver
        self.introductoryOffersEligibilities = introductoryOffersEligibilities
        self.underlayColor = underlayColor
        self.accentColor = accentColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.priceColor = priceColor
        self.priceSubtitleColor = priceSubtitleColor
        self.tagText = tagText
        self.useHaptic = useHaptic
        self.onProductSelected = onProductSelected

        super.init(frame: .zero)

        setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var productButtons: [AdaptyProductItemComponent]?
    private var placeholderViews: [AdaptyProductPlaceholderComponent]?

    private func cleanupView() {
        if let productButtons = productButtons {
            for button in productButtons {
                removeArrangedSubview(button)
                button.removeFromSuperview()
            }
        }

        if let placeholderViews = placeholderViews {
            for view in placeholderViews {
                removeArrangedSubview(view)
                view.removeFromSuperview()
            }
        }

        productButtons = nil
        placeholderViews = nil
    }

    private func setupView() {
        axis = .vertical
        alignment = .fill
        spacing = 0.0
        translatesAutoresizingMaskIntoConstraints = false

        if let products = products, !products.isEmpty {
            var productButtons = [AdaptyProductItemComponent]()

            for i in 0 ..< products.count {
                let product = products[i]
                let productButton = AdaptyProductItemComponent(
                    product: product,
                    productsTitlesResolver: productsTitlesResolver,
                    introductoryOfferEligibility: introductoryOffersEligibilities?[product.vendorProductId] ?? .ineligible,
                    underlayColor: underlayColor,
                    accentColor: accentColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    priceColor: priceColor,
                    priceSubtitleColor: priceSubtitleColor,
                    tagText: i == 0 ? tagText : nil,
                    useHaptic: useHaptic
                )

                addArrangedSubview(productButton)

                productButton.onTap = { [weak self] in
                    self?.onProductSelected?(product.vendorProductId)
                }

                productButtons.append(productButton)
            }

            self.productButtons = productButtons
        } else {
            var placeholderViews = [AdaptyProductPlaceholderComponent]()

            for _ in 0 ..< productsCount {
                let placeholder = AdaptyProductPlaceholderComponent(color: underlayColor)
                addArrangedSubview(placeholder)

                placeholderViews.append(placeholder)
            }

            self.placeholderViews = placeholderViews
        }
    }

    func updateProducts(_ products: [AdaptyPaywallProduct]?, selectedProductId: String?) {
        self.products = products
        cleanupView()
        setupView()
        updateSelectedState(selectedProductId)
    }
    
    func updateIntroEligibilities(_ eligibilities: [String: AdaptyEligibility]?) {
        productButtons?.forEach { button in
            let productId = button.product.vendorProductId
            if let eligibility = eligibilities?[productId] {
                button.updateIntroEligibility(eligibility)
            }
        }
    }

    func updateSelectedState(_ productId: String?) {
        selectedProductId = productId

        if let productId = productId {
            productButtons?.forEach { $0.selected = ($0.product.vendorProductId == productId) }
        } else {
            productButtons?.forEach { $0.selected = false }
        }
    }
}
