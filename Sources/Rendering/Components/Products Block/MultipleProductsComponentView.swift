//
//  MultipleProductsComponentView.swift
//
//
//  Created by Alexey Goncharov on 10.7.23..
//

import Adapty
import UIKit

extension Collection where Indices.Iterator.Element == Index {
    subscript(safe index: Index) -> Iterator.Element? {
        (startIndex <= index && index < endIndex) ? self[index] : nil
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
        try renderMainProductTag()
    }

    private weak var tagView: ProductBadgeView?

    private func cleanupView() {
        let views = arrangedSubviews

        for view in views {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        tagView?.removeFromSuperview()
    }

    private func populateProductsButtons(_ products: [ProductInfoModel], selectedId: String) throws {
        let productsInfos = try productsBlock.productsInfos

        for i in 0 ..< products.count {
            let product = products[i]

            guard let productInfo = productsInfos[safe: i] else {
                throw AdaptyUIError.componentNotFound("\(product.id):product_info")
            }

            let productInfoView: ProductInfoView

            switch productsBlock.type {
            case .horizontal:
                productInfoView = try VerticalProductInfoView(product: product, info: productInfo)
            default:
                productInfoView = try HorizontalProductInfoView(product: product, info: productInfo)
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
    }

    private func renderMainProductTag() throws {
        guard let tagText = productsBlock.mainProductTagText else { return }

        let index = productsBlock.mainProductIndex < arrangedSubviews.count ? productsBlock.mainProductIndex : 0
        let mainProductView = arrangedSubviews[index]

        let tagView = try ProductBadgeView(text: tagText,
                                           shape: productsBlock.mainProductTagShape)

        addSubview(tagView)

        switch productsBlock.type {
        case .horizontal:
            addConstraints([
                tagView.centerXAnchor.constraint(equalTo: mainProductView.centerXAnchor),
            ])
        default:
            addConstraints([
                tagView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0),
            ])
        }

        addConstraints([
            tagView.centerYAnchor.constraint(equalTo: mainProductView.topAnchor),
            tagView.heightAnchor.constraint(equalToConstant: 20.0),
        ])

        self.tagView = tagView
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
