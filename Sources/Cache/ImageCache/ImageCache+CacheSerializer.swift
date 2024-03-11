//
//  ImageCache+CacheSerializer.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation

/// An `CacheSerializer` is used to convert some data to an image object after
/// retrieving it from disk storage, and vice versa, to convert an image to data object
/// for storing to the disk storage.
protocol CacheSerializer {
    /// Gets the serialized data from a provided image
    /// and optional original data for caching to disk.
    ///
    /// - Parameters:
    ///   - image: The image needed to be serialized.
    ///   - original: The original data which is just downloaded.
    ///               If the image is retrieved from cache instead of
    ///               downloaded, it will be `nil`.
    /// - Returns: The data object for storing to disk, or `nil` when no valid
    ///            data could be serialized.
    func data(with image: KFCrossPlatformImage, original: Data?) -> Data?

    /// Gets an image from provided serialized data.
    ///
    /// - Parameters:
    ///   - data: The data from which an image should be deserialized.
    ///   - options: The parsed options for deserialization.
    /// - Returns: An image deserialized or `nil` when no valid image
    ///            could be deserialized.
    func image(with data: Data, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage?

    /// Whether this serializer prefers to cache the original data in its implementation.
    /// If `true`, after creating the image from the disk data, Kingfisher will continue to apply the processor to get
    /// the final image.
    ///
    /// By default, it is `false` and the actual processed image is assumed to be serialized to the disk.
    var originalDataUsed: Bool { get }
}

extension CacheSerializer {
    var originalDataUsed: Bool { false }
}

/// Represents a basic and default `CacheSerializer` used in Kingfisher disk cache system.
/// It could serialize and deserialize images in PNG, JPEG and GIF format. For
/// image other than these formats, a normalized `pngRepresentation` will be used.
struct DefaultCacheSerializer: CacheSerializer {
    /// The default general cache serializer used across Kingfisher's cache.
    static let `default` = DefaultCacheSerializer()

    /// The compression quality when converting image to a lossy format data. Default is 1.0.
    var compressionQuality: CGFloat = 1.0

    /// Whether the original data should be preferred when serializing the image.
    /// If `true`, the input original data will be checked first and used unless the data is `nil`.
    /// In that case, the serialization will fall back to creating data from image.
    var preferCacheOriginalData: Bool = false

    /// Returnes the `preferCacheOriginalData` value. When the original data is used, Kingfisher needs to re-apply the
    /// processors to get the desired final image.
    var originalDataUsed: Bool { preferCacheOriginalData }

    /// Creates a cache serializer that serialize and deserialize images in PNG, JPEG and GIF format.
    ///
    /// - Note:
    /// Use `DefaultCacheSerializer.default` unless you need to specify your own properties.
    ///
    init() { }

    /// - Parameters:
    ///   - image: The image needed to be serialized.
    ///   - original: The original data which is just downloaded.
    ///               If the image is retrieved from cache instead of
    ///               downloaded, it will be `nil`.
    /// - Returns: The data object for storing to disk, or `nil` when no valid
    ///            data could be serialized.
    ///
    /// - Note:
    /// Only when `original` contains valid PNG, JPEG and GIF format data, the `image` will be
    /// converted to the corresponding data type. Otherwise, if the `original` is provided but it is not
    /// If `original` is `nil`, the input `image` will be encoded as PNG data.
    func data(with image: KFCrossPlatformImage, original: Data?) -> Data? {
        if preferCacheOriginalData {
            return original ??
                image.data(
                    format: original?.imageFormat ?? .unknown,
                    compressionQuality: compressionQuality
                )
        } else {
            return image.data(
                format: original?.imageFormat ?? .unknown,
                compressionQuality: compressionQuality
            )
        }
    }

    /// Gets an image deserialized from provided data.
    ///
    /// - Parameters:
    ///   - data: The data from which an image should be deserialized.
    ///   - options: Options for deserialization.
    /// - Returns: An image deserialized or `nil` when no valid image
    ///            could be deserialized.
    func image(with data: Data, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        return KFCrossPlatformImage.image(data: data, options: options.imageCreatingOptions)
    }
}

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

extension Data {
    /// Gets the image format corresponding to the data.
    var imageFormat: ImageFormat {
        guard count > 8 else { return .unknown }

        var buffer = [UInt8](repeating: 0, count: 8)
        copyBytes(to: &buffer, count: 8)

        if buffer == ImageFormat.HeaderData.PNG {
            return .PNG

        } else if buffer[0] == ImageFormat.HeaderData.JPEG_SOI[0],
                  buffer[1] == ImageFormat.HeaderData.JPEG_SOI[1],
                  buffer[2] == ImageFormat.HeaderData.JPEG_IF[0] {
            return .JPEG

        } else if buffer[0] == ImageFormat.HeaderData.GIF[0],
                  buffer[1] == ImageFormat.HeaderData.GIF[1],
                  buffer[2] == ImageFormat.HeaderData.GIF[2] {
            return .GIF
        }

        return .unknown
    }
}

extension KFCrossPlatformImage {
    /// Returns a data representation for `base` image, with the `format` as the format indicator.
    /// - Parameters:
    ///   - format: The format in which the output data should be. If `unknown`, the `base` image will be
    ///             converted in the PNG representation.
    ///   - compressionQuality: The compression quality when converting image to a lossy format data.
    ///
    /// - Returns: The output data representing.
    func data(format: ImageFormat, compressionQuality: CGFloat = 1.0) -> Data? {
        return autoreleasepool { () -> Data? in
            let data: Data?
            switch format {
            case .PNG: data = pngRepresentation()
            case .JPEG: data = jpegRepresentation(compressionQuality: compressionQuality)
            default: data = nil
            }

            return data
        }
    }

    /// Returns PNG representation of `base` image.
    ///
    /// - Returns: PNG data of image.
    func pngRepresentation() -> Data? {
        #if os(macOS)
            guard let cgImage = cgImage else {
                return nil
            }
            let rep = NSBitmapImageRep(cgImage: cgImage)
            return rep.representation(using: .png, properties: [:])
        #else
            return pngData()
        #endif
    }

    /// Returns JPEG representation of `base` image.
    ///
    /// - Parameter compressionQuality: The compression quality when converting image to JPEG data.
    /// - Returns: JPEG data of image.
    func jpegRepresentation(compressionQuality: CGFloat) -> Data? {
        #if os(macOS)
            guard let cgImage = cgImage else {
                return nil
            }
            let rep = NSBitmapImageRep(cgImage: cgImage)
            return rep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
        #else
            return jpegData(compressionQuality: compressionQuality)
        #endif
    }
}
