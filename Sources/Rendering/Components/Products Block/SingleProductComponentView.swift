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
    private let info: AdaptyUI.ProductInfo

    init(
        product: ProductInfoModel,
        productsBlock: AdaptyUI.ProductsBlock
    ) throws {
        guard productsBlock.type == .single else {
            throw AdaptyUIError.wrongComponentType("products_block")
        }

        self.product = product

        let productsInfos = try productsBlock.productsInfos

        guard let productInfo = productsInfos[product.id] else {
            throw AdaptyUIError.componentNotFound("\(product.id):product_info")
        }

        info = productInfo

        super.init(frame: .zero)

        try setupView()

        updateProducts([product], selectedProductId: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private weak var titleLabel: UILabel!
    private weak var subtitleLabel: UILabel!
    private weak var descriptionLabel: UILabel!

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

        let bottomStackView = UIStackView(arrangedSubviews: [subtitleLabel, descriptionLabel])
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .vertical
        bottomStackView.spacing = 0.0

        addArrangedSubview(titleLabel)
        addArrangedSubview(bottomStackView)

        self.titleLabel = titleLabel
        self.subtitleLabel = subtitleLabel
        self.descriptionLabel = descriptionLabel
    }

    func updateProducts(_ products: [ProductInfoModel], selectedProductId: String?) {
        guard let product = products.first else { return }
        let tagConverter = product.tagConverter

        if let title = info.title?.attributedString(tagConverter: tagConverter) {
            titleLabel.attributedText = title
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }

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

        if let secondTitle = info.secondTitle?.attributedString(tagConverter: tagConverter) {
            descriptionLabel.attributedText = secondTitle
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }
    }

    func updateSelectedState(_ productId: String) { }
}
