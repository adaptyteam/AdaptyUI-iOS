//
//  ProductInfoModel.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

import Adapty
import UIKit

struct ProductInfoModel {
    let id: String
    let title: String?
    let subtitle: String?
    let price: String?
    let priceSubtitle: String?

    init(id: String, title: String?, subtitle: String?, price: String?, priceSubtitle: String?) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.priceSubtitle = priceSubtitle
    }
}

extension ProductInfoModel {
    static func placeholder(id: String, overridenTitle: String?) -> ProductInfoModel {
        ProductInfoModel(id: id, title: overridenTitle, subtitle: nil, price: nil, priceSubtitle: nil)
    }

    static func build(
        product: AdaptyPaywallProduct,
        introEligibility: AdaptyEligibility,
        overridenTitle: String?
    ) -> ProductInfoModel {
        ProductInfoModel(
            id: product.vendorProductId,
            title: overridenTitle ?? product.localizedTitle,
            subtitle: product.eligibleOfferString(introEligibility: introEligibility),
            price: product.localizedPrice,
            priceSubtitle: product.perWeekPriceString()
        )
    }
}
