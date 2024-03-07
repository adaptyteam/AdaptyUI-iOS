//
//  Image+UIKit.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

extension AdaptyUI.Image {
    var uiImage: UIImage? {
        switch self {
        case let .raster(data):
            return UIImage(data: data)
        case let .url(_, previewData):
            if let previewData = previewData {
                return UIImage(data: previewData)
            } else {
                return nil
            }
        }
    }
}
