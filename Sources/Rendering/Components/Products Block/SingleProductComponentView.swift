//
//  SingleProductComponentView.swift
//
//
//  Created by Alexey Goncharov on 9.8.23..
//

import Adapty
import UIKit

final class SingleProductComponentView: UIStackView, ProductsComponentView {
    var onProductSelected: ((ProductInfoModel) -> Void)?

    private var product: ProductInfoModel
    private let productInfo: AdaptyUI.ProductInfo
    private let productsBlock: AdaptyUI.ProductsBlock

    private let productPriceText: AdaptyUI.СompoundText
    private let productTitleText: AdaptyUI.СompoundText
    private let productOfferText: AdaptyUI.СompoundText
    private let mainProductTagText: AdaptyUI.СompoundText?

    init(
        product: ProductInfoModel,
        productsBlock: AdaptyUI.ProductsBlock
    ) throws {
        guard productsBlock.type == .single else {
            throw AdaptyUIError.wrongComponentType("products_block")
        }

        self.product = product

        guard let productsInfos = productsBlock.productsInfos,
              let productInfo = productsInfos[product.id] else {
            throw AdaptyUIError.wrongComponentType("products_infos")
        }

        self.productInfo = productInfo
        self.productsBlock = productsBlock

        productPriceText = try productsBlock.productPrice
        productTitleText = try productsBlock.productTitle
        productOfferText = try productsBlock.productOffer
        mainProductTagText = productsBlock.mainProductTagText

        super.init(frame: .zero)

        try setupView()

        updateProducts([product], selectedProductId: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var titleLabel: UILabel!
    private weak var subtitleLabel: UILabel!

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .fill
        distribution = .fillEqually
        spacing = 4.0

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        if let text = mainProductTagText {
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

        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
    }

    func updateProducts(_ products: [ProductInfoModel], selectedProductId: String?) {
        guard let product = products.first else { return }

        if let attributedString = productInfo.title?.attributedString(tagConverter: product.tagConverter) {
            titleLabel.attributedText = attributedString
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }

        if let subtitle = product.subtitle, !subtitle.isEmpty {
            subtitleLabel.attributedText = subtitle.attributedString(using: productOfferText)
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }

    func updateSelectedState(_ productId: String) { }
}

extension ProductInfoModel {
    func tagConverter(_ tagString: String) -> String? {
        guard let tag = tagString.asTag else { return nil }
        switch tag {
        case .price: return price
        }
    }
}

extension AdaptyUI.Text {
    enum Tag: String {
        case price = "PRICE"
    }
}

extension String {
    var asTag: AdaptyUI.Text.Tag? {
        guard hasPrefix("</") && hasSuffix("/>") else { return nil }
        let tagString = replacingOccurrences(of: "</", with: "")
            .replacingOccurrences(of: "/>", with: "")
        return AdaptyUI.Text.Tag(rawValue: tagString)
    }
}
