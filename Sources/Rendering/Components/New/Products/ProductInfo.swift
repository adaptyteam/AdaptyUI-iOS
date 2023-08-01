//
//  File.swift
//
//
//  Created by Alexey Goncharov on 27.7.23..
//

import Adapty
import UIKit

protocol ProductInfo {
    var title: String? { get }
    var subtitle: String? { get }
    var price: String? { get }
    var priceSubtitle: String? { get }
}

protocol ProductInfoView: UIView {
    init(info: ProductInfo, productsBlock: AdaptyUI.ProductsBlock) throws
}
