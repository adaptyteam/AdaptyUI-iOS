//
//  Image+FrameSource.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// Represents a frame source for animated image
protocol ImageFrameSource {
    /// Source data associated with this frame source.
    var data: Data? { get }

    /// Count of total frames in this frame source.
    var frameCount: Int { get }

    /// Retrieves the frame at a specific index. The result image is expected to be
    /// no larger than `maxSize`. If the index is invalid, implementors should return `nil`.
    func frame(at index: Int, maxSize: CGSize?) -> CGImage?

    /// Retrieves the duration at a specific index. If the index is invalid, implementors should return `0.0`.
    func duration(at index: Int) -> TimeInterval
}
