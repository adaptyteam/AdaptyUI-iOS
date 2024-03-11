//
//  Image+Extensions.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

private var imageSourceKey: Void?

extension KFCrossPlatformImage: CacheCostCalculable {
    // Bitmap memory cost with bytes.
    var cacheCost: Int {
        let pixel = Int(size.width * size.height * scale * scale)
        guard let cgImage = cgImage else {
            return pixel * 4
        }
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        guard let imageCount = images?.count else {
            return pixel * bytesPerPixel
        }
        return pixel * bytesPerPixel * imageCount
    }
}

extension KFCrossPlatformImage {
    /// Return an image with given scale.
    ///
    /// - Parameter scale: Target scale factor the new image should have.
    /// - Returns: The image with target scale. If the base image is already in the scale, `base` will be returned.
    func scaled(to scale: CGFloat) -> KFCrossPlatformImage {
        guard scale != self.scale else {
            return self
        }
        guard let cgImage = cgImage else {
            assertionFailure("[Kingfisher] Scaling only works for CG-based image.")
            return self
        }
        return KFCrossPlatformImage.image(cgImage: cgImage, scale: scale, refImage: self)
    }

    #if os(macOS)
        static func image(cgImage: CGImage, scale: CGFloat, refImage: KFCrossPlatformImage?) -> KFCrossPlatformImage {
            return KFCrossPlatformImage(cgImage: cgImage, size: .zero)
        }

        /// Normalize the image. This getter does nothing on macOS but return the image itself.
        var normalized: KFCrossPlatformImage { return self }

    #else
        /// Creating an image from a give `CGImage` at scale and orientation for refImage. The method signature is for
        /// compatibility of macOS version.
        static func image(cgImage: CGImage, scale: CGFloat, refImage: KFCrossPlatformImage?) -> KFCrossPlatformImage {
            return KFCrossPlatformImage(cgImage: cgImage, scale: scale, orientation: refImage?.imageOrientation ?? .up)
        }
    #endif

    /// The custom frame source of current image.
    private(set) var frameSource: ImageFrameSource? {
        get { return getAssociatedObject(self, &imageSourceKey) }
        set { setRetainedAssociatedObject(self, &imageSourceKey, newValue) }
    }

    /// Returns the decoded image of the `base` image. It will draw the image in a plain context and return the data
    /// from it. This could improve the drawing performance when an image is just created from data but not yet
    /// displayed for the first time.
    ///
    /// - Note: This method only works for CG-based image. The current image scale is kept.
    ///         For any non-CG-based image or animated image, `base` itself is returned.
    var decoded: KFCrossPlatformImage { return decoded(scale: scale) }

    /// Returns decoded image of the `base` image at a given scale. It will draw the image in a plain context and
    /// return the data from it. This could improve the drawing performance when an image is just created from
    /// data but not yet displayed for the first time.
    ///
    /// - Parameter scale: The given scale of target image should be.
    /// - Returns: The decoded image ready to be displayed.
    ///
    /// - Note: This method only works for CG-based image. The current image scale is kept.
    ///         For any non-CG-based image or animated image, `base` itself is returned.
    func decoded(scale: CGFloat) -> KFCrossPlatformImage {
        // Prevent animated image (GIF) losing it's images
        #if os(iOS) || os(visionOS)
            if frameSource != nil { return self }
        #else
            if images != nil { return self }
        #endif

        guard let imageRef = cgImage else {
            assertionFailure("[Kingfisher] Decoding only works for CG-based image.")
            return self
        }

        let size = CGSize(width: CGFloat(imageRef.width) / scale, height: CGFloat(imageRef.height) / scale)
        return draw(to: size, inverting: true, scale: scale) { context in
            context.draw(imageRef, in: CGRect(origin: .zero, size: size))
            return true
        }
    }

    func draw(
        to size: CGSize,
        inverting: Bool,
        scale: CGFloat? = nil,
        refImage: KFCrossPlatformImage? = nil,
        draw: (CGContext) -> Bool // Whether use the refImage (`true`) or ignore image orientation (`false`)
    ) -> KFCrossPlatformImage {
        #if os(macOS) || os(watchOS)
            let targetScale = scale ?? self.scale
            GraphicsContext.begin(size: size, scale: targetScale)
            guard let context = GraphicsContext.current(size: size, scale: targetScale, inverting: inverting, cgImage: cgImage) else {
                assertionFailure("[Kingfisher] Failed to create CG context for blurring image.")
                return self
            }
            defer { GraphicsContext.end() }
            let useRefImage = draw(context)
            guard let cgImage = context.makeImage() else {
                return self
            }
            let ref = useRefImage ? (refImage ?? self) : nil
            return KingfisherWrapper.image(cgImage: cgImage, scale: targetScale, refImage: ref)
        #else

            let format = UIGraphicsImageRendererFormat.preferred()
            format.scale = scale ?? self.scale
            let renderer = UIGraphicsImageRenderer(size: size, format: format)

            var useRefImage: Bool = false
            let image = renderer.image { rendererContext in

                let context = rendererContext.cgContext
                if inverting { // If drawing a CGImage, we need to make context flipped.
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.translateBy(x: 0, y: -size.height)
                }

                useRefImage = draw(context)
            }
            if useRefImage {
                guard let cgImage = image.cgImage else {
                    return self
                }
                let ref = refImage ?? self
                return KFCrossPlatformImage.image(cgImage: cgImage, scale: format.scale, refImage: ref)
            } else {
                return image
            }
        #endif
    }

    /// Creates an image from a given data and options. `.JPEG`, `.PNG` or `.GIF` is supported. For other
    /// image format, image initializer from system will be used. If no image object could be created from
    /// the given `data`, `nil` will be returned.
    ///
    /// - Parameters:
    ///   - data: The image data representation.
    ///   - options: Options to use when creating the image.
    /// - Returns: An `Image` object represents the image if created. If the `data` is invalid or not supported, `nil`
    ///            will be returned.
    static func image(data: Data, options: ImageCreatingOptions) -> KFCrossPlatformImage? {
        var image: KFCrossPlatformImage?
        switch data.imageFormat {
        case .JPEG:
            image = KFCrossPlatformImage(data: data, scale: options.scale)
        case .PNG:
            image = KFCrossPlatformImage(data: data, scale: options.scale)
        case .GIF:
            image = nil
        case .unknown:
            image = KFCrossPlatformImage(data: data, scale: options.scale)
        }
        return image
    }
}
