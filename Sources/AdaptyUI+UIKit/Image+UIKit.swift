//
//  Image+UIKit.swift
//  
//
//  Created by Alexey Goncharov on 10.8.23..
//

import Adapty
import UIKit

extension AdaptyUI.Image {
    var uiImage: UIImage? { UIImage(data: data) }
}
