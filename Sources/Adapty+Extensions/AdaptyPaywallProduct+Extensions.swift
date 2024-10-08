//
//  AdaptyPaywallProductExtensions.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Foundation

extension AdaptyPaywallProduct {
    func eligibleDiscount(introEligibility: AdaptyEligibility) -> AdaptyProductDiscount? {
        if promotionalOfferEligibility, let promotionalOfferId = promotionalOfferId,
           let promotionalOffer = discount(byIdentifier: promotionalOfferId) {
            return promotionalOffer
        } else if introEligibility == .eligible {
            return introductoryDiscount
        } else {
            return nil
        }
    }

    func pricePer(period: AdaptyPeriodUnit) -> String? {
        guard let subscriptionPeriod = subscriptionPeriod else { return nil }

        let numberOfPeriods = subscriptionPeriod.numberOfPeriods(period)
        guard numberOfPeriods > 0.0 else { return nil }

        let numberOfPeriodsDecimal = Decimal(floatLiteral: numberOfPeriods)
        let pricePerPeriod = price / numberOfPeriodsDecimal
        let nsDecimalPricePerPeriod = NSDecimalNumber(decimal: pricePerPeriod)

        return skProduct.priceLocale.localized(price: nsDecimalPricePerPeriod)
    }
}
