//
//  Resource.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation

/// Represents an image resource at a certain url and a given cache key.
/// Kingfisher will use a `Resource` to download a resource from network and cache it with the cache key when
/// using `Source.network` as its image setting source.
protocol Resource {
    /// The key used in cache.
    var cacheKey: String { get }

    /// The target image URL.
    var downloadURL: URL { get }
}

extension Resource {
    /// Converts `self` to a valid `Source` based on its `downloadURL` scheme. A `.provider` with
    /// `LocalFileImageDataProvider` associated will be returned if the URL points to a local file. Otherwise,
    /// `.network` is returned.
    func convertToSource(overrideCacheKey: String? = nil) -> Source {
        let key = overrideCacheKey ?? cacheKey
        return downloadURL.isFileURL ?
            .provider(LocalFileImageDataProvider(fileURL: downloadURL, cacheKey: key)) :
            .network(KF.ImageResource(downloadURL: downloadURL, cacheKey: key))
    }
}

struct KF {}

extension KF {
    /// ImageResource is a simple combination of `downloadURL` and `cacheKey`.
    /// When passed to image view set methods, Kingfisher will try to download the target
    /// image from the `downloadURL`, and then store it with the `cacheKey` as the key in cache.
    struct ImageResource: Resource {
        // MARK: - Initializers

        /// Creates an image resource.
        ///
        /// - Parameters:
        ///   - downloadURL: The target image URL from where the image can be downloaded.
        ///   - cacheKey: The cache key. If `nil`, Kingfisher will use the `absoluteString` of `downloadURL` as the key.
        ///               Default is `nil`.
        init(downloadURL: URL, cacheKey: String? = nil) {
            self.downloadURL = downloadURL
            self.cacheKey = cacheKey ?? downloadURL.cacheKey
        }

        // MARK: Protocol Conforming

        /// The key used in cache.
        let cacheKey: String

        /// The target image URL.
        let downloadURL: URL
    }
}

/// URL conforms to `Resource` in Kingfisher.
/// The `absoluteString` of this URL is used as `cacheKey`. And the URL itself will be used as `downloadURL`.
/// If you need customize the url and/or cache key, use `ImageResource` instead.
extension URL: Resource {
    var cacheKey: String { return isFileURL ? localFileCacheKey : absoluteString }
    var downloadURL: URL { return self }
}

extension URL {
    static let localFileCacheKeyPrefix = "kingfisher.local.cacheKey"

    // The special version of cache key for a local file on disk. Every time the app is reinstalled on the disk,
    // the system assigns a new container folder to hold the .app (and the extensions, .appex) folder. So the URL for
    // the same image in bundle might be different.
    //
    // This getter only uses the fixed part in the URL (until the bundle name folder) to provide a stable cache key
    // for the image under the same path inside the bundle.
    //
    // See #1825 (https://github.com/onevcat/Kingfisher/issues/1825)
    var localFileCacheKey: String {
        var validComponents: [String] = []
        for part in pathComponents.reversed() {
            validComponents.append(part)
            if part.hasSuffix(".app") || part.hasSuffix(".appex") {
                break
            }
        }
        let fixedPath = "\(Self.localFileCacheKeyPrefix)/\(validComponents.reversed().joined(separator: "/"))"
        if let q = query {
            return "\(fixedPath)?\(q)"
        } else {
            return fixedPath
        }
    }
}
