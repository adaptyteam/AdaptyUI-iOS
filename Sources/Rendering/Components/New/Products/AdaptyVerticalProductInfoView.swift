//
//  AdaptyVerticalProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

import Adapty
import UIKit

final class AdaptyVerticalProductInfoView: UIStackView, ProductInfoView {
    let info: ProductInfo
    let productsBlock: AdaptyUI.ProductsBlock

    init(info: ProductInfo,
         productsBlock: AdaptyUI.ProductsBlock) throws {
        self.info = info
        self.productsBlock = productsBlock

        super.init(frame: .zero)

        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() throws {
        let productTitle = try productsBlock.productTitle
        let productOffer = try productsBlock.productOffer
        let productPrice = try productsBlock.productPrice
        let productPriceCalculated = try productsBlock.productPriceCalculated

        let titleLabel = UILabel()
        titleLabel.attributedText = productTitle.attributedString(overridingValue: info.title)

        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 2
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        subtitleLabel.attributedText = productOffer.attributedString(overridingValue: info.subtitle)

        let topStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.axis = .vertical
        topStack.alignment = .fill
        topStack.spacing = 0.0

        let priceTitleLabel = UILabel()
        priceTitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        priceTitleLabel.attributedText = productPrice.attributedString(overridingValue: info.price)

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        priceSubtitleLabel.attributedText = productPriceCalculated.attributedString(overridingValue: info.priceSubtitle)

        let bottomStack = UIStackView(arrangedSubviews: [priceTitleLabel, priceSubtitleLabel])
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.axis = .vertical
        bottomStack.alignment = .fill
        bottomStack.spacing = 0.0

        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 8.0
        alignment = .fill
        distribution = .fillProportionally

        addArrangedSubview(topStack)
        addArrangedSubview(bottomStack)
    }
}