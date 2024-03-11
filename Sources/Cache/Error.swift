//
//  ImageCache+Error.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation

enum KingfisherError: Error {
    /// Represents the error reason during Kingfisher caching system.
    ///
    /// - fileEnumeratorCreationFailed: Cannot create a file enumerator for a certain disk URL. Code 3001.
    /// - invalidFileEnumeratorContent: Cannot get correct file contents from a file enumerator. Code 3002.
    /// - invalidURLResource: The file at target URL exists, but its URL resource is unavailable. Code 3003.
    /// - cannotLoadDataFromDisk: The file at target URL exists, but the data cannot be loaded from it. Code 3004.
    /// - cannotCreateDirectory: Cannot create a folder at a given path. Code 3005.
    /// - imageNotExisting: The requested image does not exist in cache. Code 3006.
    /// - cannotConvertToData: Cannot convert an object to data for storing. Code 3007.
    /// - cannotSerializeImage: Cannot serialize an image to data for storing. Code 3008.
    /// - cannotCreateCacheFile: Cannot create the cache file at a certain fileURL under a key. Code 3009.
    /// - cannotSetCacheFileAttribute: Cannot set file attributes to a cached file. Code 3010.
    enum CacheErrorReason {
        /// Cannot create a file enumerator for a certain disk URL. Code 3001.
        /// - url: The target disk URL from which the file enumerator should be created.
        case fileEnumeratorCreationFailed(url: URL)

        /// Cannot get correct file contents from a file enumerator. Code 3002.
        /// - url: The target disk URL from which the content of a file enumerator should be got.
        case invalidFileEnumeratorContent(url: URL)

        /// The file at target URL exists, but its URL resource is unavailable. Code 3003.
        /// - error: The underlying error thrown by file manager.
        /// - key: The key used to getting the resource from cache.
        /// - url: The disk URL where the target cached file exists.
        case invalidURLResource(error: Error, key: String, url: URL)

        /// The file at target URL exists, but the data cannot be loaded from it. Code 3004.
        /// - url: The disk URL where the target cached file exists.
        /// - error: The underlying error which describes why this error happens.
        case cannotLoadDataFromDisk(url: URL, error: Error)

        /// Cannot create a folder at a given path. Code 3005.
        /// - path: The disk path where the directory creating operation fails.
        /// - error: The underlying error which describes why this error happens.
        case cannotCreateDirectory(path: String, error: Error)

        /// The requested image does not exist in cache. Code 3006.
        /// - key: Key of the requested image in cache.
        case imageNotExisting(key: String)

        /// Cannot convert an object to data for storing. Code 3007.
        /// - object: The object which needs be convert to data.
        case cannotConvertToData(object: Any, error: Error)

        /// Cannot serialize an image to data for storing. Code 3008.
        /// - image: The input image needs to be serialized to cache.
        /// - original: The original image data, if exists.
        /// - serializer: The `CacheSerializer` used for the image serializing.
        case cannotSerializeImage(image: KFCrossPlatformImage?, original: Data?, serializer: CacheSerializer)

        /// Cannot create the cache file at a certain fileURL under a key. Code 3009.
        /// - fileURL: The url where the cache file should be created.
        /// - key: The cache key used for the cache. When caching a file through `KingfisherManager` and Kingfisher's
        ///        extension method, it is the resolved cache key based on your input `Source` and the image processors.
        /// - data: The data to be cached.
        /// - error: The underlying error originally thrown by Foundation when writing the `data` to the disk file at
        ///          `fileURL`.
        case cannotCreateCacheFile(fileURL: URL, key: String, data: Data, error: Error)

        /// Cannot set file attributes to a cached file. Code 3010.
        /// - filePath: The path of target cache file.
        /// - attributes: The file attribute to be set to the target file.
        /// - error: The underlying error originally thrown by Foundation when setting the `attributes` to the disk
        ///          file at `filePath`.
        case cannotSetCacheFileAttribute(filePath: String, attributes: [FileAttributeKey: Any], error: Error)

        /// The disk storage of cache is not ready. Code 3011.
        ///
        /// This is usually due to extremely lack of space on disk storage, and
        /// Kingfisher failed even when creating the cache folder. The disk storage will be in unusable state. Normally,
        /// ask user to free some spaces and restart the app to make the disk storage work again.
        /// - cacheURL: The intended URL which should be the storage folder.
        case diskStorageIsNotReady(cacheURL: URL)
    }

    /// Represents the error reason during image processing phase.
    ///
    /// - processingFailed: Image processing fails. There is no valid output image from the processor. Code 4001.
    enum ProcessorErrorReason {
        /// Image processing fails. There is no valid output image from the processor. Code 4001.
        /// - processor: The `ImageProcessor` used to process the image or its data in `item`.
        /// - item: The image or its data content.
        case processingFailed(processor: ImageProcessor, item: ImageProcessItem)
    }

