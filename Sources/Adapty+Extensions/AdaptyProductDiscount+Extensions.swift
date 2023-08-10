//
//  AdaptyProductDiscount+Extensions.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import Foundation

extension AdaptyProductDiscount {
    // TODO: discuss localization
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
