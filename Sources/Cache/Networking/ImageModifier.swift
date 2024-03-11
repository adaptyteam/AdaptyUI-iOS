
#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// An `ImageModifier` can be used to change properties on an image between cache serialization and the actual use of
/// the image. The `modify(_:)` method will be called after the image retrieved from its source and before it returned
/// to the caller. This modified image is expected to be only used for rendering purpose, any changes applied by the
/// `ImageModifier` will not be serialized or cached.
protocol ImageModifier {
    /// Modify an input `Image`.
    ///
    /// - parameter image:   Image which will be modified by `self`
    ///
    /// - returns: The modified image.
    ///
    /// - Note: The return value will be unmodified if modifying is not possible on
    ///         the current platform.
    /// - Note: Most modifiers support UIImage or NSImage, but not CGImage.
    func modify(_ image: KFCrossPlatformImage) -> KFCrossPlatformImage
}

/// A wrapper for creating an `ImageModifier` easier.
/// This type conforms to `ImageModifier` and wraps an image modify block.
/// If the `block` throws an error, the original image will be used.
struct AnyImageModifier: ImageModifier {
    /// A block which modifies images, or returns the original image
    /// if modification cannot be performed with an error.
    let block: (KFCrossPlatformImage) throws -> KFCrossPlatformImage

    /// Creates an `AnyImageModifier` with a given `modify` block.
    init(modify: @escaping (KFCrossPlatformImage) throws -> KFCrossPlatformImage) {
        block = modify
    }

    /// Modify an input `Image`. See `ImageModifier` protocol for more.
    func modify(_ image: KFCrossPlatformImage) -> KFCrossPlatformImage {
        return (try? block(image)) ?? image
    }
}

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    import UIKit

    /// Modifier for setting the rendering mode of images.
    struct RenderingModeImageModifier: ImageModifier {
        /// The rendering mode to apply to the image.
        let renderingMode: UIImage.RenderingMode

        /// Creates a `RenderingModeImageModifier`.
        ///
        /// - Parameter renderingMode: The rendering mode to apply to the image. Default is `.automatic`.
        init(renderingMode: UIImage.RenderingMode = .automatic) {
            self.renderingMode = renderingMode
        }

        /// Modify an input `Image`. See `ImageModifier` protocol for more.
        func modify(_ image: KFCrossPlatformImage) -> KFCrossPlatformImage {
            return image.withRenderingMode(renderingMode)
        }
    }

    /// Modifier for setting the `flipsForRightToLeftLayoutDirection` property of images.
    struct FlipsForRightToLeftLayoutDirectionImageModifier: ImageModifier {
        /// Creates a `FlipsForRightToLeftLayoutDirectionImageModifier`.
        init() {}

        /// Modify an input `Image`. See `ImageModifier` protocol for more.
        func modify(_ image: KFCrossPlatformImage) -> KFCrossPlatformImage {
            return image.imageFlippedForRightToLeftLayoutDirection()
        }
    }

    /// Modifier for setting the `alignmentRectInsets` property of images.
    struct AlignmentRectInsetsImageModifier: ImageModifier {
        /// The alignment insets to apply to the image
        let alignmentInsets: UIEdgeInsets

        /// Creates an `AlignmentRectInsetsImageModifier`.
        init(alignmentInsets: UIEdgeInsets) {
            self.alignmentInsets = alignmentInsets
        }

        /// Modify an input `Image`. See `ImageModifier` protocol for more.
        func modify(_ image: KFCrossPlatformImage) -> KFCrossPlatformImage {
            return image.withAlignmentRectInsets(alignmentInsets)
        }
    }
#endif
