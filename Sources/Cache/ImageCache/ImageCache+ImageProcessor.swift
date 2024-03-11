//
//  ImageCache+ImageProcessor.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation

/// Represents an item which could be processed by an `ImageProcessor`.
///
/// - image: Input image. The processor should provide a way to apply
///          processing on this `image` and return the result image.
/// - data:  Input data. The processor should provide a way to apply
///          processing on this `data` and return the result image.
enum ImageProcessItem {
    /// Input image. The processor should provide a way to apply
    /// processing on this `image` and return the result image.
    case image(KFCrossPlatformImage)

    /// Input data. The processor should provide a way to apply
    /// processing on this `data` and return the result image.
    case data(Data)
}

/// An `ImageProcessor` would be used to convert some downloaded data to an image.
protocol ImageProcessor {
    /// Identifier of the processor. It will be used to identify the processor when
    /// caching and retrieving an image. You might want to make sure that processors with
    /// same properties/functionality have the same identifiers, so correct processed images
    /// could be retrieved with proper key.
    ///
    /// - Note: Do not supply an empty string for a customized processor, which is already reserved by
    /// the `DefaultImageProcessor`. It is recommended to use a reverse domain name notation string of
    /// your own for the identifier.
    var identifier: String { get }

    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: The parsed options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: The return value should be `nil` if processing failed while converting an input item to image.
    ///         If `nil` received by the processing caller, an error will be reported and the process flow stops.
    ///         If the processing flow is not critical for your flow, then when the input item is already an image
    ///         (`.image` case) and there is any errors in the processing, you could return the input image itself
    ///         to keep the processing pipeline continuing.
    /// - Note: Most processor only supports CG-based images. watchOS is not supported for processors containing
    ///         a filter, the input image will be returned directly on watchOS.
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage?
}

// TODO: move out?
/// The default processor. It converts the input data to a valid image.
/// Images of .PNG, .JPEG and .GIF format are supported.
/// If an image item is given as `.image` case, `DefaultImageProcessor` will
/// do nothing on it and return the associated image.
struct DefaultImageProcessor: ImageProcessor {
    /// A default `DefaultImageProcessor` could be used across.
    static let `default` = DefaultImageProcessor()

    /// Identifier of the processor.
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    let identifier = ""

    /// Creates a `DefaultImageProcessor`. Use `DefaultImageProcessor.default` to get an instance,
    /// if you do not have a good reason to create your own `DefaultImageProcessor`.
    init() {}

    /// Processes the input `ImageProcessItem` with this processor.
    ///
    /// - Parameters:
    ///   - item: Input item which will be processed by `self`.
    ///   - options: Options when processing the item.
    /// - Returns: The processed image.
    ///
    /// - Note: See documentation of `ImageProcessor` protocol for more.
    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case let .image(image):
            return image.scaled(to: options.scaleFactor)
        case let .data(data):
            return KFCrossPlatformImage.image(data: data, options: options.imageCreatingOptions)
        }
    }
}
