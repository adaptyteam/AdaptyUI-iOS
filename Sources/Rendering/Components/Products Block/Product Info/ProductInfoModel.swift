//
//  ProductInfoModel.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

import Adapty
import UIKit

protocol ProductInfoModel {
    var id: String { get }
    var eligibleOffer: AdaptyProductDiscount? { get }
    var tagConverter: AdaptyUI.Text.ProductTagConverter { get }
}

struct EmptyProductInfo: ProductInfoModel {
    let id: String
    var eligibleOffer: AdaptyProductDiscount? { nil }
    var tagConverter: AdaptyUI.Text.ProductTagConverter { { _ in nil } }

    init(id: String) {
        self.id = id
    }
}

struct RealProductInfo: ProductInfoModel {
    let product: AdaptyPaywallProduct
    let introEligibility: AdaptyEligibility

    var eligibleOffer: AdaptyProductDiscount? { product.eligibleDiscount(introEligibility: introEligibility) }

    init(product: AdaptyPaywallProduct, introEligibility: AdaptyEligibility) {
        self.product = product
        self.introEligibility = introEligibility
    }

    var id: String { product.vendorProductId }

    var tagConverter: AdaptyUI.Text.ProductTagConverter {
        { tag in
            switch tag {
            case .title: return product.localizedTitle
            case .price: return product.localizedPrice
            case .pricePerDay: return product.pricePer(period: .day)
            case .pricePerWeek: return product.pricePer(period: .week)
            case .pricePerMonth: return product.pricePer(period: .month)
            case .pricePerYear: return product.pricePer(period: .year)
            case .offerPrice:
                return product.eligibleDiscount(introEligibility: introEligibility)?.localizedPrice
            case .offerPeriods:
                return product.eligibleDiscount(introEligibility: introEligibility)?.localizedSubscriptionPeriod
            case .offerNumberOfPeriods:
                return product.eligibleDiscount(introEligibility: introEligibility)?.localizedNumberOfPeriods
            }
        }
    }
}

extension ProductInfoModel {
    static func empty(id: String) -> ProductInfoModel {
        EmptyProductInfo(id: id)
    }

    static func real(product: AdaptyPaywallProduct, introEligibility: AdaptyEligibility) -> ProductInfoModel {
        RealProductInfo(product: product, introEligibility: introEligibility)
    }
}
