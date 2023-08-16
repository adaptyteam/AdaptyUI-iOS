//
//  MultipleProductsComponentView.swift
//
//
//  Created by Alexey Goncharov on 10.7.23..
//

import Adapty
import UIKit

// TODO: move out
extension AdaptyUI {
    typealias ProductsInfos = [String: ProductInfo]

    struct ProductInfo {
        let id: String
        let title: AdaptyUI.CompoundText?

        let subtitle: AdaptyUI.CompoundText?
        let subtitlePayAsYouGo: AdaptyUI.CompoundText?
        let subtitlePayUpFront: AdaptyUI.CompoundText?
        let subtitleFreeTrial: AdaptyUI.CompoundText?

        let secondTitle: AdaptyUI.CompoundText?
        let secondSubitle: AdaptyUI.CompoundText?
    }
}

extension AdaptyUI.LocalizedViewItem {
    func toProductInfo(id: String) -> AdaptyUI.ProductInfo? {
        guard
            case let .object(customObject) = self,
            customObject.type == "product_info"
        else { return nil }

        return .init(
            id: id,
            title: customObject.properties["title"]?.asText,
            subtitle: customObject.properties["subtitle"]?.asText,
            subtitlePayAsYouGo: customObject.properties["subtitle_payasyougo"]?.asText,
            subtitlePayUpFront: customObject.properties["subtitle_payupfront"]?.asText,
            subtitleFreeTrial: customObject.properties["subtitle_freetrial"]?.asText,
            secondTitle: customObject.properties["second_title"]?.asText,
            secondSubitle: customObject.properties["second_subtitle"]?.asText
        )
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
        
        for product in products {
            guard let productInfo = productsInfos[product.id] else {
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
