//
//  LayoutBuilder.swift
//
//
//  Created by Alexey Goncharov on 30.6.23..
//

import UIKit

protocol LayoutBuilder {
    func buildInterface(on view: UIView)

    func viewDidLayoutSubviews(_ view: UIView)

    func onCloseButtonPressed(_ callback: @escaping () -> Void)
}
