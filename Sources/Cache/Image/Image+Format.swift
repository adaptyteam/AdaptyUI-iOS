//
//  Image+Format.swift
//
//
//  Created by Aleksey Goncharov on 11.3.24..
//

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

/// Represents image format.
///
/// - unknown: The format cannot be recognized or not supported yet.
/// - PNG: PNG image format.
/// - JPEG: JPEG image format.
/// - GIF: GIF image format.
enum ImageFormat {
    /// The format cannot be recognized or not supported yet.
    case unknown
    /// PNG image format.
    case PNG
    /// JPEG image format.
    case JPEG
    /// GIF image format.
    case GIF

    struct HeaderData {
        static var PNG: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        static var JPEG_SOI: [UInt8] = [0xFF, 0xD8]
        static var JPEG_IF: [UInt8] = [0xFF]
        static var GIF: [UInt8] = [0x47, 0x49, 0x46]
    }

    /// https://en.wikipedia.org/wiki/JPEG
    enum JPEGMarker {
        case SOF0 // baseline
        case SOF2 // progressive
        case DHT // Huffman Table
        case DQT // Quantization Table
        case DRI // Restart Interval
        case SOS // Start Of Scan
        case RSTn(UInt8) // Restart
        case APPn // Application-specific
        case COM // Comment
        case EOI // End Of Image

        var bytes: [UInt8] {
            switch self {
            case .SOF0: return [0xFF, 0xC0]
            case .SOF2: return [0xFF, 0xC2]
            case .DHT: return [0xFF, 0xC4]
            case .DQT: return [0xFF, 0xDB]
            case .DRI: return [0xFF, 0xDD]
            case .SOS: return [0xFF, 0xDA]
            case let .RSTn(n): return [0xFF, 0xD0 + n]
            case .APPn: return [0xFF, 0xE0]
            case .COM: return [0xFF, 0xFE]
            case .EOI: return [0xFF, 0xD9]
            }
        }
    }
}
