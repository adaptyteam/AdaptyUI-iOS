//
//  Image+CreatingOptions.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

import Foundation
import ImageIO

/// Represents a set of image creating options used in Kingfisher.
struct ImageCreatingOptions {

    /// The target scale of image needs to be created.
    let scale: CGFloat

    /// The expected animation duration if an animated image being created.
    let duration: TimeInterval

    /// For an animated image, whether or not all frames should be loaded before displaying.
    let preloadAll: Bool

    /// For an animated image, whether or not only the first image should be
    /// loaded as a static image. It is useful for preview purpose of an animated image.
    let onlyFirstFrame: Bool
    
    /// Creates an `ImageCreatingOptions` object.
    ///
    /// - Parameters:
    ///   - scale: The target scale of image needs to be created. Default is `1.0`.
    ///   - duration: The expected animation duration if an animated image being created.
    ///               A value less or equal to `0.0` means the animated image duration will
    ///               be determined by the frame data. Default is `0.0`.
    ///   - preloadAll: For an animated image, whether or not all frames should be loaded before displaying.
    ///                 Default is `false`.
    ///   - onlyFirstFrame: For an animated image, whether or not only the first image should be
    ///                     loaded as a static image. It is useful for preview purpose of an animated image.
    ///                     Default is `false`.
    init(
        scale: CGFloat = 1.0,
        duration: TimeInterval = 0.0,
        preloadAll: Bool = false,
        onlyFirstFrame: Bool = false)
    {
        self.scale = scale
        self.duration = duration
        self.preloadAll = preloadAll
        self.onlyFirstFrame = onlyFirstFrame
    }
}
