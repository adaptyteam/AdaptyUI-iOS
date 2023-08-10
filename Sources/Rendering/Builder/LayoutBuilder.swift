//
//  LayoutBuilder.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

protocol LayoutBuilder {
    var productsView: ProductsComponentView? { get }
    var continueButton: AdaptyButtonComponentView? { get }
    
    func buildInterface(on view: UIView) throws
    func viewDidLayoutSubviews(_ view: UIView)
    func onAction(_ callback: @escaping (AdaptyUI.ButtonAction) -> Void)
}
