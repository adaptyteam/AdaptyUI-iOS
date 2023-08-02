//
//  AdaptyProductsComponentView.swift
//
//
//  Created by Alexey Goncharov on 10.7.23..
//

import Adapty
import UIKit

protocol ProductsComponentView {
    func updateProducts(_ products: [AdaptyPaywallProduct]?, selectedProductId: String?)
    func updateIntroEligibilities(_ eligibilities: [String: AdaptyEligibility]?)
    func updateSelectedState(_ productId: String?)
}

// TODO: Move this out
extension AdaptyUI.ProductsBlock {
    var button: AdaptyUI.Button {
        get throws {
            guard let result = items["button"]?.asButton else {
                throw AdaptyUIError.componentNotFound("button")
            }
            return result
        }
    }

    var mainProductTagBackground: AdaptyUI.Color? {
        items["main_product_tag_background"]?.asColor
    }

    var mainProductTagText: AdaptyUI.Text? {
        items["main_product_tag_text"]?.asText
    }

    var productTitle: AdaptyUI.Text {
        get throws {
            guard let result = items["product_title"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_title")
            }
            return result
        }
    }

    var productOffer: AdaptyUI.Text {
        get throws {
            guard let result = items["product_offer"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_offer")
            }
            return result
        }
    }

    var productPrice: AdaptyUI.Text {
        get throws {
            guard let result = items["product_price"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_price")
            }
            return result
        }
    }

    var productPriceCalculated: AdaptyUI.Text {
        get throws {
            guard let result = items["product_price_calculated"]?.asText else {
                throw AdaptyUIError.componentNotFound("product_price_calculated")
            }
            return result
        }
    }
}

struct MockProductInfo: ProductInfo {
    let title: String?
    let subtitle: String?
    let price: String?
    let priceSubtitle: String?

    init(title: String?, subtitle: String?, price: String?, priceSubtitle: String?) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.priceSubtitle = priceSubtitle
    }
}

final class AdaptyProductsComponentView: UIStackView {
    let productsBlock: AdaptyUI.ProductsBlock

    init(productsBlock: AdaptyUI.ProductsBlock) throws {
        self.productsBlock = productsBlock

        super.init(frame: .zero)

        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false
        alignment = .fill
        distribution = .fillEqually
        spacing = 8.0

        let products = (0 ..< 3).map { i in
            MockProductInfo(title: " / 1 year",
                            subtitle: "7 days free trial",
                            price: "$\(i).99",
                            priceSubtitle: "$9 / week")
        }

        switch productsBlock.type {
        case .vertical:
            axis = .vertical
            spacing = 8.0
            try populateProductsButtons(products)
        case .horizontal:
            axis = .horizontal
            spacing = 8.0
            try populateProductsButtons(products)
        case .single:
            axis = .vertical
            spacing = 4.0
            try populateProductInfo(products[0])
        }
    }

    private func populateProductInfo(_ product: ProductInfo) throws {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let titleAttributedString = NSMutableAttributedString()
        
        if let price = product.price {
            let priceAttrString = try productsBlock.productPrice.attributedString(overridingValue: price)
            titleAttributedString.append(priceAttrString)
        }
        
        if let title = product.title {
            let titleAttrString = try productsBlock.productTitle.attributedString(overridingValue: title)
            titleAttributedString.append(titleAttrString)
        }
        
        if titleAttributedString.length > 0 {
            titleLabel.attributedText = titleAttributedString
        } else {
            titleLabel.isHidden = true
        }

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.attributedText = try productsBlock.productOffer.attributedString(overridingValue: product.subtitle)

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        if let text = productsBlock.mainProductTagText {
            descriptionLabel.attributedText = text.attributedString()
        } else {
            descriptionLabel.isHidden = true
        }

        let bottomStackView = UIStackView(arrangedSubviews: [subtitleLabel, descriptionLabel])
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .vertical
        bottomStackView.spacing = 0.0

        addArrangedSubview(titleLabel)
        addArrangedSubview(bottomStackView)
    }

    private func populateProductsButtons(_ products: [ProductInfo]) throws {
        for i in 0 ..< products.count {
            let product = products[i]
            let productInfoView: ProductInfoView

            switch productsBlock.type {
            case .horizontal:
                productInfoView = try AdaptyVerticalProductInfoView(
                    info: product,
                    productsBlock: productsBlock
                )
            default:
                productInfoView = try AdaptyHorizontalProductInfoView(
                    info: product,
                    productsBlock: productsBlock
                )
            }

            let button = AdaptyButtonComponentView(
                component: try productsBlock.button,
                contentView: productInfoView,
                contentViewMargins: .init(top: 12, left: 20, bottom: 12, right: 20)
            )
            button.isSelected = i == productsBlock.mainProductIndex
            button.onTap = { _ in
                button.isSelected.toggle()
            }

            addArrangedSubview(button)

            switch productsBlock.type {
            case .horizontal:
                addConstraint(button.heightAnchor.constraint(equalToConstant: 128.0))
            default:
                addConstraint(button.heightAnchor.constraint(equalToConstant: 64.0))
            }
        }

        if let tagText = productsBlock.mainProductTagText {
            // TODO: safe []
            let mainProductView = arrangedSubviews[productsBlock.mainProductIndex]

            let tagLabel = AdaptyInsetLabel()

            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            tagLabel.text = tagText.value
            tagLabel.insets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
            tagLabel.layer.cornerRadius = 10.0
            tagLabel.layer.masksToBounds = true

            tagLabel.font = tagText.font?.uiFont
            tagLabel.backgroundColor = productsBlock.mainProductTagBackground?.uiColor
            tagLabel.textColor = tagText.uiColor

            let attr = NSMutableAttributedString(string: tagText.value ?? "")
            attr.addAttributes([
                NSAttributedString.Key.kern: 0.2,
            ], range: NSRange(location: 0, length: attr.length))

            tagLabel.attributedText = attr

            addSubview(tagLabel)

            switch productsBlock.type {
            case .horizontal:
                addConstraints([
                    tagLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                ])
            default:

                addConstraints([
                    tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
                ])
            }

            addConstraints([
                tagLabel.centerYAnchor.constraint(equalTo: mainProductView.topAnchor),
                tagLabel.heightAnchor.constraint(equalToConstant: 20.0),
            ])

            //            self.tagLabel = tagLabel
        }
    }
}
