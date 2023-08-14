//
//  LayoutBuilder+ProductsBlock.swift
//
//
//  Created by Alexey Goncharov on 14.8.23..
//

import Adapty
import UIKit

extension LayoutBuilder {
    func layoutProductsBlock(_ productsBlock: AdaptyUI.ProductsBlock,
                             initialProducts: [ProductInfoModel],
                             in stackView: UIStackView) throws -> ProductsComponentView {
        guard !initialProducts.isEmpty else {
            // TODO: change the error
            throw AdaptyUIError.unsupportedTemplate("test")
        }

        let productsView: ProductsComponentView

        switch productsBlock.type {
        case .horizontal:
            productsView = try MultipleProductsComponentView(axis: .horizontal,
                                                             products: initialProducts,
                                                             productsBlock: productsBlock)
        case .vertical:
            productsView = try MultipleProductsComponentView(axis: .vertical,
                                                             products: initialProducts,
                                                             productsBlock: productsBlock)
        case .single:
            productsView = try SingleProductComponentView(product: initialProducts[0],
                                                          productsBlock: productsBlock)
        }

        stackView.addArrangedSubview(productsView)

        return productsView
    }
}
