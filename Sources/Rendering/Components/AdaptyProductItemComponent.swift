//
//  AdaptyProductItemComponent.swift
//
//
//  Created by Alexey Goncharov on 2023-01-18.
//

import Adapty
import UIKit

class AdaptyProductItemComponent: UIView {
    var selected: Bool = false {
        didSet {
            updateSelected()
        }
    }

    private(set) var product: AdaptyPaywallProduct
    private let productsTitlesResolver: (AdaptyProduct) -> String
    private(set) var introductoryOfferEligibility: AdaptyEligibility
    private let underlayColor: AdaptyUI.Color
    private let accentColor: AdaptyUI.Color
    private let titleColor: AdaptyUI.Color
    private let subtitleColor: AdaptyUI.Color
    private let priceColor: AdaptyUI.Color
    private let priceSubtitleColor: AdaptyUI.Color
    private let tagText: AdaptyUI.Text?
    private let feedbackGenerator: UIImpactFeedbackGenerator?

    var onTap: (() -> Void)?

    init(
        product: AdaptyPaywallProduct,
        productsTitlesResolver: @escaping (AdaptyProduct) -> String,
        introductoryOfferEligibility: AdaptyEligibility,
        underlayColor: AdaptyUI.Color,
        accentColor: AdaptyUI.Color,
        titleColor: AdaptyUI.Color,
        subtitleColor: AdaptyUI.Color,
        priceColor: AdaptyUI.Color,
        priceSubtitleColor: AdaptyUI.Color,
        tagText: AdaptyUI.Text?,
        useHaptic: Bool
    ) {
        self.product = product
        self.productsTitlesResolver = productsTitlesResolver
        self.introductoryOfferEligibility = introductoryOfferEligibility
        self.underlayColor = underlayColor
        self.accentColor = accentColor
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.priceColor = priceColor
        self.priceSubtitleColor = priceSubtitleColor
        self.tagText = tagText

        if useHaptic {
            feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        } else {
            feedbackGenerator = nil
        }

        super.init(frame: .zero)

        setupView()
        setupConstraints()
        setupActions()
    }

    func updateIntroEligibility(_ eligibility: AdaptyEligibility) {
        introductoryOfferEligibility = eligibility
        subtitleLabel.text = product.eligibleOfferString(introEligibility: eligibility)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var underlayView: UIView!
    private weak var baseStack: UIStackView!
    private weak var titleLabel: UILabel!
    private weak var subtitleLabel: UILabel!
    private weak var priceTitleLabel: UILabel!
    private weak var priceSubtitleLabel: UILabel!
    private weak var tagLabel: UILabel?
    private weak var button: UIButton!

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        let underlayView = UIView()
        underlayView.translatesAutoresizingMaskIntoConstraints = false
        underlayView.backgroundColor = underlayColor.uiColor
        underlayView.layer.masksToBounds = true
        underlayView.layer.cornerRadius = 8.0
        underlayView.layer.borderColor = UIColor.clear.cgColor
        underlayView.layer.borderWidth = 0.0

        addSubview(underlayView)
        self.underlayView = underlayView

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18.0, weight: .medium)
        titleLabel.textColor = titleColor.uiColor

        let priceTitleLabel = UILabel()
        priceTitleLabel.font = .systemFont(ofSize: 18.0, weight: .medium)
        priceTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        priceTitleLabel.textColor = priceColor.uiColor
        priceTitleLabel.textAlignment = .right

        let titleStack = UIStackView(arrangedSubviews: [titleLabel, priceTitleLabel])
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        titleStack.axis = .horizontal

        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 14.0)
        subtitleLabel.textColor = subtitleColor.uiColor
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let priceSubtitleLabel = UILabel()
        priceSubtitleLabel.font = .systemFont(ofSize: 14.0)
        priceSubtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        priceSubtitleLabel.textColor = priceSubtitleColor.uiColor
        priceSubtitleLabel.textAlignment = .right

        let subtitleStack = UIStackView(arrangedSubviews: [subtitleLabel, priceSubtitleLabel])
        subtitleStack.translatesAutoresizingMaskIntoConstraints = false
        subtitleStack.axis = .horizontal
        subtitleStack.spacing = 4.0

        let baseStack = UIStackView(arrangedSubviews: [titleStack, subtitleStack])
        baseStack.translatesAutoresizingMaskIntoConstraints = false
        baseStack.axis = .vertical
        baseStack.spacing = 0.0
        baseStack.alignment = .fill

        addSubview(baseStack)

        if let tagText = tagText {
            let tagLabel = AdaptyInsetLabel()
            
            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            tagLabel.text = tagText.value
            tagLabel.insets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
            tagLabel.layer.cornerRadius = 10.0
            tagLabel.layer.masksToBounds = true

            tagLabel.font = tagText.font?.uiFont
            tagLabel.backgroundColor = accentColor.uiColor
            tagLabel.textColor = tagText.uiColor

            let attr = NSMutableAttributedString(string: tagText.value ?? "")
            attr.addAttributes([
                NSAttributedString.Key.kern: 0.2,
            ], range: NSRange(location: 0, length: attr.length))

            tagLabel.attributedText = attr

            addSubview(tagLabel)

            self.tagLabel = tagLabel
        }

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear

        addSubview(button)

        titleLabel.text = productsTitlesResolver(product)
        subtitleLabel.text = product.eligibleOfferString(introEligibility: introductoryOfferEligibility)
        priceTitleLabel.text = product.localizedPrice
        priceSubtitleLabel.text = product.perWeekPriceString()

        self.baseStack = baseStack
        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.priceTitleLabel = priceTitleLabel
        self.priceSubtitleLabel = priceSubtitleLabel
        self.button = button
    }

    private func setupConstraints() {
        addConstraints([
            underlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlayView.heightAnchor.constraint(equalToConstant: 64.0),

            baseStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.0),
            baseStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.0),
            baseStack.centerYAnchor.constraint(equalTo: underlayView.centerYAnchor),

            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),

            heightAnchor.constraint(equalToConstant: 74.0),
        ])

        if let tagLabel = tagLabel {
            addConstraints([
                tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
                tagLabel.centerYAnchor.constraint(equalTo: underlayView.topAnchor),
                tagLabel.heightAnchor.constraint(equalToConstant: 20.0),
            ])
        }
    }

    private func setupActions() {
        button.addTarget(self, action: #selector(buttonDidTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(buttonDidTouchUpOutside), for: .touchUpOutside)
        button.addTarget(self, action: #selector(buttonDidTouchUpInside), for: .touchUpInside)
    }

    private func updateSelected() {
        underlayView?.layer.borderColor = (selected ? accentColor.uiColor : .clear).cgColor
        underlayView?.layer.borderWidth = selected ? 2.0 : 0.0
    }

    @objc
    private func buttonDidTouchDown() {
        alpha = 0.7
        feedbackGenerator?.prepare()
    }

    @objc
    private func buttonDidTouchUpOutside() {
        alpha = 1.0
    }

    @objc
    private func buttonDidTouchUpInside() {
        alpha = 1.0
        onTap?()
        feedbackGenerator?.impactOccurred()
    }
}
