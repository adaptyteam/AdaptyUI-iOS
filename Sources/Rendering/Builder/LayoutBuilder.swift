//
//  LayoutBuilder.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import Adapty
import UIKit

protocol LayoutBuilder {
    var activityIndicator: AdaptyActivityIndicatorComponentView? { get }
    var productsView: ProductsComponentView? { get }
    var continueButton: AdaptyButtonComponentView? { get }
    
    func buildInterface(on view: UIView) throws
    func viewDidLayoutSubviews(_ view: UIView)
    
    func addListeners(
        onContinue: @escaping () -> Void,
        onAction: @escaping (AdaptyUI.ButtonAction?) -> Void
    )
}
