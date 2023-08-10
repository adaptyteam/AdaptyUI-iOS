//
//  HorizontalProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 11.7.23..
//

import Adapty
import UIKit

final class HorizontalProductInfoView: UIStackView, ProductInfoView {
    let info: ProductInfoModel
    let productsBlock: AdaptyUI.ProductsBlock

    init(info: ProductInfoModel,
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
        titleLabel.attributedText = info.title?.attributedString(using: productTitle)

        let priceTitleLabel = UILabel()
        priceTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        priceTitleLabel.attributedText = info.price?.attributedString(using: productPrice)

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, priceTitleLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal

        let subtitleLabel = UILabel()
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.attributedText = info.subtitle?.attributedString(using: productOffer)

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        priceSubtitleLabel.attributedText = info.priceSubtitle?.attributedString(using: productPriceCalculated)

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
