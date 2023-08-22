//
//  VerticalProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

import Adapty
import UIKit

final class VerticalProductInfoView: UIStackView, ProductInfoView {
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
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        if let title = info.title {
            titleLabel.attributedText = title.attributedString(tagConverter: tagConverter)
        } else {
            titleLabel.text = " "
        }

        let subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 2
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        switch product.eligibleOffer?.paymentMode {
        case .payAsYouGo:
            subtitleLabel.attributedText = info.subtitlePayAsYouGo?.attributedString(tagConverter: tagConverter)
        case .payUpFront:
            subtitleLabel.attributedText = info.subtitlePayUpFront?.attributedString(tagConverter: tagConverter)
        case .freeTrial:
            subtitleLabel.attributedText = info.subtitleFreeTrial?.attributedString(tagConverter: tagConverter)
        default:
            if let subtitle = info.subtitle {
                subtitleLabel.attributedText = subtitle.attributedString(tagConverter: tagConverter)
            } else {
                subtitleLabel.text = " "
            }
        }
        
        let topStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        topStack.translatesAutoresizingMaskIntoConstraints = false
        topStack.axis = .vertical
        topStack.alignment = .fill
        topStack.spacing = 0.0

        let priceTitleLabel = UILabel()
        priceTitleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        priceTitleLabel.attributedText = info.secondTitle?.attributedString(tagConverter: tagConverter)

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        priceSubtitleLabel.attributedText = info.secondSubitle?.attributedString(tagConverter: tagConverter)

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
