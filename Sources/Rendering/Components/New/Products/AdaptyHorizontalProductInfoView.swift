//
//  AdaptyHorizontalProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 11.7.23..
//

import Adapty
import UIKit

final class AdaptyHorizontalProductInfoView: UIStackView, ProductInfoView {
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
//        titleLabel.font = productTitle.uiFont
//        titleLabel.textColor = productTitle.uiColor
        titleLabel.attributedText = productTitle.attributedString(overridingValue: info.title)

        let priceTitleLabel = UILabel()
        priceTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        priceTitleLabel.font = productPrice.uiFont
//        priceTitleLabel.textColor = productPrice.uiColor
//        priceTitleLabel.textAlignment = .right
        priceTitleLabel.attributedText = productPrice.attributedString(overridingValue: info.price)

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, priceTitleLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal

        let subtitleLabel = UILabel()
//        subtitleLabel.font = productOffer.uiFont
//        subtitleLabel.textColor = productOffer.uiColor
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.attributedText = productOffer.attributedString(overridingValue: info.subtitle)

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        priceSubtitleLabel.font = productPriceCalculated.uiFont
//        priceSubtitleLabel.textColor = productPriceCalculated.uiColor
//        priceSubtitleLabel.textAlignment = .right
        priceSubtitleLabel.attributedText = productPriceCalculated.attributedString(overridingValue: info.priceSubtitle)

        let subtitleStack = UIStackView(arrangedSubviews: [subtitleLabel, priceSubtitleLabel])
        subtitleStack.translatesAutoresizingMaskIntoConstraints = false
        subtitleStack.axis = .horizontal
        subtitleStack.spacing = 4.0

        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 0.0
        alignment = .fill

        addArrangedSubview(titleStack)
        addArrangedSubview(subtitleStack)
    }
}
