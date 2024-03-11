//
//  Kingfisher.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation
#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// The downloading progress block type.
/// The parameter value is the `receivedSize` of current response.
/// The second parameter is the total expected data length from response's "Content-Length" header.
/// If the expected length is not available, this block will not be called.
typealias DownloadProgressBlock = (_ receivedSize: Int64, _ totalSize: Int64) -> Void

/// Represents the result of a Kingfisher retrieving image task.
struct RetrieveImageResult {
    /// Gets the image object of this result.
    let image: KFCrossPlatformImage

    /// Gets the cache source of the image. It indicates from which layer of cache this image is retrieved.
    /// If the image is just downloaded from network, `.none` will be returned.
    let cacheType: CacheType

    /// The `Source` which this result is related to. This indicated where the `image` of `self` is referring.
    let source: Source

    /// The original `Source` from which the retrieve task begins. It can be different from the `source` property.
    /// When an alternative source loading happened, the `source` will be the replacing loading target, while the
    /// `originalSource` will be kept as the initial `source` which issued the image loading process.
    let originalSource: Source

    /// Gets the data behind the result.
    ///
    /// If this result is from a network downloading (when `cacheType == .none`), calling this returns the downloaded
    /// data. If the reuslt is from cache, it serializes the image with the given cache serializer in the loading option
    /// and returns the result.
    ///
    /// - Note:
    /// This can be a time-consuming action, so if you need to use the data for multiple times, it is suggested to hold
    /// it and prevent keeping calling this too frequently.
    let data: () -> Data?
}

/// A struct that stores some related information of an `KingfisherError`. It provides some context information for
/// a pure error so you can identify the error easier.
struct PropagationError {
    /// The `Source` to which current `error` is bound.
    let source: Source

    /// The actual error happens in framework.
    let error: KingfisherError
}

/// The downloading task updated block type. The parameter `newTask` is the updated new task of image setting process.
/// It is a `nil` if the image loading does not require an image downloading process. If an image downloading is issued,
/// this value will contain the actual `DownloadTask` for you to keep and cancel it later if you need.
typealias DownloadTaskUpdatedBlock = (_ newTask: DownloadTask?) -> Void

/// Main manager class of Kingfisher. It connects Kingfisher downloader and cache,
/// to provide a set of convenience methods to use Kingfisher for tasks.
/// You can use this class to retrieve an image via a specified URL from web or cache.
class KingfisherManager {
    /// Represents a shared manager used across Kingfisher.
    /// Use this instance for getting or storing images with Kingfisher.
//    static let shared = KingfisherManager()

    // MARK: Properties

    /// The `ImageCache` used by this manager. It is `ImageCache.default` by default.
    /// If a cache is specified in `KingfisherManager.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
    var cache: ImageCache

    /// The `ImageDownloader` used by this manager. It is `ImageDownloader.default` by default.
    /// If a downloader is specified in `KingfisherManager.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
    var downloader: ImageDownloader

    /// Default options used by the manager. This option will be used in
    /// Kingfisher manager related methods, as well as all view extension methods.
    /// You can also passing other options for each image task by sending an `options` parameter
    /// to Kingfisher's APIs. The per image options will overwrite the default ones,
    /// if the option exists in both.
    var defaultOptions = KingfisherOptionsInfo.empty

    // Use `defaultOptions` to overwrite the `downloader` and `cache`.
    private var currentDefaultOptions: KingfisherOptionsInfo {
        return defaultOptions
    }

    private let processingQueue: CallbackQueue

//    private convenience init() {
//        self.init(downloader: .default, cache: .default)
//    }

    /// Creates an image setting manager with specified downloader and cache.
    ///
    /// - Parameters:
    ///   - downloader: The image downloader used to download images.
    ///   - cache: The image cache which stores memory and disk images.
    init(downloader: ImageDownloader, cache: ImageCache) {
        self.downloader = downloader
        self.cache = cache

        let processQueueName = "com.onevcat.Kingfisher.KingfisherManager.processQueue.\(UUID().uuidString)"
        processingQueue = .dispatch(DispatchQueue(label: processQueueName))
    }

    // MARK: - Getting Images

