//
//  Storage.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation

/// Constants for some time intervals
struct TimeConstants {
    static let secondsInOneDay = 86400
}

/// Represents the expiration strategy used in storage.
///
/// - never: The item never expires.
/// - seconds: The item expires after a time duration of given seconds from now.
/// - days: The item expires after a time duration of given days from now.
/// - date: The item expires after a given date.
enum StorageExpiration {
    /// The item never expires.
    case never
    /// The item expires after a time duration of given seconds from now.
    case seconds(TimeInterval)
    /// The item expires after a time duration of given days from now.
    case days(Int)
    /// The item expires after a given date.
    case date(Date)
    /// Indicates the item is already expired. Use this to skip cache.
    case expired

    func estimatedExpirationSince(_ date: Date) -> Date {
        switch self {
        case .never: return .distantFuture
        case let .seconds(seconds):
            return date.addingTimeInterval(seconds)
        case let .days(days):
            let duration: TimeInterval = TimeInterval(TimeConstants.secondsInOneDay) * TimeInterval(days)
            return date.addingTimeInterval(duration)
        case let .date(ref):
            return ref
        case .expired:
            return .distantPast
        }
    }

    var estimatedExpirationSinceNow: Date {
        return estimatedExpirationSince(Date())
    }

    var isExpired: Bool {
        return timeInterval <= 0
    }

    var timeInterval: TimeInterval {
        switch self {
        case .never: return .infinity
        case let .seconds(seconds): return seconds
        case let .days(days): return TimeInterval(TimeConstants.secondsInOneDay) * TimeInterval(days)
        case let .date(ref): return ref.timeIntervalSinceNow
        case .expired: return -(.infinity)
        }
    }
}

/// Represents the expiration extending strategy used in storage to after access.
///
/// - none: The item expires after the original time, without extending after access.
/// - cacheTime: The item expiration extends by the original cache time after each access.
/// - expirationTime: The item expiration extends by the provided time after each access.
enum ExpirationExtending {
    /// The item expires after the original time, without extending after access.
    case none
    /// The item expiration extends by the original cache time after each access.
    case cacheTime
    /// The item expiration extends by the provided time after each access.
    case expirationTime(_ expiration: StorageExpiration)
}

/// Represents types which cost in memory can be calculated.
protocol CacheCostCalculable {
    var cacheCost: Int { get }
}

/// Represents types which can be converted to and from data.
protocol DataTransformable {
    func toData() throws -> Data
    static func fromData(_ data: Data) throws -> Self
    static var empty: Self { get }
}
