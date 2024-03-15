//
//  AdaptyImageCache.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Adapty
import Foundation

extension AdaptyUI {
    static let imageCache = ImageCache(name: "Adapty")
    static let imageDownloader = ImageDownloader(name: "Adapty")

    public struct CacheConfiguration {
        /// Total cost limit of the storage in bytes.
        public var memoryStorageTotalCostLimit: Int

        /// The item count limit of the memory storage.
        public var memoryStorageCountLimit: Int

        /// The file size limit on disk of the storage in bytes. 0 means no limit.
        public var diskStorageSizeLimit: UInt

        public init(
            memoryStorageTotalCostLimit: Int = 100 * 1024 * 1024, // 100MB
            memoryStorageCountLimit: Int = .max,
            diskStorageSizeLimit: UInt = 100 * 1024 * 1024 // 100MB
        ) {
            self.memoryStorageTotalCostLimit = memoryStorageTotalCostLimit
            self.memoryStorageCountLimit = memoryStorageCountLimit
            self.diskStorageSizeLimit = diskStorageSizeLimit
        }
    }
    
    static var currentCacheConfiguration: CacheConfiguration?

    static func configureImageCacheIfNeeded() {
        if currentCacheConfiguration == nil {
            configureImageCache(.init())
        }
    }
    
    public static func configureImageCache(_ configuration: CacheConfiguration) {
        imageCache.memoryStorage.config.totalCostLimit = configuration.memoryStorageTotalCostLimit
        imageCache.memoryStorage.config.countLimit = configuration.memoryStorageCountLimit
        imageCache.diskStorage.config.sizeLimit = configuration.diskStorageSizeLimit
        imageCache.diskStorage.config.expiration = .never
        
        currentCacheConfiguration = configuration
    }

    public static func clearImageCache() {
        imageCache.clearMemoryCache()
        imageCache.clearDiskCache()
    }
}

extension AdaptyUI {
    static func chacheImagesIfNeeded(viewConfiguration: AdaptyUI.ViewConfiguration, locale: String) {
        configureImageCacheIfNeeded()
        
        let urls = viewConfiguration.extractImageUrls(locale)

        let prefetcher = ImagePrefetcher(
            sources: urls.map { .network($0) },
            options: [
                .targetCache(imageCache),
                .downloader(imageDownloader),
            ]
        )

        prefetcher.start()
    }
}
