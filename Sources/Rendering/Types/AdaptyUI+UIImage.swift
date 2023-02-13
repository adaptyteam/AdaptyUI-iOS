//
//  AdaptyUI+UIImage.swift
//
//
//  Created by Alexey Goncharov on 2023-01-23.
//

import Adapty
import UIKit

extension AdaptyUI.Image {
    var uiImage: UIImage? { UIImage(data: data) }
}
