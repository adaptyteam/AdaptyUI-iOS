//
//  AdaptyProductSubscriptionPeriodExtensions.swift
//
//
//  Created by Alexey Goncharov on 2023-01-24.
//

import Adapty
import Foundation

extension AdaptyProductSubscriptionPeriod {
    func numberOfWeeks() -> Int {
        switch unit {
        case .day:
            return numberOfUnits / 7
        case .week:
            return numberOfUnits
        case .month:
            return numberOfUnits * 4
        case .year:
            return numberOfUnits * 52
        case .unknown:
            return 0
        }
    }
}
