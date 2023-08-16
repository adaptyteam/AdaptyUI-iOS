//
//  HorizontalProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 11.7.23..
//

import Adapty
import UIKit

final class HorizontalProductInfoView: UIStackView, ProductInfoView {
    let product: ProductInfoModel
    let info: AdaptyUI.ProductInfo

    init(product: ProductInfoModel, info: AdaptyUI.ProductInfo) throws {
        self.product = product
        self.info = info

        super.init(frame: .zero)

        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() throws {
        let tagConverter = product.tagConverter

        let titleLabel = UILabel()
        titleLabel.attributedText = info.title?.attributedString(tagConverter: tagConverter)

        let subtitleLabel = UILabel()
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        switch product.eligibleOffer?.paymentMode {
        case .payAsYouGo:
            subtitleLabel.attributedText = info.subtitlePayAsYouGo?.attributedString(tagConverter: tagConverter)
        case .payUpFront:
            subtitleLabel.attributedText = info.subtitlePayUpFront?.attributedString(tagConverter: tagConverter)
        case .freeTrial:
            subtitleLabel.attributedText = info.subtitleFreeTrial?.attributedString(tagConverter: tagConverter)
        default:
            subtitleLabel.attributedText = info.subtitle?.attributedString(tagConverter: tagConverter)
        }

        let priceTitleLabel = UILabel()
        priceTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        priceTitleLabel.attributedText = info.secondTitle?.attributedString(tagConverter: tagConverter)

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        priceSubtitleLabel.attributedText = info.secondSubitle?.attributedString(tagConverter: tagConverter)

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, priceTitleLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal

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
