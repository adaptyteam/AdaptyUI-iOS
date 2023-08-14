//
//  MultipleProductsComponentView.swift
//
//
//  Created by Alexey Goncharov on 10.7.23..
//

import Adapty
import UIKit

extension AdaptyUI {
    typealias ProductsInfos = [String: ProductInfo]

    struct ProductInfo {
        let id: String
        let title: AdaptyUI.СompoundText?
    }
}

extension AdaptyUI.LocalizedViewItem {
    func toProductInfo(id: String) -> AdaptyUI.ProductInfo? {
        guard
            case let .object(customObject) = self,
            customObject.type == "product_info"
        else { return nil }

        return .init(id: id,
                     title: customObject.properties["title"]?.asText)
    }

    var asProductsInfos: AdaptyUI.ProductsInfos? {
        guard
            case let .object(customObject) = self,
            customObject.type == "products_infos"
        else { return nil }

        var infos = [String: AdaptyUI.ProductInfo]()

        for (key, value) in customObject.properties {
            guard let productInfo = value.toProductInfo(id: key) else { continue }
            infos[key] = productInfo
        }

        return infos
    }
}

extension AdaptyUI.ProductsBlock {
    var productsInfos: AdaptyUI.ProductsInfos? {
        items["infos"]?.asProductsInfos
    }
}

final class MultipleProductsComponentView: UIStackView, ProductsComponentView {
    private var products: [ProductInfoModel]
    private let productsBlock: AdaptyUI.ProductsBlock

    var onProductSelected: ((ProductInfoModel) -> Void)?

    init(
        axis: NSLayoutConstraint.Axis,
        products: [ProductInfoModel],
        productsBlock: AdaptyUI.ProductsBlock
    ) throws {
        self.products = products
        self.productsBlock = productsBlock

        super.init(frame: .zero)

        self.axis = axis

        try setupView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() throws {
        translatesAutoresizingMaskIntoConstraints = false
        alignment = .fill
        distribution = .fillEqually
        spacing = 8.0

        let selectedId = products[productsBlock.mainProductIndex].id
        try populateProductsButtons(products, selectedId: selectedId)
    }

    private func cleanupView() {
        let views = arrangedSubviews

        for view in views {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    private func populateProductsButtons(_ products: [ProductInfoModel], selectedId: String) throws {
        let productsInfos = productsBlock.productsInfos
        let a = productsInfos?.first?.value

        for product in products {
            let productInfoView: ProductInfoView

            switch productsBlock.type {
            case .horizontal:
                productInfoView = try VerticalProductInfoView(
                    info: product,
                    productsBlock: productsBlock
                )
            default:
                productInfoView = try HorizontalProductInfoView(
                    info: product,
                    productsBlock: productsBlock
                )
            }

            let button = AdaptyButtonComponentView(
                component: try productsBlock.button,
                contentView: productInfoView,
                contentViewMargins: .init(top: 12, left: 20, bottom: 12, right: 20),
                onTap: { [weak self] _ in
                    self?.onProductSelected?(product)
                }
            )
            button.isSelected = product.id == selectedId

            addArrangedSubview(button)

            switch productsBlock.type {
            case .horizontal:
                addConstraint(button.heightAnchor.constraint(equalToConstant: 128.0))
            default:
                addConstraint(button.heightAnchor.constraint(equalToConstant: 64.0))
            }
        }

        if let tagText = productsBlock.mainProductTagText {
            let index = productsBlock.mainProductIndex < arrangedSubviews.count ? productsBlock.mainProductIndex : 0
            let mainProductView = arrangedSubviews[index]

            let tagLabel = AdaptyInsetLabel()

            tagLabel.translatesAutoresizingMaskIntoConstraints = false
            tagLabel.insets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
            tagLabel.layer.cornerRadius = 10.0
            tagLabel.layer.masksToBounds = true

            tagLabel.backgroundColor = productsBlock.mainProductTagBackground?.uiColor
            tagLabel.attributedText = tagText.attributedString(kern: 0.2)

            addSubview(tagLabel)

            switch productsBlock.type {
            case .horizontal:
                addConstraints([
                    tagLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                ])
            default:

                addConstraints([
                    tagLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
                ])
            }

            addConstraints([
                tagLabel.centerYAnchor.constraint(equalTo: mainProductView.topAnchor),
                tagLabel.heightAnchor.constraint(equalToConstant: 20.0),
            ])
        }
    }

    func updateProducts(_ products: [ProductInfoModel], selectedProductId: String?) {
        self.products = products

        cleanupView()
        try? setupView()
    }

    func updateSelectedState(_ productId: String) {
        guard let index = products.firstIndex(where: { $0.id == productId }) else {
            return
        }

        for i in 0 ..< arrangedSubviews.count {
            guard let button = arrangedSubviews[i] as? AdaptyButtonComponentView else { return }
            button.isSelected = i == index
        }
    }
}
