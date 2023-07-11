//
//  AdaptyHorizontalProductsComponentView.swift
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

final class AdaptyHorizontalProductsComponentView: UIStackView {
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
        axis = .vertical
        alignment = .fill
        spacing = 8.0
        translatesAutoresizingMaskIntoConstraints = false

        for i in 0 ..< 3 {
            let productInfoView = try AdaptyHorizontalProductInfoView(
                title: "1 year",
                subtitle: "7 days free trial",
                price: "$99.99",
                priceSubtitle: "$9 / week",
                productsBlock: productsBlock
            )

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
            addConstraint(button.heightAnchor.constraint(equalToConstant: 64.0))
        }

        if let tagText = productsBlock.mainProductTagText {
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
            addConstraints([
                tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
                tagLabel.centerYAnchor.constraint(equalTo: mainProductView.topAnchor),
                tagLabel.heightAnchor.constraint(equalToConstant: 20.0),
            ])

            //            self.tagLabel = tagLabel
        }
    }
}
