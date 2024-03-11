//
//  Source.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation

/// Represents an image setting source for Kingfisher methods.
///
/// A `Source` value indicates the way how the target image can be retrieved and cached.
///
/// - network: The target image should be got from network remotely. The associated `Resource`
///            value defines detail information like image URL and cache key.
/// - provider: The target image should be provided in a data format. Normally, it can be an image
///             from local storage or in any other encoding format (like Base64).
enum Source {
    /// Represents the source task identifier when setting an image to a view with extension methods.
    enum Identifier {
        /// The underlying value type of source identifier.
        typealias Value = UInt
        private(set) static var current: Value = 0
        static func next() -> Value {
            current += 1
            return current
        }
    }

    // MARK: Member Cases

    /// The target image should be got from network remotely. The associated `Resource`
    /// value defines detail information like image URL and cache key.
    case network(Resource)

    /// The target image should be provided in a data format. Normally, it can be an image
    /// from local storage or in any other encoding format (like Base64).
    case provider(ImageDataProvider)

    // MARK: Getting Properties

    /// The cache key defined for this source value.
    var cacheKey: String {
        switch self {
        case let .network(resource): return resource.cacheKey
        case let .provider(provider): return provider.cacheKey
        }
    }

    /// The URL defined for this source value.
    ///
    /// For a `.network` source, it is the `downloadURL` of associated `Resource` instance.
    /// For a `.provider` value, it is always `nil`.
    var url: URL? {
        switch self {
        case let .network(resource): return resource.downloadURL
        case let .provider(provider): return provider.contentURL
        }
    }
}

extension Source: Hashable {
    static func == (lhs: Source, rhs: Source) -> Bool {
        switch (lhs, rhs) {
        case let (.network(r1), .network(r2)):
            return r1.cacheKey == r2.cacheKey && r1.downloadURL == r2.downloadURL
        case let (.provider(p1), .provider(p2)):
            return p1.cacheKey == p2.cacheKey && p1.contentURL == p2.contentURL
        case (.provider(_), .network(_)):
            return false
        case (.network(_), .provider(_)):
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .network(r):
            hasher.combine(r.cacheKey)
            hasher.combine(r.downloadURL)
        case let .provider(p):
            hasher.combine(p.cacheKey)
            hasher.combine(p.contentURL)
        }
    }
}

extension Source {
    var asResource: Resource? {
        guard case let .network(resource) = self else {
            return nil
        }
        return resource
    }
}
