
import Foundation

/// Represents and wraps a method for modifying request before an image download request starts in an asynchronous way.
protocol AsyncImageDownloadRequestModifier {
    /// This method will be called just before the `request` being sent.
    /// This is the last chance you can modify the image download request. You can modify the request for some
    /// customizing purpose, such as adding auth token to the header, do basic HTTP auth or something like url mapping.
    /// When you have done with the modification, call the `reportModified` block with the modified request and the data
    /// download will happen with this request.
    ///
    /// Usually, you pass an `AsyncImageDownloadRequestModifier` as the associated value of
    /// `KingfisherOptionsInfoItem.requestModifier` and use it as the `options` parameter in related methods.
    ///
    /// If you do nothing with the input `request` and return it as is, a downloading process will start with it.
    ///
    /// - Parameters:
    ///   - request: The input request contains necessary information like `url`. This request is generated
    ///              according to your resource url as a GET request.
    ///   - reportModified: The callback block you need to call after the asynchronous modifying done.
    ///
    func modified(for request: URLRequest, reportModified: @escaping (URLRequest?) -> Void)

    /// A block will be called when the download task started.
    ///
    /// If an `AsyncImageDownloadRequestModifier` and the asynchronous modification happens before the download, the
    /// related download method will not return a valid `DownloadTask` value. Instead, you can get one from this method.
    var onDownloadTaskStarted: ((DownloadTask?) -> Void)? { get }
}

/// Represents and wraps a method for modifying request before an image download request starts.
protocol ImageDownloadRequestModifier: AsyncImageDownloadRequestModifier {
    /// This method will be called just before the `request` being sent.
    /// This is the last chance you can modify the image download request. You can modify the request for some
    /// customizing purpose, such as adding auth token to the header, do basic HTTP auth or something like url mapping.
    ///
    /// Usually, you pass an `ImageDownloadRequestModifier` as the associated value of
    /// `KingfisherOptionsInfoItem.requestModifier` and use it as the `options` parameter in related methods.
    ///
    /// If you do nothing with the input `request` and return it as is, a downloading process will start with it.
    ///
    /// - Parameter request: The input request contains necessary information like `url`. This request is generated
    ///                      according to your resource url as a GET request.
    /// - Returns: A modified version of request, which you wish to use for downloading an image. If `nil` returned,
    ///            a `KingfisherError.requestError` with `.emptyRequest` as its reason will occur.
    ///
    func modified(for request: URLRequest) -> URLRequest?
}

extension ImageDownloadRequestModifier {
    func modified(for request: URLRequest, reportModified: @escaping (URLRequest?) -> Void) {
        let request = modified(for: request)
        reportModified(request)
    }

    /// This is `nil` for a sync `ImageDownloadRequestModifier` by default. You can get the `DownloadTask` from the
    /// return value of downloader method.
    var onDownloadTaskStarted: ((DownloadTask?) -> Void)? { return nil }
}

/// A wrapper for creating an `ImageDownloadRequestModifier` easier.
/// This type conforms to `ImageDownloadRequestModifier` and wraps an image modify block.
struct AnyModifier: ImageDownloadRequestModifier {
    let block: (URLRequest) -> URLRequest?

    /// For `ImageDownloadRequestModifier` conformation.
    func modified(for request: URLRequest) -> URLRequest? {
        return block(request)
    }

    /// Creates a value of `ImageDownloadRequestModifier` which runs `modify` block.
    ///
    /// - Parameter modify: The request modifying block runs when a request modifying task comes.
    ///                     The return `URLRequest?` value of this block will be used as the image download request.
    ///                     If `nil` returned, a `KingfisherError.requestError` with `.emptyRequest` as its
    ///                     reason will occur.
    init(modify: @escaping (URLRequest) -> URLRequest?) {
        block = modify
    }
}