    /// Gets an image from a given resource.
    /// - Parameters:
    ///   - resource: The `Resource` object defines data information like key or URL.
    ///   - options: Options to use when creating the image.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called. `progressBlock` is always called in
    ///                    main queue.
    ///   - downloadTaskUpdated: Called when a new image downloading task is created for current image retrieving. This
    ///                          usually happens when an alternative source is used to replace the original (failed)
    ///                          task. You can update your reference of `DownloadTask` if you want to manually `cancel`
    ///                          the new task.
    ///   - completionHandler: Called when the image retrieved and set finished. This completion handler will be invoked
    ///                        from the `options.callbackQueue`. If not specified, the main queue will be used.
    /// - Returns: A task represents the image downloading. If there is a download task starts for `.network` resource,
    ///            the started `DownloadTask` is returned. Otherwise, `nil` is returned.
    ///
    /// - Note:
    ///    This method will first check whether the requested `resource` is already in cache or not. If cached,
    ///    it returns `nil` and invoke the `completionHandler` after the cached image retrieved. Otherwise, it
    ///    will download the `resource`, store it in cache, then call `completionHandler`.
    @discardableResult
    func retrieveImage(
        with resource: Resource,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        downloadTaskUpdated: DownloadTaskUpdatedBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask?
    {
        return retrieveImage(
            with: resource.convertToSource(),
            options: options,
            progressBlock: progressBlock,
            downloadTaskUpdated: downloadTaskUpdated,
            completionHandler: completionHandler
        )
    }

    /// Gets an image from a given resource.
    ///
    /// - Parameters:
    ///   - source: The `Source` object defines data information from network or a data provider.
    ///   - options: Options to use when creating the image.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called. `progressBlock` is always called in
    ///                    main queue.
    ///   - downloadTaskUpdated: Called when a new image downloading task is created for current image retrieving. This
    ///                          usually happens when an alternative source is used to replace the original (failed)
    ///                          task. You can update your reference of `DownloadTask` if you want to manually `cancel`
    ///                          the new task.
    ///   - completionHandler: Called when the image retrieved and set finished. This completion handler will be invoked
    ///                        from the `options.callbackQueue`. If not specified, the main queue will be used.
    /// - Returns: A task represents the image downloading. If there is a download task starts for `.network` resource,
    ///            the started `DownloadTask` is returned. Otherwise, `nil` is returned.
    ///
    /// - Note:
    ///    This method will first check whether the requested `source` is already in cache or not. If cached,
    ///    it returns `nil` and invoke the `completionHandler` after the cached image retrieved. Otherwise, it
    ///    will try to load the `source`, store it in cache, then call `completionHandler`.
    ///
    @discardableResult
    func retrieveImage(
        with source: Source,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        downloadTaskUpdated: DownloadTaskUpdatedBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask?
    {
        let options = currentDefaultOptions + (options ?? .empty)
        let info = KingfisherParsedOptionsInfo(options)
        return retrieveImage(
            with: source,
            options: info,
            progressBlock: progressBlock,
            downloadTaskUpdated: downloadTaskUpdated,
            completionHandler: completionHandler)
    }

    func retrieveImage(
        with source: Source,
        options: KingfisherParsedOptionsInfo,
        progressBlock: DownloadProgressBlock? = nil,
        downloadTaskUpdated: DownloadTaskUpdatedBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask?
    {
        retrieveImage(
            with: source,
            options: options,
            downloadTaskUpdated: downloadTaskUpdated,
            progressiveImageSetter: nil,
            completionHandler: completionHandler)
    }

    func retrieveImage(
        with source: Source,
        options: KingfisherParsedOptionsInfo,
        downloadTaskUpdated: DownloadTaskUpdatedBlock? = nil,
        progressiveImageSetter: ((KFCrossPlatformImage?) -> Void)? = nil,
        referenceTaskIdentifierChecker: (() -> Bool)? = nil,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask?
    {
        var options = options

        let retrievingContext = RetrievingContext(options: options, originalSource: source)
        var retryContext: RetryContext?

        func startNewRetrieveTask(
            with source: Source,
            downloadTaskUpdated: DownloadTaskUpdatedBlock?
        ) {
            let newTask = retrieveImage(with: source, context: retrievingContext) { result in
                handler(currentSource: source, result: result)
            }
            downloadTaskUpdated?(newTask)
        }

        func failCurrentSource(_ source: Source, with error: KingfisherError) {
            // Skip alternative sources if the user cancelled it.
            guard !error.isTaskCancelled else {
                completionHandler?(.failure(error))
                return
            }

            // When low data mode constrained error, retry with the low data mode source instead of use alternative on fly.
            guard !error.isLowDataModeConstrained else {
                completionHandler?(.failure(error))
                return
            }

            if retrievingContext.propagationErrors.isEmpty {
                completionHandler?(.failure(error))
            } else {
                retrievingContext.appendError(error, to: source)
                let finalError = KingfisherError.imageSettingError(
                    reason: .alternativeSourcesExhausted(retrievingContext.propagationErrors)
                )
                completionHandler?(.failure(finalError))
            }
        }

        func handler(currentSource: Source, result: Result<RetrieveImageResult, KingfisherError>) {
            switch result {
            case .success:
                completionHandler?(result)
            case let .failure(error):
                failCurrentSource(currentSource, with: error)
            }
        }

        return retrieveImage(
            with: source,
            context: retrievingContext) {
                result in
                handler(currentSource: source, result: result)
            }
    }

    private func retrieveImage(
        with source: Source,
        context: RetrievingContext,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask?
    {
        let options = context.options

        let loadedFromCache = retrieveImageFromCache(
            source: source,
            context: context,
            completionHandler: completionHandler)

        if loadedFromCache {
            return nil
        }

        return loadAndCacheImage(
            source: source,
            context: context,
            completionHandler: completionHandler)?.value
    }

    func provideImage(
        provider: ImageDataProvider,
        options: KingfisherParsedOptionsInfo,
        completionHandler: ((Result<ImageLoadingResult, KingfisherError>) -> Void)?) {
        guard let completionHandler = completionHandler else { return }
        provider.data { result in
            switch result {
            case let .success(data):
                (options.processingQueue ?? self.processingQueue).execute {
                    let processor = options.processor
                    let processingItem = ImageProcessItem.data(data)
                    guard let image = processor.process(item: processingItem, options: options) else {
                        options.callbackQueue.execute {
                            let error = KingfisherError.processorError(
                                reason: .processingFailed(processor: processor, item: processingItem))
                            completionHandler(.failure(error))
                        }
                        return
                    }

                    options.callbackQueue.execute {
                        let result = ImageLoadingResult(image: image, url: nil, originalData: data)
                        completionHandler(.success(result))
                    }
                }
            case let .failure(error):
                options.callbackQueue.execute {
                    let error = KingfisherError.imageSettingError(
                        reason: .dataProviderError(provider: provider, error: error))
                    completionHandler(.failure(error))
                }
            }
        }
    }

    private func cacheImage(
        source: Source,
        options: KingfisherParsedOptionsInfo,
        context: RetrievingContext,
        result: Result<ImageLoadingResult, KingfisherError>,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?
    ) {
        switch result {
        case let .success(value):
            let needToCacheOriginalImage = false
            let coordinator = CacheCallbackCoordinator(
                shouldWaitForCache: true, shouldCacheOriginal: false)
            let result = RetrieveImageResult(
                image: value.image,
                cacheType: .none,
                source: source,
                originalSource: context.originalSource,
                data: { value.originalData }
            )
            // Add image to cache.
            let targetCache = cache

            targetCache.store(
                value.image,
                original: value.originalData,
                forKey: source.cacheKey,
                options: options,
                toDisk: true) {
                    _ in
                    coordinator.apply(.cachingImage) {
                        completionHandler?(.success(result))
                    }
                }

            coordinator.apply(.cacheInitiated) {
                completionHandler?(.success(result))
            }

        case let .failure(error):
            completionHandler?(.failure(error))
        }
    }

    @discardableResult
    func loadAndCacheImage(
        source: Source,
        context: RetrievingContext,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> DownloadTask.WrappedTask?
    {
        let options = context.options
        func _cacheImage(_ result: Result<ImageLoadingResult, KingfisherError>) {
            cacheImage(
                source: source,
                options: options,
                context: context,
                result: result,
                completionHandler: completionHandler
            )
        }

        switch source {
        case let .network(resource):
            let downloader = self.downloader
            let task = downloader.downloadImage(
                with: resource.downloadURL, options: options, completionHandler: _cacheImage
            )

            // The code below is neat, but it fails the Swift 5.2 compiler with a runtime crash when
            // `BUILD_LIBRARY_FOR_DISTRIBUTION` is turned on. I believe it is a bug in the compiler.
            // Let's fallback to a traditional style before it can be fixed in Swift.
            //
            // https://github.com/onevcat/Kingfisher/issues/1436
            //
            // return task.map(DownloadTask.WrappedTask.download)

            if let task = task {
                return .download(task)
            } else {
                return nil
            }

        case let .provider(provider):
            provideImage(provider: provider, options: options, completionHandler: _cacheImage)
            return .dataProviding
        }
    }

    /// Retrieves image from memory or disk cache.
    ///
    /// - Parameters:
    ///   - source: The target source from which to get image.
    ///   - key: The key to use when caching the image.
    ///   - url: Image request URL. This is not used when retrieving image from cache. It is just used for
    ///          `RetrieveImageResult` callback compatibility.
    ///   - options: Options on how to get the image from image cache.
    ///   - completionHandler: Called when the image retrieving finishes, either with succeeded
    ///                        `RetrieveImageResult` or an error.
    /// - Returns: `true` if the requested image or the original image before being processed is existing in cache.
    ///            Otherwise, this method returns `false`.
    ///
    /// - Note:
    ///    The image retrieving could happen in either memory cache or disk cache. The `.processor` option in
    ///    `options` will be considered when searching in the cache. If no processed image is found, Kingfisher
    ///    will try to check whether an original version of that image is existing or not. If there is already an
    ///    original, Kingfisher retrieves it from cache and processes it. Then, the processed image will be store
    ///    back to cache for later use.
    func retrieveImageFromCache(
        source: Source,
        context: RetrievingContext,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?) -> Bool {
        let options = context.options
        // 1. Check whether the image was already in target cache. If so, just get it.
        let targetCache = cache
        let key = source.cacheKey
        let targetImageCached = targetCache.imageCachedType(
            forKey: key, processorIdentifier: options.processor.identifier)

        let validCache = targetImageCached.cached &&
            (options.fromMemoryCacheOrRefresh == false || targetImageCached == .memory)

        if validCache {
            targetCache.retrieveImage(forKey: key, options: options) { result in
                guard let completionHandler = completionHandler else { return }

                func checkResultImageAndCallback(_ inputImage: KFCrossPlatformImage) {
                    var image = inputImage

                    let value = result.map {
                        RetrieveImageResult(
                            image: image,
                            cacheType: $0.cacheType,
                            source: source,
                            originalSource: context.originalSource,
                            data: { options.cacheSerializer.data(with: image, original: nil) }
                        )
                    }
                    completionHandler(value)
                }

                result.match { cacheResult in
                    options.callbackQueue.execute {
                        guard let image = cacheResult.image else {
                            completionHandler(.failure(KingfisherError.cacheError(reason: .imageNotExisting(key: key))))
                            return
                        }

                        if options.cacheSerializer.originalDataUsed {
                            let processor = options.processor
                            (options.processingQueue ?? self.processingQueue).execute {
                                let item = ImageProcessItem.image(image)
                                guard let processedImage = processor.process(item: item, options: options) else {
                                    let error = KingfisherError.processorError(
                                        reason: .processingFailed(processor: processor, item: item))
                                    options.callbackQueue.execute { completionHandler(.failure(error)) }
                                    return
                                }
                                options.callbackQueue.execute {
                                    checkResultImageAndCallback(processedImage)
                                }
                            }
                        } else {
                            checkResultImageAndCallback(image)
                        }
                    }
                } onFailure: { _ in
                    options.callbackQueue.execute {
                        completionHandler(.failure(KingfisherError.cacheError(reason: .imageNotExisting(key: key))))
                    }
                }
            }
            return true
        }

        return false
    }
}

class RetrievingContext {
    var options: KingfisherParsedOptionsInfo

    let originalSource: Source
    var propagationErrors: [PropagationError] = []

    init(options: KingfisherParsedOptionsInfo, originalSource: Source) {
        self.originalSource = originalSource
        self.options = options
    }

    @discardableResult
    func appendError(_ error: KingfisherError, to source: Source) -> [PropagationError] {
        let item = PropagationError(source: source, error: error)
        propagationErrors.append(item)
        return propagationErrors
    }
}

class CacheCallbackCoordinator {
    enum State {
        case idle
        case imageCached
        case originalImageCached
        case done
    }

    enum Action {
        case cacheInitiated
        case cachingImage
        case cachingOriginalImage
    }

    private let shouldWaitForCache: Bool
    private let shouldCacheOriginal: Bool
    private let stateQueue: DispatchQueue
    private var threadSafeState: State = .idle

    private(set) var state: State {
        set { stateQueue.sync { threadSafeState = newValue } }
        get { stateQueue.sync { threadSafeState } }
    }

    init(shouldWaitForCache: Bool, shouldCacheOriginal: Bool) {
        self.shouldWaitForCache = shouldWaitForCache
        self.shouldCacheOriginal = shouldCacheOriginal
        let stateQueueName = "com.onevcat.Kingfisher.CacheCallbackCoordinator.stateQueue.\(UUID().uuidString)"
        stateQueue = DispatchQueue(label: stateQueueName)
    }

    func apply(_ action: Action, trigger: () -> Void) {
        switch (state, action) {
        case (.done, _):
            break

        // From .idle
        case (.idle, .cacheInitiated):
            if !shouldWaitForCache {
                state = .done
                trigger()
            }
        case (.idle, .cachingImage):
            if shouldCacheOriginal {
                state = .imageCached
            } else {
                state = .done
                trigger()
            }
        case (.idle, .cachingOriginalImage):
            state = .originalImageCached

        // From .imageCached
        case (.imageCached, .cachingOriginalImage):
            state = .done
            trigger()

        // From .originalImageCached
        case (.originalImageCached, .cachingImage):
            state = .done
            trigger()

        default:
            assertionFailure("This case should not happen in CacheCallbackCoordinator: \(state) - \(action)")
        }
    }
}