    /// Represents the error reason during networking request phase.
    ///
    /// - emptyRequest: The request is empty. Code 1001.
    /// - invalidURL: The URL of request is invalid. Code 1002.
    /// - taskCancelled: The downloading task is cancelled by user. Code 1003.
    enum RequestErrorReason {
        /// The request is empty. Code 1001.
        case emptyRequest

        /// The URL of request is invalid. Code 1002.
        /// - request: The request is tend to be sent but its URL is invalid.
        case invalidURL(request: URLRequest)

        /// The downloading task is cancelled by user. Code 1003.
        /// - task: The session data task which is cancelled.
        /// - token: The cancel token which is used for cancelling the task.
        case taskCancelled(task: SessionDataTask, token: SessionDataTask.CancelToken)
    }

    /// Represents the error reason during networking response phase.
    ///
    /// - invalidURLResponse: The response is not a valid URL response. Code 2001.
    /// - invalidHTTPStatusCode: The response contains an invalid HTTP status code. Code 2002.
    /// - URLSessionError: An error happens in the system URL session. Code 2003.
    /// - dataModifyingFailed: Data modifying fails on returning a valid data. Code 2004.
    /// - noURLResponse: The task is done but no URL response found. Code 2005.
    enum ResponseErrorReason {
        /// The response is not a valid URL response. Code 2001.
        /// - response: The received invalid URL response.
        ///             The response is expected to be an HTTP response, but it is not.
        case invalidURLResponse(response: URLResponse)

        /// The response contains an invalid HTTP status code. Code 2002.
        /// - Note:
        ///   By default, status code 200..<400 is recognized as valid. You can override
        ///   this behavior by conforming to the `ImageDownloaderDelegate`.
        /// - response: The received response.
        case invalidHTTPStatusCode(response: HTTPURLResponse)

        /// An error happens in the system URL session. Code 2003.
        /// - error: The underlying URLSession error object.
        case URLSessionError(error: Error)

        /// Data modifying fails on returning a valid data. Code 2004.
        /// - task: The failed task.
        case dataModifyingFailed(task: SessionDataTask)

        /// The task is done but no URL response found. Code 2005.
        /// - task: The failed task.
        case noURLResponse(task: SessionDataTask)

        /// The task is cancelled by `ImageDownloaderDelegate` due to the `.cancel` response disposition is
        /// specified by the delegate method. Code 2006.
        case cancelledByDelegate(response: URLResponse)
    }
    
    
    /// Represents the error reason during image setting in a view related class.
    ///
    /// - emptySource: The input resource is empty or `nil`. Code 5001.
    /// - notCurrentSourceTask: The source task is finished, but it is not the one expected now. Code 5002.
    /// - dataProviderError: An error happens during getting data from an `ImageDataProvider`. Code 5003.
    public enum ImageSettingErrorReason {
        
        /// The input resource is empty or `nil`. Code 5001.
        case emptySource
        
        /// The resource task is finished, but it is not the one expected now. This usually happens when you set another
        /// resource on the view without cancelling the current on-going one. The previous setting task will fail with
        /// this `.notCurrentSourceTask` error when a result got, regardless of it being successful or not for that task.
        /// The result of this original task is contained in the associated value.
        /// Code 5002.
        /// - result: The `RetrieveImageResult` if the source task is finished without problem. `nil` if an error
        ///           happens.
        /// - error: The `Error` if an issue happens during image setting task. `nil` if the task finishes without
        ///          problem.
        /// - source: The original source value of the task.
        case notCurrentSourceTask(result: RetrieveImageResult?, error: Error?, source: Source)

        /// An error happens during getting data from an `ImageDataProvider`. Code 5003.
        case dataProviderError(provider: ImageDataProvider, error: Error)

        /// No more alternative `Source` can be used in current loading process. It means that the
        /// `.alternativeSources` are used and Kingfisher tried to recovery from the original error, but still
        /// fails for all the given alternative sources. The associated value holds all the errors encountered during
        /// the load process, including the original source loading error and all the alternative sources errors.
        /// Code 5004.
        case alternativeSourcesExhausted([PropagationError])
    }

    /// Represents the error reason during Kingfisher caching system.
    case cacheError(reason: CacheErrorReason)

    /// Represents the error reason during image processing phase.
    case processorError(reason: ProcessorErrorReason)

    /// Represents the error reason during networking request phase.
    case requestError(reason: RequestErrorReason)

    /// Represents the error reason during networking response phase.
    case responseError(reason: ResponseErrorReason)

    /// Represents the error reason during image setting in a view related class.
    case imageSettingError(reason: ImageSettingErrorReason)
    
    // MARK: Helper Properties & Methods

    /// Helper property to check whether this error is a `RequestErrorReason.taskCancelled` or not.
    var isTaskCancelled: Bool {
        if case .requestError(reason: .taskCancelled) = self {
            return true
        }
        return false
    }

    var isLowDataModeConstrained: Bool {
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *),
           case let .responseError(reason: .URLSessionError(sessionError)) = self,
           let urlError = sessionError as? URLError,
           urlError.networkUnavailableReason == .constrained {
            return true
        }
        return false
    }
}
