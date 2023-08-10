//
//  ProductInfoView.swift
//
//
//  Created by Alexey Goncharov on 10.8.23..
//

import UIKit
import Adapty

protocol ProductInfoView: UIView {
    init(info: ProductInfoModel, productsBlock: AdaptyUI.ProductsBlock) throws
}
