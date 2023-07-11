//
//  AdaptyHorizontalProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 11.7.23..
//

import UIKit

final class AdaptyHorizontalProductInfoView: UIStackView {
    let title: String?
    let subtitle: String?
    let price: String?
    let priceSubtitle: String?

    let titleColor: UIColor
    let subtitleColor: UIColor
    let priceColor: UIColor
    let priceSubtitleColor: UIColor

    init(title: String?,
         subtitle: String?,
         price: String?,
         priceSubtitle: String?,
         titleColor: UIColor,
         subtitleColor: UIColor,
         priceColor: UIColor,
         priceSubtitleColor: UIColor) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.priceSubtitle = priceSubtitle
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.priceColor = priceColor
        self.priceSubtitleColor = priceSubtitleColor

        super.init(frame: .zero)

        setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18.0, weight: .medium)
        titleLabel.textColor = titleColor
        titleLabel.text = title

        let priceTitleLabel = UILabel()
        priceTitleLabel.font = .systemFont(ofSize: 18.0, weight: .medium)
        priceTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        priceTitleLabel.textColor = priceColor
        priceTitleLabel.textAlignment = .right
        priceTitleLabel.text = price

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, priceTitleLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal

        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 14.0)
        subtitleLabel.textColor = subtitleColor
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.text = subtitle

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.font = .systemFont(ofSize: 14.0)
        priceSubtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        priceSubtitleLabel.textColor = priceSubtitleColor
        priceSubtitleLabel.textAlignment = .right
        priceSubtitleLabel.text = priceSubtitle

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
