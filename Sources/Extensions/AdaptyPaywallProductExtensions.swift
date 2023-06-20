//
//  AdaptyPaywallProductExtensions.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Foundation

extension AdaptyProductDiscount {
    func localizedDescriptionString() -> String? {
        switch paymentMode {
        case .payAsYouGo:
            return (localizedPrice ?? "") + " for " + (localizedSubscriptionPeriod ?? "")
        case .payUpFront:
            return (localizedPrice ?? "") + " for the first " + (localizedNumberOfPeriods ?? "")
        case .freeTrial:
            return (localizedSubscriptionPeriod ?? "") + " free trial"
        case .unknown:
            return nil
        }
    }
}

extension AdaptyPaywallProduct {
    func eligibleOfferString(introEligibility: AdaptyEligibility) -> String? {
        if let promotionalOfferId = promotionalOfferId,
           let promotionalOffer = discounts.first(where: { $0.identifier == promotionalOfferId }) {
            return promotionalOffer.localizedDescriptionString()
        } else if introEligibility == .eligible {
            return introductoryDiscount?.localizedDescriptionString()
        } else {
            return nil
        }
    }

    func perWeekPriceString() -> String? {
        guard let subscriptionPeriod = subscriptionPeriod else { return nil }

        let numberOfWeeks = subscriptionPeriod.numberOfWeeks()

        guard numberOfWeeks > 0 else { return nil }

        let numberOfWeeksDecimal = Decimal(integerLiteral: numberOfWeeks)
        let pricePerWeek = price / numberOfWeeksDecimal

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceLocale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .ceiling

        if let s = formatter.string(from: NSDecimalNumber(decimal: pricePerWeek)) {
            return "\(s)/week"
        } else {
            return nil
        }
    }
}
