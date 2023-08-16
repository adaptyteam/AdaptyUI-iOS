//
//  AdaptyPaywallProductExtensions.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Foundation

extension AdaptyPaywallProduct {
    @available(*, deprecated)
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
    
    func eligibleDiscount(introEligibility: AdaptyEligibility) -> AdaptyProductDiscount? {
        if let promotionalOfferId = promotionalOfferId,
           let promotionalOffer = discounts.first(where: { $0.identifier == promotionalOfferId }) {
            return promotionalOffer
        } else if introEligibility == .eligible {
            return introductoryDiscount
        } else {
            return nil
        }
    }
}

extension AdaptyPaywallProduct {
    func pricePer(period: AdaptyPeriodUnit) -> String? {
        guard let subscriptionPeriod = subscriptionPeriod else { return nil }
        
        let numberOfPeriods = subscriptionPeriod.numberOfPeriods(period)
        guard numberOfPeriods > 0.0 else { return nil }
        
        let numberOfPeriodsDecimal = Decimal(floatLiteral: numberOfPeriods)
        let pricePerPeriod = price / numberOfPeriodsDecimal
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = skProduct.priceLocale
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .ceiling
        
        return formatter.string(from: NSDecimalNumber(decimal: pricePerPeriod))
    }
}
